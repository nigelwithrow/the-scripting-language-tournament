type rect = { x : int; y : int; width : int; height : int }
type input = { goal : int; rects : rect list }
type coord = { x : int; y : int }
type output = { path : coord list; distance : float }

let origin = { x = 0; y = 0 }

let calc_dist { x; y } { x = x'; y = y' } =
  let open Float in
  let x, x', y, y' = (of_int x, of_int x', of_int y, of_int y') in
  sqrt (add (pow (sub y' y) 2.) (pow (sub x' x) 2.))

module Graph' = struct
  open Graph

  module G = struct
    module Coord = struct
      type t = coord

      let compare = Stdlib.compare
      let equal = ( = )
      let hash = Hashtbl.hash
    end

    module Float = struct
      type t = float

      let compare = Stdlib.compare
      let default = 0.
    end

    include Imperative.Graph.ConcreteLabeled (Coord) (Float)
  end

  module Dijkstra =
    Path.Dijkstra
      (G)
      (struct
        type edge = G.E.t
        type t = float

        let weight (a, _, b) = calc_dist a b
        let zero = 0.
        let add = Float.add
        let compare = Float.compare
      end)

  let create = G.create
  let add_vertex = G.add_vertex
  let add_edge = G.add_edge
  let shortest_path = Dijkstra.shortest_path
end

let intersect_line_rect { x; y } { x = x'; y = y' } (rect : rect) =
  if
    max x x' <= min rect.x (rect.x + rect.width)
    || min x x' >= max rect.x (rect.x + rect.width)
    || max y y' <= min rect.y (rect.y + rect.height)
    || min y y' >= max rect.y (rect.y + rect.height)
  then false
  else
    let open Float in
    let mx_plus_c_of_2_point (x, y) (x', y') =
      let m =
        (div @@ sub (of_int y') (of_int y)) @@ sub (of_int x') (of_int x)
      in
      let c = sub (of_int y) (mul (of_int x) m) in
      (m, c)
    in
    let rect_base_y = rect.y in
    let rect_top_y = rect.y + rect.height in
    let m, c = mx_plus_c_of_2_point (x, y) (x', y') in
    if m = 0. then y >= rect_base_y && y <= rect_top_y
    else if is_infinite m then x > rect.x && x < rect.x + rect.width
    else
      let line_x_base = div (sub (of_int rect_base_y) c) m in
      let line_x_top = div (sub (of_int rect_top_y) c) m in
      (line_x_base > of_int rect.x && line_x_base < of_int (rect.x + rect.width))
      || line_x_top > of_int rect.x
         && line_x_top < of_int (rect.x + rect.width)
      || line_x_base <= of_int rect.x
         && line_x_top >= of_int (rect.x + rect.width)
      || line_x_base >= of_int (rect.x + rect.width)
         && line_x_top <= of_int rect.x

let solve (input : input) : output =
  let open List in
  let open Graph' in
  let goal = { x = 0; y = input.goal } in
  let rect_corners =
    input.rects
    |> map (fun { x; y; width; height } ->
           [
             { x; y };
             { x; y = y + height };
             { x = x + width; y };
             { x = x + width; y = y + height };
           ])
    |> flatten
  in
  let vertices = [ origin; goal ] @ rect_corners in
  let graph = create () in
  vertices |> iter (add_vertex graph);
  for i = 0 to length vertices - 1 do
    let a = nth vertices i in
    for j = i + 1 to length vertices - 1 do
      let b = nth vertices j in
      let valid_edge =
        input.rects
        |> fold_left
             (fun no_intersects rect ->
               if no_intersects then not (intersect_line_rect a b rect)
               else false)
             true
      in
      if valid_edge then add_edge graph a b
    done
  done;
  let path, _ = shortest_path graph origin goal in
  {
    path =
      origin :: (path |> map (fun (_vertex_a, _edge_id, vertex_b) -> vertex_b));
    distance =
      path |> fold_left (fun sum (a, _, b) -> Float.add sum @@ calc_dist a b) 0.;
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
        { x = -6; y = 10; width = 102; height = 8 };
      ];
  }
