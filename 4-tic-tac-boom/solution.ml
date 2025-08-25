let move (board : string) : int =
  print_endline board;
  let rec find_empty index =
    if index >= 9 then 0
    else if board.[index] = ' ' then index
    else find_empty (index + 1)
  in
  find_empty 0

(* I give up making it link with C. You can figure it out on your own *)
