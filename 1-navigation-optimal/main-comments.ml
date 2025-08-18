(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 1 - Navigation Optimal
  Date: 16th August 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ ocamlc main.ml -o main`
  + `$ ./main`
  + Copy output and paste into the first empty cell in Desmos Graphing
    Calculator: https://www.desmos.com/calculator
  + Hold press on the circle on the left of Cell 3; in the menu that opens up,
    enable 'Lines'
  + Enter Cell 6 and simply hit left arrow key once
  + Enter Cell 9 and simply hit left arrow key once
*)

(* Input data-types *)
type rect = { x : int; y : int; width : int; height : int }

let left { x; y; width; height } = ((x, y), (x, y + height))
let right { x; y; width; height } = ((x + width, y), (x + width, y + height))

type input = { goal : int; rects : rect list }

(* Output data-types *)
type coord = { x : int; y : int }
type output = { path : coord list; distance : float }
type side_to_walk = Left | Right
type side_vertical = Up | Down

(* whether line between two points (x, y) & (x', y') intersects with rectange
   `rect` *)
let intersect_line_rect (x, y) (x', y') (rect : rect) =
  let open Float in
  (* From `(x,y), (x',y')` line equation to `y = mx + c` equation *)
  let mx_plus_c_of_2_point (x, y) (x', y') =
    let m = (div @@ sub (of_int y') (of_int y)) @@ sub (of_int x') (of_int x) in
    let c = sub (of_int y) (mul (of_int x) m) in
    (m, c)
  in

  let rect_base_y = rect.y in
  let rect_top_y = rect.y + rect.height in
  let m, c = mx_plus_c_of_2_point (x, y) (x', y') in
  (* mantissa of the line at the level of the base and top of the rectangle
     respectively *)
  let line_x_min, line_x_max =
    if is_finite m then
      min_max
        (div (sub (of_int rect_base_y) c) m)
        (div (sub (of_int rect_top_y) c) m)
    else
      (* line is parallel to y-axis *)
      (of_int x, of_int x)
  in
  not (line_x_max < of_int rect.x || line_x_min > of_int (rect.x + rect.width))

(*
  NOTE: Solution
*)
let solve input : output =
  (* `None` if uninitialized *)
  let shortest_dist = ref None in
  let shortest_path = ref None in

  (* Calculates the distance of the path represented by the given coordinates *)
  let rec calc_dist = function
    | [] | [ _ ] -> 0.
    | (x, y) :: ((x', y') as new_head) :: xs ->
        let open Float in
        let x, x', y, y' = (of_int x, of_int x', of_int y, of_int y') in
        sqrt (add (pow (sub y' y) 2.) (pow (sub x' x) 2.))
        |> add (calc_dist @@ (new_head :: xs))
  in

  (*
    Evaluates the path to walk from `(x,y)` to `(x',y')` along each of the
    provided set of rectangle-sides, jumping directly to the goal if possible

    NOTE: if `fast_path` is true, it also tries jumping directly to a rectangle
    after the immediate next rectangle at any time, given there are no obstacles
    NOTE: Returns None when the path is invalid, i.e. a jump is required that
    passes through a rectangle
    NOTE: `lines` is assumed to be sorted in ascending order of `y`
    NOTE: The provided path excludes (x, y) itself
  *)
  let rec walk_along fast_path (x, y) (x', y') rect_sides =
    match rect_sides with
    (* We are already at the goal, no extra jumps *)
    | _ when x = x' && y = y' -> Some []
    (* No more rectangles ahead, single jump to the goal *)
    | [] -> Some [ (x', y') ]
    (*
      Rectangles ahead:
      1. Try to directly jump to the goal
      2. If 1 not possible & fast_path enabled, try to jump to bottom or the top
         of the farthest rectangle side
      3. If fast_path enabled & 2 not possible or fast_path disabled & 1 not
         possible, walk to immediate next rectangle, walk along it, and then try
         all over again
    *)
    | (next_rect, side) :: xs -> (
        (* 1. Try to directly jump to the goal *)
        let can_jump_to_goal =
          let open Seq in
          fold_left
            (fun no_intersects this_intersects ->
              no_intersects && not this_intersects)
            true
            (map
               (fun (rect, _) -> intersect_line_rect (x, y) (x', y') rect)
               (List.to_seq rect_sides))
        in
        if can_jump_to_goal then Some [ (x', y') ]
        else
          (* 2. Try to jump to bottom or the top of the farthest rectangle side*)
          let goals =
            let open List in
            xs
            |> mapi (fun rect_id (rect, side) ->
                   let (u, v), (u', v') =
                     match side with Left -> left rect | Right -> right rect
                   in
                   [ ((u', v'), (rect_id, Up)); ((u, v), (rect_id, Down)) ])
            (* best to worst == farthest to nearest, i.e. reverse *)
            |> rev
            |> flatten
          in
          let rect_to_jump =
            let open Seq in
            (* If fast_path is disabled, don't try this *)
            if not fast_path then None
            else
              List.to_seq goals
              |> map (fun (goal, (rect_id, rect_side_vert)) ->
                     List.to_seq rect_sides
                     (* the only obstacles in the path to a side of this
                      destination-rectangle are the ones that come before it
                      (including the immediately next) and, in the case the goal
                      is the top of a rectangle, the destination-rectangle itself
                      as well *)
                     |> take
                          (match rect_side_vert with
                          | Down -> rect_id + 1
                          | Up -> rect_id + 2)
                     (* Ensure that the line to the point on the side of the
                      destination-rectangle doesn't intersect with any rectangles
                      in between *)
                     |> map (fun (rect, _) ->
                            intersect_line_rect (x, y) goal rect)
                     |> fold_left
                          (fun no_intersects this_intersects ->
                            no_intersects && not this_intersects)
                          true)
              (* Get the farthest destination-rectangle that can be jumped to *)
              |> find_mapi (fun id no_intersects ->
                     if no_intersects then Some id else None)
          in
          match rect_to_jump with
          (* Jump to the found destination-rectangle *)
          | Some rect_side ->
              let open List in
              let side, (rect_id, rect_side_vert) = nth goals rect_side in
              let remaining_rects =
                drop
                  (match rect_side_vert with
                  | Down -> rect_id
                  | Up -> rect_id + 1)
                  xs
              in
              walk_along fast_path side (x', y') remaining_rects
              |> Option.map (fun l -> side :: l)
          (* No jumps available, so
             3. Walk to immediate next rectangle, walk along it, and then try all
                over again
          *)
          | None ->
              let (u, v), (u', v') =
                match side with
                | Left -> left next_rect
                | Right -> right next_rect
              in
              if u = u' && v = v' then
                walk_along fast_path (u', v') (x', y') xs
                |> Option.map (fun l -> (u', v') :: l)
                (* Invalid path having jump through a rectangle, stop walking *)
              else if (u != u' && v = v') || (u = v' && v > v') then None
              else
                walk_along fast_path (u', v') (x', y') xs
                |> Option.map (( @ ) [ (u, v); (u', v') ]))
  in

  (*
    Gets all combinations selecting the left or right sides of a rectangle

    EXAMPLE: `[(0,0,10,10); (-10,10,10,10)]` becomes `[
      [left(0,0,10,10), left(-10,10,10,10)];
      [left(0,0,10,10), right(-10,10,10,10)];
      [right(0,0,10,10), left(-10,10,10,10)];
      [right(0,0,10,10), right(-10,10,10,10)];
    ]`
  *)
  let rec combinations = function
    | [] -> []
    (* The last rectangle *)
    | [ rect ] -> [ [ (rect, Left) ]; [ (rect, Right) ] ]
    | rect :: xs ->
        let xs_combinations = combinations xs in
        (* All combinations having the left line of this rectangle *)
        List.map (( @ ) [ (rect, Left) ]) xs_combinations
        @
        (* All combinations having the right line of this rectangle *)
        List.map (( @ ) [ (rect, Right) ]) xs_combinations
  in

  (*
    Update the shortest-distance refcell with a newly encountered path distance
  *)
  let update_shortest_path new_path =
    let open Option in
    let new_dist = calc_dist new_path in
    if
      (* First distance encountered *)
      !shortest_dist |> is_none
      (* New shortest distance *)
      || bind !shortest_dist (fun old_dist ->
             if new_dist < old_dist then Some () else None)
         |> is_some
    then (
      shortest_dist := Some new_dist;
      shortest_path := Some new_path)
  in

  (* NOTE: evaluation begins here *)

  (* First Sort rectangles by ascending order of `y` *)
  let rects =
    List.sort (fun ({ y; _ } : rect) { y = y'; _ } -> y - y') input.rects
  in
  let open List in
  combinations rects
  |> map (fun combination ->
         let open Option in
         List.append
           (to_list @@ walk_along true (0, 0) (0, input.goal) combination)
           (to_list @@ walk_along false (0, 0) (0, input.goal) combination))
  |> flatten
  |> iter (fun path ->
         let path = (0, 0) :: path in
         update_shortest_path path);
  {
    path =
      (match !shortest_path with
      | Some path -> path |> map (fun (x, y) -> { x; y })
      | None -> raise Exit);
    distance =
      (match !shortest_dist with
      | Some distance -> distance
      | None -> raise Exit);
  }

(*
  Solve the given input & generate the `desmos` expressions to visualize the
  rectangles & the path taken
*)
let generate_desmos input =
  let print_list draw label list =
    let xh, xs =
      match (List.to_seq list) () with
      | Cons (first, rest) -> (first, rest)
      | Nil -> raise Exit
    in
    Printf.printf "%s = [%s" label (draw xh);
    Seq.iter (fun x -> Printf.printf ",%s" @@ draw x) xs;
    print_endline "]"
  in
  let soln = solve input in
  Printf.printf "# Desmos Output\n";
  Printf.printf "# Distance: %f units\n" soln.distance;
  (* Draw list of points in solution path *)
  soln.path |> print_list (fun { x; y } -> Printf.sprintf "(%d,%d)" x y) "p";
  (* Draw rectangles *)
  input.rects
  |> List.iteri (fun i (rect : rect) ->
         let tag = string_of_int i in
         let print_list = print_list string_of_int in
         print_list
           (Printf.sprintf "x_%s" tag)
           [ rect.x; rect.x; rect.x + rect.width; rect.x + rect.width ];
         print_list
           (Printf.sprintf "y_%s" tag)
           [ rect.y; rect.y + rect.height; rect.y + rect.height; rect.y ];
         Printf.printf "polygon(x_%s, y_%s)\n" tag tag)
;;

(*
  NOTE: Sample Example
*)
generate_desmos
  {
    goal = 48;
    rects =
      [
        { x = -18; y = 31; width = 22; height = 8 };
        { x = -6; y = 10; width = 22; height = 8 };
      ];
  }
