(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 4 - Wavedash
  Date: 1st September 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ cd 5-wavedash`
  + `$ ocamlc solution.ml -o solution`
  + `$ ./solution`
*)
type building = { xstart : int; xend : int; height : int }
type jump = { angle : int; time : float }

let c_G = 9.81
let c_U = 10.
let ( + ) = Float.add
let ( - ) = Float.sub
let ( * ) = Float.mul
let ( / ) = Float.div
let ( ^ ) = Float.pow
let deg_to_radians x = x / 180. * Float.pi
let dx_after_t v0 theta t = v0 * cos theta * t
let dy_after_t v0 theta t = (v0 * sin theta * t) - (c_G * (t ^ 2.) / 2.)

let jump_for_t t (x, y) v0 angle =
  (x + dx_after_t v0 angle t, y + dy_after_t v0 angle t)

let solve ~buildings ~goal =
  (* Find the tallest building *)
  let max_building_height =
    try
      buildings
      |> List.fold_left
           (fun max' { height; _ } ->
             Some (match max' with None -> height | Some m -> max m height))
           None
      |> Option.get
    with Invalid_argument _ -> raise @@ Failure "No buildings passed"
  in
  Printf.printf "Max building height: %d\n" max_building_height;
  (* Find the number of 0-deg jumps needed to clear the horizontal distance
     from x=0 to x=goal *)
  let num_hor_jumps =
    (* u*cos(theta) = u for theta = 0 *)
    let hor_dist_per_jump = c_U in
    Float.of_int goal / hor_dist_per_jump |> ceil
  in
  (* Find the total decrease in height brought about by `num_hor_jumps` jumps *)
  let descent_hor_jumps =
    (* g*t^2 / 2 = g/2 for t = 1 *)
    let fall_per_hor_jump = c_G / 2.0 in
    fall_per_hor_jump * num_hor_jumps
  in
  (* Find sum of the height of the tallest building and `descent_hor_jumps` *)
  let ascent_vert_jumps =
    Float.of_int max_building_height + descent_hor_jumps
  in
  (* Find the number of 90-deg jumps needed to reach a height of `ascent_vert_jumps` *)
  let num_vert_jumps =
    (* u*sin(theta) - g*t^2/2 = u - g/2 for theta = 90 & t = 1 *)
    let rise_per_vert_jump = c_U - (c_G / 2.0) in
    ascent_vert_jumps / rise_per_vert_jump |> ceil |> Float.to_int
  in
  (* Assemble jumps:
     1. Make `num_vert_jumps` 90-deg 1-sec jumps to reach a height of `ascent_vert_jumps`
     2. Make `num_hor_jumps` 0-deg 1-sec jumps to reach x=goal without being blocked by any building *)
  Seq.(
    append
      (init num_vert_jumps (fun _ -> { angle = 90; time = 1. }))
      (init (Float.to_int num_hor_jumps) (fun _ -> { angle = 0; time = 1. })))
;;

(* Example *)
solve
  ~buildings:
    [
      { xstart = 2; xend = 4; height = 3 }; { xstart = 5; xend = 6; height = 4 };
    ]
  ~goal:10
|> Seq.fold_lefti
     (fun (x, y) i { angle; time } ->
       let x', y' =
         jump_for_t time (x, y) c_U (deg_to_radians @@ Float.of_int angle)
       in
       Printf.printf "Jump %d: %d degrees, %f seconds, New position: (%f, %f)\n"
         (succ i) angle time x' y';
       (x', y'))
     (0., 0.)
