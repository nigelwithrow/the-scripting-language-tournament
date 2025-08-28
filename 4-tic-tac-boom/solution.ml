module Board = struct
  type nzint = One | S of nzint

  let four = S (S (S One))

  type cell = E | O of nzint | X of nzint
  type b = cell Array.t
  type t = { mutable str : string; board : b }

  let empty =
    { str = "         "; board = Seq.repeat E |> Seq.take 9 |> Array.of_seq }

  let tick_cell = function
    | E | O One | X One -> E
    | O (S n) -> O n
    | X (S n) -> X n

  let string_of_cell = function E -> ' ' | O _ -> 'o' | X _ -> 'x'

  let string_of_board board =
    board |> Array.to_seq |> Seq.map string_of_cell |> String.of_seq

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

  let transpose3x3i = function
    | (0 | 4 | 8) as v -> v
    | 1 -> 3
    | 3 -> 1
    | 2 -> 6
    | 6 -> 2
    | 5 -> 7
    | 7 -> 5
    | n ->
        raise @@ Failure (Printf.sprintf "%d not valid element in 3x3 table" n)

  let transpose3x3 = function
    | [ b0; b1; b2; b3; b4; b5; b6; b7; b8 ] ->
        [ b0; b3; b6; b1; b4; b7; b2; b5; b8 ]
    | l ->
        raise
        @@ Failure
             (Printf.sprintf "table not 3x3=9 elements but %d" @@ List.length l)
end

module Strategy = struct
  open Board

  type strat =
    Board.b ->
    (*Some (o's next move) or None i.e. strategy failed*)
    int option

  (* Nah I'd win *)
  let strat_win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    let board = Array.to_list board in
    let next board =
      let open Board in
      try
        Some
          (match board with
          | [ E; O (S _); O (S _); _; _; _; _; _; _ ] -> 0
          | [ O (S _); E; O (S _); _; _; _; _; _; _ ] -> 1
          | [ O (S _); O (S _); E; _; _; _; _; _; _ ] -> 2
          | [ _; _; _; E; O (S _); O (S _); _; _; _ ] -> 3
          | [ _; _; _; O (S _); E; O (S _); _; _; _ ] -> 4
          | [ _; _; _; O (S _); O (S _); E; _; _; _ ] -> 5
          | [ _; _; _; _; _; _; E; O (S _); O (S _) ] -> 6
          | [ _; _; _; _; _; _; O (S _); E; O (S _) ] -> 7
          | [ _; _; _; _; _; _; O (S _); O (S _); E ] -> 8
          | [ E; _; _; _; O (S _); _; _; _; O (S _) ] -> 0
          | [ O (S _); _; _; _; E; _; _; _; O (S _) ] -> 4
          | [ O (S _); _; _; _; O (S _); _; _; _; E ] -> 8
          | [ _; _; E; _; O (S _); _; O (S _); _; _ ] -> 2
          | [ _; _; O (S _); _; E; _; O (S _); _; _ ] -> 4
          | [ _; _; O (S _); _; O (S _); _; E; _; _ ] -> 6
          | [ _; _; _; _; _; _; _; _; _ ] -> raise Exit
          | _ -> raise Exit (* unreachable, checked above *))
      with Exit -> None
    in
    match next board with
    | Some v -> Some v
    | None -> (
        match next (transpose3x3 board) with
        | Some v -> Some (transpose3x3i v)
        | None -> None)

  let strat_dont_lose : strat =
   fun board ->
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    let board = Array.to_list board in
    let next board =
      let open Board in
      try
        Some
          (match board with
          | [ E; X (S _); X (S _); _; _; _; _; _; _ ] -> 0
          | [ X (S _); E; X (S _); _; _; _; _; _; _ ] -> 1
          | [ X (S _); X (S _); E; _; _; _; _; _; _ ] -> 2
          | [ _; _; _; E; X (S _); X (S _); _; _; _ ] -> 3
          | [ _; _; _; X (S _); E; X (S _); _; _; _ ] -> 4
          | [ _; _; _; X (S _); X (S _); E; _; _; _ ] -> 5
          | [ _; _; _; _; _; _; E; X (S _); X (S _) ] -> 6
          | [ _; _; _; _; _; _; X (S _); E; X (S _) ] -> 7
          | [ _; _; _; _; _; _; X (S _); X (S _); E ] -> 8
          | [ E; _; _; _; X (S _); _; _; _; X (S _) ] -> 0
          | [ X (S _); _; _; _; E; _; _; _; X (S _) ] -> 4
          | [ X (S _); _; _; _; X (S _); _; _; _; E ] -> 8
          | [ _; _; E; _; X (S _); _; X (S _); _; _ ] -> 2
          | [ _; _; X (S _); _; E; _; X (S _); _; _ ] -> 4
          | [ _; _; X (S _); _; X (S _); _; E; _; _ ] -> 6
          | [ _; _; _; _; _; _; _; _; _ ] -> raise Exit
          | _ -> raise Exit (* unreachable, checked above *))
      with Exit -> None
    in
    match next board with
    | Some v -> Some v
    | None -> (
        match next (transpose3x3 board) with
        | Some v -> Some (transpose3x3i v)
        | None -> None)

  let strat_dont_get_trapped : strat =
   fun board ->
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    let board = Array.to_list board in
    let next board =
      let open Board in
      try
        Some
          (match board with
          | [ E; O (S One); X (S (S _)); _; _; _; _; _; _ ] -> 0
          | [ E; X (S (S _)); O (S One); _; _; _; _; _; _ ] -> 0
          | [ O (S One); E; X (S (S _)); _; _; _; _; _; _ ] -> 1
          | [ X (S (S _)); E; O (S One); _; _; _; _; _; _ ] -> 1
          | [ O (S One); X (S (S _)); E; _; _; _; _; _; _ ] -> 2
          | [ X (S (S _)); O (S One); E; _; _; _; _; _; _ ] -> 2
          | [ _; _; _; E; O (S One); X (S (S _)); _; _; _ ] -> 3
          | [ _; _; _; E; X (S (S _)); O (S One); _; _; _ ] -> 3
          | [ _; _; _; O (S One); E; X (S (S _)); _; _; _ ] -> 4
          | [ _; _; _; X (S (S _)); E; O (S One); _; _; _ ] -> 4
          | [ _; _; _; O (S One); X (S (S _)); E; _; _; _ ] -> 5
          | [ _; _; _; X (S (S _)); O (S One); E; _; _; _ ] -> 5
          | [ _; _; _; _; _; _; E; O (S One); X (S (S _)) ] -> 6
          | [ _; _; _; _; _; _; E; X (S (S _)); O (S One) ] -> 6
          | [ _; _; _; _; _; _; O (S One); E; X (S (S _)) ] -> 7
          | [ _; _; _; _; _; _; X (S (S _)); E; O (S One) ] -> 7
          | [ _; _; _; _; _; _; O (S One); X (S (S _)); E ] -> 8
          | [ _; _; _; _; _; _; X (S (S _)); O (S One); E ] -> 8
          | [ E; _; _; _; O (S One); _; _; _; X (S (S _)) ] -> 0
          | [ E; _; _; _; X (S (S _)); _; _; _; O (S One) ] -> 0
          | [ O (S One); _; _; _; E; _; _; _; X (S (S _)) ] -> 4
          | [ X (S (S _)); _; _; _; E; _; _; _; O (S One) ] -> 4
          | [ O (S One); _; _; _; X (S (S _)); _; _; _; E ] -> 8
          | [ X (S (S _)); _; _; _; O (S One); _; _; _; E ] -> 8
          | [ _; _; E; _; O (S One); _; X (S (S _)); _; _ ] -> 2
          | [ _; _; E; _; X (S (S _)); _; O (S One); _; _ ] -> 2
          | [ _; _; O (S One); _; E; _; X (S (S _)); _; _ ] -> 4
          | [ _; _; X (S (S _)); _; E; _; O (S One); _; _ ] -> 4
          | [ _; _; O (S One); _; X (S (S _)); _; E; _; _ ] -> 6
          | [ _; _; X (S (S _)); _; O (S One); _; E; _; _ ] -> 6
          | [ _; _; _; _; _; _; _; _; _ ] -> raise Exit
          | _ -> raise Exit (* unreachable, checked above *))
      with Exit -> None
    in
    match next board with
    | Some v -> Some v
    | None -> (
        match next (transpose3x3 board) with
        | Some v -> Some (transpose3x3i v)
        | None -> None)

  let strat_prepare_win board =
    if Array.length board != 9 then raise @@ Failure "board not length 9";
    let board = Array.to_list board in
    let next board =
      let open Board in
      try
        Some
          (match board with
          | [ E; (E | X One); O (S (S _)); _; _; _; _; _; _ ] -> 0
          | [ E; O (S (S _)); (E | X One); _; _; _; _; _; _ ] -> 0
          | [ X One; E; O (S (S _)); _; _; _; _; _; _ ] -> 1
          | [ O (S (S _)); E; (E | X One); _; _; _; _; _; _ ] -> 1
          | [ X One; O (S (S _)); E; _; _; _; _; _; _ ] -> 2
          | [ O (S (S _)); X One; E; _; _; _; _; _; _ ] -> 2
          | [ _; _; _; E; (E | X One); O (S (S _)); _; _; _ ] -> 3
          | [ _; _; _; E; O (S (S _)); (E | X One); _; _; _ ] -> 3
          | [ _; _; _; X One; E; O (S (S _)); _; _; _ ] -> 4
          | [ _; _; _; O (S (S _)); E; (E | X One); _; _; _ ] -> 4
          | [ _; _; _; X One; O (S (S _)); E; _; _; _ ] -> 5
          | [ _; _; _; O (S (S _)); X One; E; _; _; _ ] -> 5
          | [ _; _; _; _; _; _; E; (E | X One); O (S (S _)) ] -> 6
          | [ _; _; _; _; _; _; E; O (S (S _)); (E | X One) ] -> 6
          | [ _; _; _; _; _; _; X One; E; O (S (S _)) ] -> 7
          | [ _; _; _; _; _; _; O (S (S _)); E; (E | X One) ] -> 7
          | [ _; _; _; _; _; _; X One; O (S (S _)); E ] -> 8
          | [ _; _; _; _; _; _; O (S (S _)); X One; E ] -> 8
          | [ E; _; _; _; (E | X One); _; _; _; O (S (S _)) ] -> 0
          | [ E; _; _; _; O (S (S _)); _; _; _; (E | X One) ] -> 0
          | [ X One; _; _; _; E; _; _; _; O (S (S _)) ] -> 4
          | [ O (S (S _)); _; _; _; E; _; _; _; (E | X One) ] -> 4
          | [ X One; _; _; _; O (S (S _)); _; _; _; E ] -> 8
          | [ O (S (S _)); _; _; _; X One; _; _; _; E ] -> 8
          | [ _; _; _; _; _; _; _; _; _ ] -> raise Exit
          | _ -> raise Exit (* unreachable, checked above *))
      with Exit -> None
    in
    match next board with
    | Some v -> Some v
    | None -> (
        match next (transpose3x3 board) with
        | Some v -> Some (transpose3x3i v)
        | None -> None)

  let strat_find_empty : strat =
   fun board ->
    let rec find_empty index =
      let index = index mod 9 in
      match board.(index) with E -> index | _ -> find_empty (index + 4)
    in
    Some (find_empty 0)
end

open Board

let detect_x_move s s' =
  let open Seq in
  zip (String.to_seq s) (String.to_seq s')
  |> find_mapi (fun i (c, c') ->
         let open Char in
         if
           equal (lowercase_ascii c') 'x' && not (equal (lowercase_ascii c) 'x')
         then Some i
         else None)

let disp str =
  Printf.printf ">>>> %s\n"
    (String.map (fun c -> if Char.equal c ' ' then '.' else c) str);
  flush stdout

let game = empty

let move (str' : string) : int =
  let x_move =
    match detect_x_move game.str str' with
    | Some v -> v
    | None -> raise @@ Failure "X didn't play a move"
  in
  Printf.printf "x's move: %d\n" x_move;
  flush stdout;
  move_x x_move game;
  tick_x game;
  game.str <- string_of_board game.board;
  disp game.str;
  let o_move =
    let open Strategy in
    [
      ("win", strat_win);
      ("dont lose", strat_dont_lose);
      ("dont get trapped", strat_dont_get_trapped);
      ("prepare to win", strat_prepare_win);
      ("find empty", strat_find_empty);
    ]
    |> List.find_map (fun (strat_name, strat) ->
           strat game.board
           |> Option.map (fun a ->
                  Printf.printf "chosen strategy `%s`, move `%d`\n" strat_name a;
                  flush stdout;
                  a))
    |> Option.get
  in
  Printf.printf "o's move: %d\n" o_move;
  flush stdout;
  move_o o_move game;
  tick_o game;
  game.str <- string_of_board game.board;
  o_move

let _ = Callback.register "move" move
