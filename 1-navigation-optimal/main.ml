type rect = { x : int; y : int; width : int; height : int }

let left { x; y; width; height } = ((x, y), (x, y + height))
let right { x; y; width; height } = ((x + width, y), (x + width, y + height))

type input = { goal : int; rects : rect list }
type coord = { x : int; y : int }
type output = { path : coord list; distance : float }
type side_to_walk = Left | Right
type side_vertical = Up | Down

let intersect_line_rect (x, y) (x', y') (rect : rect) =
  let open Float in
  let mx_plus_c_of_2_point (x, y) (x', y') =
    let m = (div @@ sub (of_int y') (of_int y)) @@ sub (of_int x') (of_int x) in
    let c = sub (of_int y) (mul (of_int x) m) in
    (m, c)
  in
  let rect_base_y = rect.y in
  let rect_top_y = rect.y + rect.height in
  let m, c = mx_plus_c_of_2_point (x, y) (x', y') in
  let line_x_min, line_x_max =
    if is_finite m then
      min_max
        (div (sub (of_int rect_base_y) c) m)
        (div (sub (of_int rect_top_y) c) m)
    else (of_int x, of_int x)
  in
  not (line_x_max < of_int rect.x || line_x_min > of_int (rect.x + rect.width))

let solve input : output =
  let shortest_dist = ref None in
  let shortest_path = ref None in
  let rec calc_dist = function
    | [] | [ _ ] -> 0.
    | (x, y) :: ((x', y') as new_head) :: xs ->
        let open Float in
        let x, x', y, y' = (of_int x, of_int x', of_int y, of_int y') in
        sqrt (add (pow (sub y' y) 2.) (pow (sub x' x) 2.))
        |> add (calc_dist @@ (new_head :: xs))
  in
  let rec walk_along fast_path (x, y) (x', y') rect_sides =
    match rect_sides with
    | _ when x = x' && y = y' -> Some []
    | [] -> Some [ (x', y') ]
    | (next_rect, side) :: xs -> (
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
          let goals =
            let open List in
            xs
            |> mapi (fun rect_id (rect, side) ->
                   let (u, v), (u', v') =
                     match side with Left -> left rect | Right -> right rect
                   in
                   [ ((u', v'), (rect_id, Up)); ((u, v), (rect_id, Down)) ])
            |> rev |> flatten
          in
          let rect_to_jump =
            let open Seq in
            if not fast_path then None
            else
              List.to_seq goals
              |> map (fun (goal, (rect_id, rect_side_vert)) ->
                     List.to_seq rect_sides
                     |> take
                          (match rect_side_vert with
                          | Down -> rect_id + 1
                          | Up -> rect_id + 2)
                     |> map (fun (rect, _) ->
                            intersect_line_rect (x, y) goal rect)
                     |> fold_left
                          (fun no_intersects this_intersects ->
                            no_intersects && not this_intersects)
                          true)
              |> find_mapi (fun id no_intersects ->
                     if no_intersects then Some id else None)
          in
          match rect_to_jump with
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
          | None ->
              let (u, v), (u', v') =
                match side with
                | Left -> left next_rect
                | Right -> right next_rect
              in
              if u = u' && v = v' then
                walk_along fast_path (u', v') (x', y') xs
                |> Option.map (fun l -> (u', v') :: l)
              else if (u != u' && v = v') || (u = v' && v > v') then None
              else
                walk_along fast_path (u', v') (x', y') xs
                |> Option.map (( @ ) [ (u, v); (u', v') ]))
  in
  let rec combinations = function
    | [] -> []
    | [ rect ] -> [ [ (rect, Left) ]; [ (rect, Right) ] ]
    | rect :: xs ->
        let xs_combinations = combinations xs in
        List.map (( @ ) [ (rect, Left) ]) xs_combinations
        @ List.map (( @ ) [ (rect, Right) ]) xs_combinations
  in
  let update_shortest_path new_path =
    let open Option in
    let new_dist = calc_dist new_path in
    if
      !shortest_dist |> is_none
      || bind !shortest_dist (fun old_dist ->
             if new_dist < old_dist then Some () else None)
         |> is_some
    then (
      shortest_dist := Some new_dist;
      shortest_path := Some new_path)
  in
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
  soln.path |> print_list (fun { x; y } -> Printf.sprintf "(%d,%d)" x y) "p";
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

generate_desmos
  {
    goal = 48;
    rects =
      [
        { x = -18; y = 31; width = 22; height = 8 };
        { x = -6; y = 10; width = 22; height = 8 };
      ];
  }
