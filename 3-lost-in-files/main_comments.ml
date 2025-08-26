(*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 3 - Lost in files
  Date: 23rd August 2025

  Entry:  OCaml
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ cd 3-lost-in-files`
  + `$ opam install .`
  + `$ dune build`
  + `$ ./_build/default/main.exe /path/to/archive.tar.gz`
*)

exception Found of string

type input = { filename : string }

(*
  Kind of `source` to uncompress & unarchive, i.e.
  | `Fd` when from a Unix file-descriptor, and
  | `Mem` when from an in-memory bytestring
*)
type mem = { buf : bytes; mutable cursor : int }
type source = Fd of Unix.file_descr | Mem of mem

(*
  Handler for the tar unarchiver from a source of type `source`

  Huge thanks to:
  https://github.com/kit-ty-kate/ocaml-tar-playground/blob/b8883a2b3d54040a943f268ae10af710ce9aafed/test.ml
  for this function
*)
let run t fd =
  let rec run' : type a. source -> (a, _, _) Tar.t -> a =
    let rec safe f a =
      try f a with Unix.Unix_error (Unix.EINTR, _, _) -> safe f a
    in
    let common_mem_read len mem =
      let l = Bytes.length mem.buf in
      if mem.cursor >= l - 1 then raise End_of_file;
      let read =
        if len <= l - mem.cursor then Bytes.sub_string mem.buf mem.cursor len
        else Bytes.unsafe_to_string mem.buf
      in
      mem.cursor <- mem.cursor + len;
      read
    in
    fun src -> function
      | Tar.Write str -> (
          let open String in
          let strlen = length str in
          match src with
          | Fd fd -> ignore (safe (Unix.write_substring fd str 0) strlen)
          | Mem mem ->
              str |> iteri (fun i c -> Bytes.set mem.buf (mem.cursor + i) c);
              mem.cursor <- mem.cursor + strlen)
      | Tar.Read len -> (
          match src with
          | Fd fd ->
              let b = Bytes.create len in
              let read = safe (Unix.read fd b 0) len in
              if read = 0 then raise End_of_file
              else if len = (read : int) then Bytes.unsafe_to_string b
              else Bytes.sub_string b 0 read
          | Mem mem -> common_mem_read len mem)
      | Tar.Really_read len -> (
          match src with
          | Fd fd ->
              let rec loop fd buf offset len =
                if offset < (len : int) then
                  let n = safe (Unix.read fd buf offset) (len - offset) in
                  if n = 0 then raise End_of_file
                  else loop fd buf (offset + n) len
              in
              let buf = Bytes.create len in
              loop fd buf 0 len;
              Bytes.unsafe_to_string buf
          | Mem mem -> common_mem_read len mem)
      | Tar.Seek len -> (
          match src with
          | Fd fd -> ignore (safe (Unix.lseek fd len) Unix.SEEK_CUR)
          | Mem mem -> mem.cursor <- mem.cursor + len)
      | Tar.Return (Ok x) -> x
      | Tar.Return (Error err) -> (
          match err with _ -> failwith "something's gone wrong")
      | Tar.High _ -> assert false
      | Tar.Bind (x, f) -> run' src (f (run' src x))
  in
  run' fd t

(* Find whether string `pat` occurs in another string `str` *)
let occurs pat str =
  let pat = String.to_seq pat () in
  let open Seq in
  let rec occurs' = function
    | Nil, _ -> true
    | Cons _, Nil -> false
    | Cons (px, pxs), Cons (sx, sxs) ->
        if Char.equal px sx then
          (* increment str & pattern *)
          occurs' (pxs (), sxs ())
        else
          (* increment str, reset pattern *)
          occurs' (pat, sxs ())
  in
  occurs' String.(pat, to_seq str ())

(*
  Algorithm to recursively try to uncompress & unarchive each entry of an
  uncompressed archive, as in-memory bytestrings
*)
let rec algo () =
  Tar_gz.in_gzipped
    (Tar.fold
       (fun ?global:_ header () ->
         Tar.bind
           (Tar.really_read (Int64.to_int header.Tar.Header.file_size))
           (fun content ->
             if not (occurs ".tar.gz" header.file_name) then
               (* Entry is not a nested archive; find occurrence of `Answer:` in
                  contents *)
               let occurred =
                 content
                 (* Split into lines *)
                 |> String.split_on_char '\n'
                 (* Find first line having the answer *)
                 |> List.find_map (fun line ->
                        if occurs "Answer: " line then Some line else None)
               in
               match occurred with
               (* Halt searching, answer was found *)
               | Some found -> raise (Found found)
               | None -> ()
             else
               (* Recurse: uncompress+unarchive contents of nested .tar.gz *)
               run (algo ()) (Mem { buf = Bytes.of_string content; cursor = 0 });
             Tar.return (Ok ())))
       ())

(* Solution *)
let solve input =
  try
    run (algo ()) (Fd (Unix.openfile input.filename [ Unix.O_RDONLY ] 0));
    None
  with Found msg -> Some msg
;;

(* Get CLI arguments *)
let filename =
  match Array.to_list Sys.argv with
  | [ _; v ] -> v
  | _ ->
      Printf.eprintf
        "Expecting argument for filename of compressed archive .tar.gz\n";
      exit 1
in
match solve { filename } with
| Some msg -> print_endline msg
| None -> Printf.eprintf "Error: No answer found\n"
