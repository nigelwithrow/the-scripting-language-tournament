(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 4 - Tic Tac Boom
  Date: 28th August 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + Have system-wide Rust & Cargo installation
  + `$ cd 4-tic-tac-boom`
  + `$ nix develop`
  + `$ just tic-tac-boom`
  + `$ ./target/release/tic-tac-boom ./solution.ml`
*)

module Game = struct
  (*
    Inductive definition of non-zero unsigned integer
    Used for better pattern matching on X and O's remaining lifespan
  *)
  type nzuint = One | S of nzuint

  (* Every spawned X or O lives for 4 rounds (game tick happens right after
     spawning) *)
  let four = S (S (S One))

  (* Empty or O or X *)
  type cell = E | O of nzuint | X of nzuint

  let string_of_cell = function E -> ' ' | O _ -> 'o' | X _ -> 'x'

  (* Game board *)
  type board = cell Array.t

  let string_of_board board =
    board |> Array.to_seq |> Seq.map string_of_cell |> String.of_seq

  (* Board and its string representation used for diff'ing with input *)
  type t = { board : board; mutable str : string }

  let empty =
    { board = Seq.repeat E |> Seq.take 9 |> Array.of_seq; str = "         " }

  (*
    Tick lifespan of Xs and Os
  *)
  let tick_x self : unit =
    Array.iteri
      (fun i cell ->
        self.board.(i) <-
          (match cell with E -> E | X One -> E | X (S n) -> X n | O n -> O n))
      self.board

  let tick_o self =
    Array.iteri
      (fun i cell ->
        self.board.(i) <-
          (match cell with E -> E | O One -> E | O (S n) -> O n | X n -> X n))
      self.board

  (*
    Add moves from X and O
  *)
  let move_x i self =
    (match self.board.(i) with
    | E -> ()
    | _ -> raise @@ Failure "X trying to play at occupied space");
    self.board.(i) <- X four

  let move_o i self =
    (match self.board.(i) with
    | E -> ()
    | _ -> raise @@ Failure "O trying to play at occupied space");
    self.board.(i) <- O four
end

(*
  Strategies decided what move we should play
*)
module Strategy = struct
  open Game

  (*
    Match a provided 3-cell permutation to see if any of its combinations occurs
    on the game board, returning the indexes of the matched cells if matched
  *)
  let match3 board (a, b, c) =
    let permutations = [
      (* rows *)
      (0,1,2); (0,2,1); (1,0,2); (1,2,0); (2,0,1); (2,1,0);
      (3,4,5); (3,5,4); (4,3,5); (4,5,3); (5,3,4); (5,4,3);
      (6,7,8); (6,8,7); (7,6,8); (7,8,6); (8,6,7); (8,7,6);
      (* columns *)
      (0,3,6); (0,6,3); (3,0,6); (3,6,0); (6,0,3); (6,3,0);
      (1,4,7); (1,7,4); (4,1,7); (4,7,1); (7,1,4); (7,4,1);
      (2,5,8); (2,8,5); (5,2,8); (5,8,2); (8,2,5); (8,5,2);
      (* left diagonal *)
      (0,4,8); (0,8,4); (4,0,8); (4,8,0); (8,0,4); (8,4,0); 
      (* right diagonal *)
      (2,4,6); (2,6,4); (4,2,6); (4,6,2); (6,2,4); (6,4,2); 
    ] [@@ocamlformat "disable"] in
    permutations
    |> List.find_map (fun (a', b', c') ->
           if a board.(a') && b board.(b') && c board.(c') then Some (a', b', c')
           else None)

  type t = cell array -> int option

  (* The strategy to win if 2 Os of a row, column or diagonal found *)
  let win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function O (S _) -> true | _ -> false),
        function O (S _) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  (* The strategy to not lose if 2 Xs of a row, column or diagonal found *)
  let dont_lose board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function X (S _) -> true | _ -> false),
        function X (S _) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  (*
    The strategy to not get trapped into this particular situation by the
    opponent:

    2 Xs of a row, column or diagonal where the third is a O but after your turn
    that O will vanish
  *)
  let dont_get_trapped board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function O (S One) -> true | _ -> false),
        function X (S (S _)) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  (* The strategy to make progress by filling 2 places of a row, column or a
     diagonal, where the 3rd is either empty or will be empty soon *)
  let prepare_win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function E | X One -> true | _ -> false),
        function O (S (S _)) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  (* The strategy when no other strategies are applicable, i.e., to just pick
     some arbitrarily interesting free cell *)
  let find_empty board =
    let rec find_empty index =
      let index = index mod 9 in
      match board.(index) with E -> index | _ -> find_empty (index + 4)
    in
    Some (find_empty 0)
end

open Game

(* diff current board with input from opponent to get X's new move *)
let detect_x_move s s' =
  let open Seq in
  zip (String.to_seq s) (String.to_seq s')
  |> find_mapi (fun i (c, c') ->
         let open Char in
         if
           equal (lowercase_ascii c') 'x' && not (equal (lowercase_ascii c) 'x')
         then Some i
         else None)

(* Start empty game *)
let game = empty

let move (str' : string) : int =
  let x_move =
    match detect_x_move game.str str' with
    | Some v -> v
    | None -> raise @@ Failure "X didn't play a move"
  in
  (* X's move *)
  move_x x_move game;
  tick_x game;
  let o_move =
    let open Strategy in
    (* Get the first strategy in order of descending priority that applies *)
    [ win; dont_lose; dont_get_trapped; prepare_win; find_empty ]
    |> List.find_map (fun strat -> strat game.board)
    (* The last strategy always applies so this never fails *)
    |> Option.get
  in
  (* O's move *)
  move_o o_move game;
  tick_o game;
  (* Save game string to be able to diff next round *)
  game.str <- string_of_board game.board;
  (* Return O's move to opponent *)
  o_move

(* C interop poggers *)
let _ = Callback.register "move" move
