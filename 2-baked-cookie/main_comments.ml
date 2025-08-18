(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 2 - Baked Cookie
  Date: 18th August 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ opam install .`
  + `$ dune build`
  + `$ dune exec main -- poster.webp poster-unbaked.webp`
*)

(* Input data-types *)
type input = { in_filename : string; out_filename : string }

let solve input =
  let open Bimage in
  let in_img =
    match Bimage_unix.Magick.read f32 rgba input.in_filename with
    | Ok img -> img
    | Error err -> raise @@ Failure (Error.to_string err)
  in
  let out_img = Image.like in_img in

  let w = in_img.width in
  let h = in_img.height in
  let interpolate a b =
    let open Float in
    div (add a b) 2.
  in

  let img_get = Image.get in_img in
  let img_set = Image.set out_img in

  (* Top half of `in_img` scrunched into right half of `out_img`*)
  for x = 0 to w - 1 do
    for y = 0 to (h / 2) - 1 do
      if x mod 2 = 1 then
        for c = 0 to 4 do
          (* interpolate 2 pixels along width of `in_img` and write as first
             pixel on `out_img` *)
          img_get x y c
          |> interpolate (img_get (x - 1) y c)
          |> img_set ((w / 2) + (x / 2)) (2 * y) c;
          (* interpolate 4 corresponding pixels of `in_img` and write as second
             pixel on `out_img` (below first pixel) *)
          interpolate (img_get x y c) (img_get (x - 1) y c)
          |> interpolate
               (interpolate (img_get x (y + 1) c) (img_get (x - 1) (y + 1) c))
          |> img_set ((w / 2) + (x / 2)) ((2 * y) + 1) c
        done
    done
  done;

  (* Bottom half of `in_img` scrunched into left half of `out_img`*)
  for x = 0 to in_img.width - 1 do
    for y = 0 to (in_img.height / 2) - 1 do
      if x mod 2 = 1 then
        for c = 0 to 4 do
          (* interpolate 2 pixels along width of `in_img` and write as first
             pixel on `out_img` *)
          img_get x ((h / 2) + y) c
          |> interpolate (img_get (x - 1) ((h / 2) + y) c)
          |> img_set (x / 2) (2 * y) c;
          (* interpolate 4 corresponding pixels of `in_img` and write as second
             pixel on `out_img` (below first pixel) *)
          img_get x ((h / 2) + y) c
          |> interpolate (img_get (x - 1) ((h / 2) + y) c)
          |> interpolate
               (img_get x ((h / 2) + y + 1) c
               |> interpolate (img_get (x - 1) ((h / 2) + y + 1) c))
          |> img_set (x / 2) ((2 * y) + 1) c
        done
    done
  done;
  (* write output image *)
  Bimage_unix.Magick.write input.out_filename out_img;
  Printf.printf "Done. Open '%s'\n" input.out_filename
;;

let in_filename, out_filename =
  match Array.to_list Sys.argv with
  | [ _; v1; v2 ] -> (v1, v2)
  | _ ->
      raise @@ Failure "Expecting arguments for input & output image filenames"
in
solve { in_filename; out_filename }
