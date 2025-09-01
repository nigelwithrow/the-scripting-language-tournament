type building = { xstart : int; xend : int; height : int }
type jump = { angle : int; time : float }

let c_G = 9.81
let c_U = 10.
let ( + ) = Float.add
let ( - ) = Float.sub
let ( * ) = Float.mul
let ( / ) = Float.div

let solve ~buildings ~goal =
  let max_building_height =
    buildings
    |> List.fold_left
         (fun max' { height; _ } ->
           Some (match max' with None -> height | Some m -> max m height))
         None
    |> Option.get
  in
  let num_hor_jumps =
    let hor_dist_per_jump = c_U in
    Float.of_int goal / hor_dist_per_jump |> ceil
  in
  let descent_hor_jumps =
    let fall_per_hor_jump = c_G / 2.0 in
    fall_per_hor_jump * num_hor_jumps
  in
  let ascent_vert_jumps =
    Float.of_int max_building_height + descent_hor_jumps
  in
  let num_vert_jumps =
    let rise_per_vert_jump = c_U - (c_G / 2.0) in
    ascent_vert_jumps / rise_per_vert_jump |> ceil |> Float.to_int
  in
  Seq.(
    append
      (init num_vert_jumps (fun _ -> { angle = 90; time = 1. }))
      (init (Float.to_int num_hor_jumps) (fun _ -> { angle = 0; time = 1. })))
;;

solve
  ~buildings:
    [
      { xstart = 2; xend = 4; height = 3 }; { xstart = 5; xend = 6; height = 4 };
    ]
  ~goal:10
|> Seq.iter (fun { angle; time } -> Printf.printf "(%d, %f)\n" angle time)
