module Board = struct
  type nzint = | One | S of nzint

  type cell = E | O of nzint | X of nzint

  type b = cell ref list
  type b' = cell list

  type t = { str : string; board : b }

  let empty = { str = "         "; board = Seq.repeat (ref E) |> Seq.take 9 |> List.of_seq }

  let tick = _

  let move_x = _
  let move_o = _
end

let board = Board.empty;;

let iota: int Seq.t =
  let i = ref 0 in
  let rec iota' () = Seq.Cons (!i, fun () -> incr i; iota' ()) in
  iota'
;;

let detect_x_move s s' =
  Seq.zip (String.to_seq s) (String.to_seq s')
  |> Seq.zip iota
  |> Seq.find_map (fun (i, (c, c')) ->
    let open Char in
    if equal (lowercase_ascii c) 'x' && not (equal (lowercase_ascii c') 'x')
      then Some i
      else None)
;;

let move (str' : string) : int =
  let x_move = detect_x_move board.str str' in
  Board.move_x x_move board;
  Board.tick board;
  let o_move = 
    let rec find_empty index =
      if index >= 9 then 0
      else if board.[index] = ' ' then index
      else find_empty (index + 1)
    in
    find_empty 0
  in
  Board.move_o o_move board;
  Board.tick;
  o_move
;;

let _ = Callback.register "move" move

(* I give up making it link with C. You can figure it out on your own *)
