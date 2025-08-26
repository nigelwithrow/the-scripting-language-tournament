exception Found of string

type input = { filename : string }
type mem = { buf : bytes; mutable cursor : int }
type source = Fd of Unix.file_descr | Mem of mem

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

let occurs pat str =
  let pat = String.to_seq pat () in
  let open Seq in
  let rec occurs' = function
    | Nil, _ -> true
    | Cons _, Nil -> false
    | Cons (px, pxs), Cons (sx, sxs) ->
        if Char.equal px sx then occurs' (pxs (), sxs ()) else false
  in
  occurs' String.(pat, to_seq str ())

let rec algo () =
  Tar_gz.in_gzipped
    (Tar.fold
       (fun ?global:_ header () ->
         Tar.bind
           (Tar.really_read (Int64.to_int header.Tar.Header.file_size))
           (fun content ->
             if not (occurs ".tar.gz" header.file_name) then
               let occurred =
                 content |> String.split_on_char '\n'
                 |> List.find_map (fun line ->
                        if occurs "Answer: " line then Some line else None)
               in
               match occurred with
               | Some found -> raise (Found found)
               | None -> ()
             else
               run (algo ()) (Mem { buf = Bytes.of_string content; cursor = 0 });
             Tar.return (Ok ())))
       ())

let solve input =
  try
    run (algo ()) (Fd (Unix.openfile input.filename [ Unix.O_RDONLY ] 0));
    None
  with Found msg -> Some msg
;;

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
