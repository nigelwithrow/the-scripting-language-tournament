(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 2 - Baked Cookie
  Date: 18th August 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ opam install .`
  + `$ dune build`
  + `$ ./_build/default/main.exe poster.webp poster-unbaked.webp 4`
*)

(* Input data-types *)
type input = { in_filename : string; out_filename : string; iterations : int }

let solve input =
  let open Bimage in
  let rec solve' in_img iter =
    let out_img = Image.like in_img in
    let w = in_img.width in
    let h = in_img.height in

    (* Arithmetic mean i.e. Linear interpolation *)
    let interpolate a b =
      let open Float in
      div (add a b) 2.
    in

    let img_get = Image.get in_img in
    let img_set = Image.set out_img in

    (* Map over entire width of input image *)
    for x = 0 to w - 1 do
      (* Map over half of the height of input image *)
      for y = 0 to (h / 2) - 1 do
        (* Mapped image has width half of input image, so only write every
           alternative pixel of input image *)
        if x mod 2 = 1 then
          (* The 4 color channels *)
          for c = 0 to 4 do
            [
              (* Top half of `in_img` scrunched into right half of `out_img`*)
              (w / 2, 0);
              (* Bottom half of `in_img` scrunched into left half of `out_img`*)
              (0, h / 2);
            ]
            |> List.iter (fun (x_offset, y_offset) ->
                   (* interpolate 2 pixels along width of `in_img` and write as
                      first pixel on `out_img` *)
                   img_get x (y_offset + y) c
                   |> interpolate (img_get (x - 1) (y_offset + y) c)
                   |> img_set (x_offset + (x / 2)) (2 * y) c;
                   (* interpolate 4 corresponding pixels of `in_img` and write as
                      second pixel on `out_img` (below first pixel) *)
                   img_get x (y_offset + y) c
                   |> interpolate (img_get (x - 1) (y_offset + y) c)
                   |> interpolate
                        (img_get x (y_offset + y + 1) c
                        |> interpolate (img_get (x - 1) (y_offset + y + 1) c))
                   |> img_set (x_offset + (x / 2)) ((2 * y) + 1) c)
          done
      done
    done;
    if iter = 1 then
      (* Last iteration: Return output image *)
      out_img
    else
      (* Re-iterate *)
      solve' out_img (iter - 1)
  in
  let in_img =
    match Bimage_unix.Magick.read f32 rgba input.in_filename with
    | Ok img -> img
    | Error err -> raise @@ Failure (Error.to_string err)
  in
  (* Write output image *)
  let out_img = solve' in_img input.iterations in
  Bimage_unix.Magick.write input.out_filename out_img;

  Printf.printf "Done. Open '%s'\n" input.out_filename
;;

(* Get CLI arguments *)
let in_filename, out_filename, iterations =
  let err_msg =
    "Expecting arguments for input image filename (string), output image \
     filename (string) & iterations (integer >= 1). 4 to get the answer"
  in
  match Array.to_list Sys.argv with
  | [ _; v1; v2; v3 ] -> (
      try
        ( v1,
          v2,
          match int_of_string v3 with
          | n when n <= 0 -> raise @@ Failure err_msg
          | n -> n )
      with Failure _ -> raise @@ Failure err_msg)
  | _ -> raise @@ Failure err_msg
in
solve { in_filename; out_filename; iterations }
