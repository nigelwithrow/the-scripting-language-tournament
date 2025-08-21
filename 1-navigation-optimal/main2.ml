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

module Graph = struct
  type edge = { pair : int * int; weight : float }

  type 'a t = {
    node_seq : 'a list;
    node_exist : ('a, int) Hashtbl.t;
    node_edges : (*edge id*) int list Array.t;
    edge_seq : edge list;
  }

  let init node_seq =
    let open Seq in
    let count = length node_seq in
    {
      node_seq = List.of_seq node_seq;
      node_exist = Hashtbl.of_seq @@ mapi (fun i node -> (node, i)) node_seq;
      node_edges = Array.init count (fun _ -> []);
      edge_seq = [];
    }

  let add_edge a b weight graph =
    let open Option in
    let open Hashtbl in
    let fail =
      Assert_failure
        ("start & goal should be different nodes existing in the graph", 0, 0)
    in
    if a = b then raise fail;
    match (find_opt graph.node_exist a, find_opt graph.node_exist b) with
    | Some a_id, Some b_id ->
        let edge = { pair = (a_id, b_id); weight } in
        let edge_id = List.length graph.edge_seq in
        let replace id =
          graph.node_edges.(id) <- edge_id :: graph.node_edges.(id)
        in
        replace a_id;
        replace b_id;
        { graph with edge_seq = edge :: graph.edge_seq }
    | _ -> raise fail

  let neighbors node graph =
    let open Option in
    let open Hashtbl in
    find_opt graph.node_exist node
    |> map (fun node ->
           graph.node_edges.(node) |> List.map (List.nth graph.edge_seq))

  let dfs_min_lightest_path start goal graph =
    let open Hashtbl in
    let open Option in
    match (find_opt graph.node_exist start, find_opt graph.node_exist goal) with
    | Some start, Some goal ->
        let visited =
          Array.init (List.length graph.node_seq) (fun _ -> false)
        in
        let min_path = None in
        let rec dfs_rec s path =
          if s = goal then path else visited.(s) <- true;
          graph.node_edges.(s)
          |> List.map (fun neighbor ->
                 if not visited.(neighbor) then dfs_rec neighbor path else [])
        in
        dfs_rec start []
    | _ ->
        raise
        @@ Assert_failure
             ( "start & goal should be different nodes existing in the graph",
               0,
               0 )
end

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
  if m = 0. then
    (* line is paralell to x-axis *)
    y >= rect_base_y && y <= rect_top_y
  else if is_infinite m then
    (* line is paralell to y-axis *)
    x > rect.x && x < rect.x + rect.width
  else
    (* mantissa of the line at the level of the base and top of the rectangle
       respectively *)
    let line_x_min, line_x_max =
      min_max
        (div (sub (of_int rect_base_y) c) m)
        (div (sub (of_int rect_top_y) c) m)
    in
    line_x_max > of_int rect.x && line_x_min < of_int (rect.x + rect.width)

(* Calculates the distance of the path represented by the given coordinates *)
let rec calc_dist = function
  | [] | [ _ ] -> 0.
  | (x, y) :: ((x', y') as new_head) :: xs ->
      let open Float in
      let x, x', y, y' = (of_int x, of_int x', of_int y, of_int y') in
      sqrt (add (pow (sub y' y) 2.) (pow (sub x' x) 2.))
      |> add (calc_dist @@ (new_head :: xs))

let graph_of_input (input : input) =
  let open List in
  let rect_corners =
    input.rects
    |> map (fun { x; y; width; height } ->
           [ (x, y); (x, y + height); (x + width, y); (x + width, y + height) ])
    |> flatten
  in
  let nodes = [ (0, 0); (0, input.goal) ] @ rect_corners in
  let graph = ref @@ Graph.init @@ List.to_seq nodes in
  for i = 0 to length nodes - 1 do
    let a = nth nodes i in
    for j = i + 1 to length nodes - 1 do
      let b = nth nodes j in
      let valid_edge =
        input.rects
        |> fold_left
             (fun no_intersects rect ->
               if no_intersects then not (intersect_line_rect a b rect)
               else false)
             true
      in
      if valid_edge then graph := Graph.add_edge a b (calc_dist [ a; b ]) !graph
    done
  done;
  (* !edges
  |> iter (fun { nodes = (ax, ay), (bx, by); distance } ->
         Printf.printf "(%d, %d) ---%f--> (%d, %d)\n" ax ay distance bx by); *)
  graph

let dfs_shortest_path (graph : (int * int) Graph.t) start goal =
  let open Hashtbl in
  let open Option in
  if
    (is_none @@ find_opt graph.nodes start)
    || (is_none @@ find_opt graph.nodes goal)
  then raise @@ Assert_failure ("start and goal should be in graph", 0, 0);
  let dfs' _ = _ in
  dfs' graph.edges
;;

let graph =
  graph_of_input
    {
      goal = 48;
      rects =
        [
          { x = -18; y = 31; width = 22; height = 8 };
          { x = -6; y = 10; width = 22; height = 8 };
        ];
    }
in
dfs_shortest_path graph
(*
  NOTE: Solution
*)
(* let solve input : output = _ *)
