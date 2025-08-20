type input = { in_filename : string; out_filename : string; iterations : int }

let solve input =
  let open Bimage in
  let rec solve' in_img iter =
    let out_img = Image.like in_img in
    let w = in_img.width in
    let h = in_img.height in
    let interpolate a b =
      let open Float in
      div (add a b) 2.
    in
    let img_get = Image.get in_img in
    let img_set = Image.set out_img in
    for x = 0 to w - 1 do
      for y = 0 to (h / 2) - 1 do
        if x mod 2 = 1 then
          for c = 0 to 4 do
            [ (w / 2, 0); (0, h / 2) ]
            |> List.iter (fun (x_offset, y_offset) ->
                   img_get x (y_offset + y) c
                   |> interpolate (img_get (x - 1) (y_offset + y) c)
                   |> img_set (x_offset + (x / 2)) (2 * y) c;
                   img_get x (y_offset + y) c
                   |> interpolate (img_get (x - 1) (y_offset + y) c)
                   |> interpolate
                        (img_get x (y_offset + y + 1) c
                        |> interpolate (img_get (x - 1) (y_offset + y + 1) c))
                   |> img_set (x_offset + (x / 2)) ((2 * y) + 1) c)
          done
      done
    done;
    if iter = 1 then out_img else solve' out_img (iter - 1)
  in
  let in_img =
    match Bimage_unix.Magick.read f32 rgba input.in_filename with
    | Ok img -> img
    | Error err -> raise @@ Failure (Error.to_string err)
  in
  let out_img = solve' in_img input.iterations in
  Bimage_unix.Magick.write input.out_filename out_img;
  Printf.printf "Done. Open '%s'\n" input.out_filename
;;

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
