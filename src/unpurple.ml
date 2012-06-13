open Printf
open Color

type mode = Normal | Diff | Blur

type param = {
  radius : float; (* pixels *)
  intensity : float; (* scalar more or less around 1.0 *)
  min_brightness : float; (* positive scalar smaller 1.0 *)
  min_red_to_blue_ratio : float;
  max_red_to_blue_ratio : float;
  mode : mode;
}

let default_radius = 5.
let default_intensity = 1.
let default_min_brightness = 0.
let default_min_red_to_blue_ratio = 0.
let default_max_red_to_blue_ratio = 0.33

let dims m =
  let n1 = Array.length m in
  if n1 = 0 then 0, 0
  else n1, Array.length m.(0)

let init_acc radius a =
  let n = Array.length a in
  if n = 0 then 0.
  else
    let acc = ref 0. in
    acc := float (radius+2) *. a.(0);
    for i = 1 to radius - 1 do
      acc := !acc +. a.(min (n-1) i)
    done;
    !acc

let init_acc_dim2 radius m j =
  let n = Array.length m in
  if n = 0 then 0.
  else
    let acc = ref 0. in
    acc := float (radius+2) *. m.(0).(j);
    for i = 1 to radius - 1 do
      acc := !acc +. m.(min (n-1) i).(j)
    done;
    !acc

let motion_blur_dim1 radius m =
  let n1, n2 = dims m in
  let w = float (2 * radius + 1) in
  for i = 0 to n1 - 1 do
    let a = m.(i) in
    let b = Array.make n2 0. in
    let acc = ref (init_acc radius a) in
    for j = 0 to n2 - 1 do
      acc := !acc
             -. a.(max 0 (j-1 - radius))
             +. a.(min (n2-1) (j + radius));
      b.(j) <- !acc /. w;
    done;
    m.(i) <- b
  done

let motion_blur_dim2 radius m =
  let n1, n2 = dims m in
  let w = float (2 * radius + 1) in
  for j = 0 to n2 - 1 do
    let b = Array.make n1 0. in
    let acc = ref (init_acc_dim2 radius m j) in
    for i = 0 to n1 - 1 do
      acc := !acc
             -. m.(max 0 (i-1 - radius)).(j)
             +. m.(min (n1-1) (i + radius)).(j);
      b.(i) <- !acc /. w;
    done;
    for i = 0 to n1 - 1 do
      m.(i).(j) <- b.(i)
    done
  done

let box_blur radius m =
  motion_blur_dim1 radius m;
  motion_blur_dim2 radius m

(*
  0/2 -> 0
  1/2 -> 1
  2/2 -> 1
  3/2 -> 2
  ...
*)
let div_up a b =
  let r = a / b in
  if a mod b = 0 then
    r
  else
    r + 1

let tent_blur radius m =
  box_blur (div_up radius 2) m;
  box_blur (div_up radius 2) m

let quadratic_blur radius m =
  box_blur (div_up radius 3) m;
  box_blur (div_up radius 3) m;
  box_blur (div_up radius 3) m


let make_purple_blur param w h m =
  let radius = truncate (ceil param.radius) in
  let blur = Array.make_matrix w h 0. in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let b = float (Rgb24.get m i j).b /. 255. in
      let p =
        let thresh = param.min_brightness in
        let white = (max 0. (b -. thresh)) *. 1. /. (1.-.thresh) in
        param.intensity *. white
      in
      blur.(i).(j) <- p
    done
  done;
  tent_blur radius blur;
  blur

let remove_purple_blur param w h m purple_blur =
  let m2 = Rgb24.copy m in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let { r; g; b } = Rgb24.get m i j in
      let bl = min 255. (255. *. purple_blur.(i).(j)) in

(*
      let b_diff = min bl (max (b - g) 0) in
      let r_diff = min (max (r - g) 0) (b_diff / 3) in
*)

      (* amount of blue and red that would produce a grey if removed *)
      let db = max (float b -. float g) 0. in
      let dr = max (float r -. float g) 0. in
      
      (* maximum amount of blue that we accept to remove, ignoring red level *)
      let mb = min bl db in

      (* amount of red that we will remove, honoring max red:blue *)
      let r_diff = min dr (mb *. param.max_red_to_blue_ratio) in

      (* amount of blue that we will remove, honoring min red:blue *)
      let b_diff =
        if param.min_red_to_blue_ratio > 0. then
          min mb (r_diff /. param.min_red_to_blue_ratio)
        else
          mb
      in

      let bl = truncate bl in
      let r_diff = truncate r_diff in
      let b_diff = truncate b_diff in

      let pixel =
        match param.mode with
            Normal ->
              {
                r = r - r_diff;
                g = g;
                b = b - b_diff
              }
          | Diff ->
              {
                r = r_diff;
                g = 0;
                b = b_diff
              }
          | Blur ->
              {
                r = bl;
                g = bl;
                b = bl;
              }
      in
      Rgb24.set m2 i j pixel
    done
  done;
  m2

let remove_purple_fringe param img =
  let m =
    match img with
        Images.Rgb24 x -> x
      | _ -> failwith "Not an RGB image"
  in
  let w, h = Images.size img in
  let mask = make_purple_blur param w h m in
  let m2 = remove_purple_blur param w h m mask in
  Images.Rgb24 m2

let run param infile outfile =
  let img = Images.load infile [] in
  let img2 = remove_purple_fringe param img in
  Images.save outfile None [] img2

let main () =
  let intensity = ref default_intensity in
  let radius = ref default_radius in
  let min_brightness = ref default_min_brightness in
  let min_red_to_blue_ratio = ref default_min_red_to_blue_ratio in
  let max_red_to_blue_ratio = ref default_max_red_to_blue_ratio in
  let mode = ref Normal in
  let files = ref [] in
  let options = [
    "-i", Arg.Set_float intensity,
    sprintf "<float>  Intensity of purple fringe (default: %g)" !intensity;

    "-m", Arg.Set_float min_brightness,
    sprintf "<float>  Minimum brightness (default: %g)" !min_brightness;

    "-r", Arg.Set_float radius,
    sprintf "<float>  Blur radius (default: %g pixels)" !radius;

    "-minred", Arg.Set_float min_red_to_blue_ratio,
    sprintf "<float>  Minimum red:blue ratio in the fringe (default: %g)"
      !min_red_to_blue_ratio;

    "-maxred", Arg.Set_float max_red_to_blue_ratio,
    sprintf "<float>  Maximum red:blue ratio in the fringe (default: %g)"
      !max_red_to_blue_ratio;

    "-diff", Arg.Unit (fun () -> mode := Diff),
    "Output purple mask that would be substracted to the original image";

    "-blur", Arg.Unit (fun () -> mode := Blur),
    "Output blur used to simulate lack of focus of the purple light";
  ]
  in
  let anon_fun s =
    files := s :: !files
  in
  let usage_msg =
    sprintf "\
Usage: %s [options] <input file> <output file>
This program attempts to remove purple fringing from photos (JPEG format).
" Sys.argv.(0)
  in
  Arg.parse options anon_fun usage_msg;
  let infile, outfile =
    match List.rev !files with
        [ infile; outfile ] -> infile, outfile
      | _ -> failwith "needs one input file and one output file; try -help"
  in
  let param = {
    radius = !radius;
    intensity = !intensity;
    min_brightness = !min_brightness;
    min_red_to_blue_ratio = !min_red_to_blue_ratio;
    max_red_to_blue_ratio = !max_red_to_blue_ratio;
    mode = !mode;
  }
  in
  run param infile outfile

let () = main ()
