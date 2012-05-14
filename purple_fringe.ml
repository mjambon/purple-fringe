(* ocamlfind ocamlopt -o purple_fringe purple_fringe.ml \
     -package camlimages -linkpkg *)

open Printf
open Color

type param = {
  radius : float; (* pixels *)
  intensity : float; (* scalar more or less around 1.0 *)
  diff_mode : bool;
}

let default_radius = 40.
let default_intensity = 3.0

let gaussian_mask rmax sigma =
  let len = 2 * rmax + 1 in
  let m = Array.make_matrix len len 0. in
  for i = -rmax to rmax do
    for j = -rmax to rmax do
      let r2 = float (i * i + j * j) in
      m.(i+rmax).(j+rmax) <- exp (-. r2 /. (2. *. sigma ** 2.))
    done
  done;
  let total = Array.fold_left (Array.fold_left (+.)) 0. m in
  Array.iteri
    (fun i a -> Array.iteri (fun j x -> m.(i).(j) <- x /. total) a)
    m;
  m

let make_purple_blur param w h m =
  let rmax = truncate (ceil (2. *. param.radius)) in
  let mask = gaussian_mask rmax param.radius in
  let blur = Array.make_matrix w h 0. in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let { r; g; b } = Rgb24.get m i j in
      let p = float (min (3*r) b) *. param.intensity in
      let acc = ref 0. in
      for k1 = -rmax to rmax do
        let mask1 = mask.(k1+rmax) in
        let i' = i + k1 in
        if i' >= 0 && i' < w then
          for k2 = -rmax to rmax do
            let j' = j + k2 in
            if j' >= 0 && j' < h then
              acc := !acc +. p *. Array.unsafe_get mask1 (k2+rmax)
          done
      done;
      blur.(i).(j) <- !acc
    done
  done;
  blur

let remove_purple_blur param w h m purple_blur =
  let m2 = Rgb24.copy m in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let { r; g; b } = Rgb24.get m i j in
      let bl = min 255 (truncate purple_blur.(i).(j)) in
      let b_diff = min bl (max (b - g) 0) in
      let r_diff = min (max (r - g) 0) (b_diff / 3) in
      let pixel =
        if param.diff_mode then
          {
            r = r_diff;
            g = 0;
            b = b_diff
          }
        else
          {
            r = r - r_diff;
            g = g;
            b = b - b_diff
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
  let diff_mode = ref false in
  let files = ref [] in
  let options = [
    "-i", Arg.Set_float intensity,
    sprintf "<float>  Fraction of purple to remove (default: %g)" !intensity;
    "-r", Arg.Set_float radius,
    sprintf "<float>  Blur radius (default: %g pixels)" !radius;
    "-diff", Arg.Set diff_mode,
    "Output purple mask that would be substracted to the original image";
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
    diff_mode = !diff_mode;
  }
  in
  run param infile outfile

let () = main ()
