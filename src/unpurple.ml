(* ocamlfind ocamlopt -o purple_fringe purple_fringe.ml \
     -package camlimages -linkpkg *)

open Printf
open Color

type mode = Normal | Diff | Blur | Pred

type param = {
  radius : float; (* pixels *)
  intensity : float; (* scalar more or less around 1.0 *)
  mode : mode;
}

let default_radius = 5.
let default_intensity = 1.

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

let average_window m imin imax jmin jmax =
  (*printf "window: imin=%i imax=%i jmin=%i jmax=%i\n" imin imax jmin jmax;*)
  let r_acc = ref 0 in
  let g_acc = ref 0 in
  let b_acc = ref 0 in
  for i = imin to imax do
    for j = jmin to jmax do
      let { r; g; b } = Rgb24.get m i j in
      r_acc := r + !r_acc;
      g_acc := g + !g_acc;
      b_acc := b + !b_acc;
    done
  done;
  let area = (max 0 (imax - imin + 1)) * (max 0 (jmax - jmin + 1)) in
  let farea = float area in
  let maxint = farea *. 255. in
  (float !r_acc /. maxint,
   float !g_acc /. maxint,
   float !b_acc /. maxint,
   farea)


let make_purple_blur param w h m =
  let rmax = truncate (ceil (2. *. param.radius)) in
  let r0 = rmax / 10 in
  let d0 = 2 * r0 + 1 in
  (*printf "rmax=%i r0=%i d0=%i\n%!" rmax r0 d0;*)
  let mask = gaussian_mask rmax param.radius in
  let blur = Array.make_matrix w h 0. in
  for i = 0 to w - 1 do
    if i mod d0 = 0 then
      for j = 0 to h - 1 do
        if j mod d0 = 0 then
          let r, g, b, area =
            average_window m
              (max 0 (i - r0)) (min (w - 1) (i + r0))
              (max 0 (j - r0)) (min (h - 1) (j + r0))
          in
          let p = area *. param.intensity *. b in
          for k1 = -rmax to rmax do
            let mask1 = mask.(k1+rmax) in
            let i' = i + k1 in
            if i' >= 0 && i' < w then
              let blur_i' = blur.(i') in
              for k2 = -rmax to rmax do
                let j' = j + k2 in
                if j' >= 0 && j' < h then (
                  let contrib = p *. Array.unsafe_get mask1 (k2+rmax) in
                  (*printf "i=%i j=%i i'=%i j'=%i k1=%i k2=%i contrib=%g\n"
                    i j i' j' k1 k2 contrib;*)
                  blur_i'.(j') <- blur_i'.(j') +. contrib
                )
              done
          done
      done
  done;
  blur

let remove_purple_blur param w h m purple_blur =
  let m2 = Rgb24.copy m in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let { r; g; b } = Rgb24.get m i j in
      let bl = min 255 (truncate (255. *. purple_blur.(i).(j))) in
      let b_diff = min bl (max (b - g) 0) in
      let r_diff = min (max (r - g) 0) (b_diff / 3) in
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
          | Pred ->
              let b_diff_pred = max 0 (bl - g) in
              let r_diff_pred = b_diff_pred / 3 in
              {
                r = r_diff_pred;
                g = 0;
                b = b_diff_pred;
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
  let mode = ref Normal in
  let files = ref [] in
  let options = [
    "-i", Arg.Set_float intensity,
    sprintf "<float>  Fraction of purple to remove (default: %g)" !intensity;
    "-r", Arg.Set_float radius,
    sprintf "<float>  Blur radius (default: %g pixels)" !radius;
    "-diff", Arg.Unit (fun () -> mode := Diff),
    "Output purple mask that would be substracted to the original image";
    "-blur", Arg.Unit (fun () -> mode := Blur),
    "Output blur used to simulate lack of focus of the purple light";
    "-pred", Arg.Unit (fun () -> mode := Pred),
    "Output predicted purple fringes";
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
    mode = !mode;
  }
  in
  run param infile outfile

let () = main ()
