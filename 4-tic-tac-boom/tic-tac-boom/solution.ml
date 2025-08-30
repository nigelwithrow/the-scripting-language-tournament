module Game = struct
  type nzuint = One | S of nzuint

  let four = S (S (S One))

  type cell = E | O of nzuint | X of nzuint

  let string_of_cell = function E -> ' ' | O _ -> 'o' | X _ -> 'x'

  type board = cell Array.t

  let string_of_board board =
    board |> Array.to_seq |> Seq.map string_of_cell |> String.of_seq

  type t = { board : board; mutable str : string }

  let empty =
    { board = Seq.repeat E |> Seq.take 9 |> Array.of_seq; str = "         " }

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

module Strategy = struct
  open Game

  let match3 board (a, b, c) =
    let permutations = [
      (0,1,2); (0,2,1); (1,0,2); (1,2,0); (2,0,1); (2,1,0);
      (3,4,5); (3,5,4); (4,3,5); (4,5,3); (5,3,4); (5,4,3);
      (6,7,8); (6,8,7); (7,6,8); (7,8,6); (8,6,7); (8,7,6);
      (0,3,6); (0,6,3); (3,0,6); (3,6,0); (6,0,3); (6,3,0);
      (1,4,7); (1,7,4); (4,1,7); (4,7,1); (7,1,4); (7,4,1);
      (2,5,8); (2,8,5); (5,2,8); (5,8,2); (8,2,5); (8,5,2);
      (0,4,8); (0,8,4); (4,0,8); (4,8,0); (8,0,4); (8,4,0); 
      (2,4,6); (2,6,4); (4,2,6); (4,6,2); (6,2,4); (6,4,2); 
    ] [@@ocamlformat "disable"] in
    permutations
    |> List.find_map (fun (a', b', c') ->
           if a board.(a') && b board.(b') && c board.(c') then Some (a', b', c)
           else None)

  type t = cell array -> int option

  let win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function O (S _) -> true | _ -> false),
        function O (S _) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  let dont_lose board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function X (S _) -> true | _ -> false),
        function X (S _) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  let dont_get_trapped board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function O (S One) -> true | _ -> false),
        function X (S (S _)) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  let prepare_win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    match3 board
      ( (function E -> true | _ -> false),
        (function E | X One -> true | _ -> false),
        function O (S (S _)) -> true | _ -> false )
    |> Option.map (fun (empty, _, _) -> empty)

  let find_empty board =
    let rec find_empty index =
      let index = index mod 9 in
      match board.(index) with E -> index | _ -> find_empty (index + 4)
    in
    Some (find_empty 0)
end

open Game

let detect_x_move s s' =
  let open Seq in
  zip (String.to_seq s) (String.to_seq s')
  |> find_mapi (fun i (c, c') ->
         let open Char in
         if
           equal (lowercase_ascii c') 'x' && not (equal (lowercase_ascii c) 'x')
         then Some i
         else None)

let game = empty

let move (str' : string) : int =
  let x_move =
    match detect_x_move game.str str' with
    | Some v -> v
    | None -> raise @@ Failure "X didn't play a move"
  in
  move_x x_move game;
  tick_x game;
  let o_move =
    let open Strategy in
    [ win; dont_lose; dont_get_trapped; prepare_win; find_empty ]
    |> List.find_map (fun strat -> strat game.board)
    |> Option.get
  in
  move_o o_move game;
  tick_o game;
  game.str <- string_of_board game.board;
  o_move

let _ = Callback.register "move" move
