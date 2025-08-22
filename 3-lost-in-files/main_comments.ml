exception Found of string

let rec safe f a = try f a with Unix.Unix_error (Unix.EINTR, _, _) -> safe f a

(*
  Kind of source to uncompress & unarchive, i.e.
  `Fd` when from a Unix file-descriptor, and
  `Mem` when from an in-memory bytestring
*)
type source =
  | Fd of Unix.file_descr
  | Mem of { buf : bytes; mutable cursor : int }

let rec run' : type a. source -> (a, _, _) Tar.t -> a =
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
      | Mem mem ->
          let l = Bytes.length mem.buf in
          if mem.cursor >= l - 1 then raise End_of_file;
          let read =
            if len <= l - mem.cursor then
              Bytes.sub_string mem.buf mem.cursor len
            else Bytes.unsafe_to_string mem.buf
          in
          mem.cursor <- mem.cursor + len;
          read)
  | Tar.Really_read len -> (
      match src with
      | Fd fd ->
          let rec loop fd buf offset len =
            if offset < (len : int) then
              let n = safe (Unix.read fd buf offset) (len - offset) in
              if n = 0 then raise End_of_file else loop fd buf (offset + n) len
          in
          let buf = Bytes.create len in
          loop fd buf 0 len;
          Bytes.unsafe_to_string buf
      | Mem mem ->
          let l = Bytes.length mem.buf in
          if mem.cursor >= l - 1 then raise End_of_file;
          let read =
            if len <= l - mem.cursor then
              Bytes.sub_string mem.buf mem.cursor len
            else Bytes.unsafe_to_string mem.buf
          in
          mem.cursor <- mem.cursor + len;
          read)
  | Tar.Seek len -> (
      match src with
      | Fd fd -> ignore (safe (Unix.lseek fd len) Unix.SEEK_CUR)
      | Mem mem -> mem.cursor <- mem.cursor + len)
  | Tar.Return (Ok x) -> x
  | Tar.Return (Error err) -> (
      match err with _ -> failwith "something's gone wrong")
  | Tar.High _ -> assert false
  | Tar.Bind (x, f) -> run' src (f (run' src x))

let run t fd = run' fd t

let occurs pat str =
  let open Seq in
  let rec occurs' = function
    | Nil, _ -> true
    | Cons (px, pxs), Nil -> false
    | (Cons (px, pxs) as pat), Cons (sx, sxs) ->
        if Char.equal px sx then
          (* increment str & pattern *)
          occurs' (pxs (), sxs ())
        else
          (* increment only str *)
          occurs' (pat, sxs ())
  in
  let open String in
  occurs' (to_seq pat (), to_seq str ())

let rec thing () =
  Tar_gz.in_gzipped
    (Tar.fold
       (fun ?global:_ hdr () ->
         Tar.bind
           (Tar.really_read (Int64.to_int hdr.Tar.Header.file_size))
           (fun content ->
             (if occurs "Answer: " content then raise (Found content)
              else
                try
                  run (thing ())
                    (Mem { buf = Bytes.of_string content; cursor = 0 })
                with
                | Failure _ -> ()
                | End_of_file -> ());
             Tar.return (Ok ())))
       ())
;;

run (thing ())
  (Fd
     (Unix.openfile "/home/admin1234/Downloads/root.tar.gz.tar"
        [ Unix.O_RDONLY ] 0))

(* Printf.printf "%s\n" *)
(* @@ Option.fold ~none:"<none>" ~some:(fun c -> string_of_int c) count *)

(* let _ =
  let file = open_in "/home/admin1234/Downloads/root.tar.gz.tar" in
  let source = ref "" in
  while
    try
      source := !source ^ input_line file ^ "\n";
      true
    with End_of_file -> false
  do
    ()
  done;
  run (thing ()) (Mem { buf = Bytes.of_string !source; cursor = 0 }) *)

(* Printf.printf "%s\n" *)
(* @@ Option.fold ~none:"<none>" ~some:(fun c -> string_of_int c) count *)

(*https://github.com/kit-ty-kate/ocaml-tar-playground/blob/b8883a2b3d54040a943f268ae10af710ce9aafed/test.ml*)

(* let rec run' : type a. Unix.file_descr -> (a, _, _) Tar.t -> a =
 fun fd -> function
  | Tar.Write str ->
      ignore (safe (Unix.write_substring fd str 0) (String.length str))
  | Tar.Read len ->
      let b = Bytes.create len in
      let read = safe (Unix.read fd b 0) len in
      if read = 0 then failwith "Unexpected_end_of_file"
      else if len = (read : int) then Bytes.unsafe_to_string b
      else Bytes.sub_string b 0 read
  | Tar.Really_read len ->
      let rec loop fd buf offset len =
        if offset < (len : int) then
          let n = safe (Unix.read fd buf offset) (len - offset) in
          if n = 0 then failwith "Unexpected_end_of_file"
          else loop fd buf (offset + n) len
      in
      let buf = Bytes.create len in
      loop fd buf 0 len;
      Bytes.unsafe_to_string buf
  | Tar.Seek len -> ignore (safe (Unix.lseek fd len) Unix.SEEK_CUR)
  | Tar.Return (Ok x) -> x
  | Tar.Return (Error _) -> failwith "something's gone wrong"
  | Tar.High _ -> assert false
  | Tar.Bind (x, f) -> run' fd (f (run' fd x))

let run t fd = run' fd t *)

(* let rec safe f a = try f a with Unix.Unix_error (Unix.EINTR, _, _) -> safe f a

let run t fd =
  let rec run : type a. (a, _, _) Tar.t -> a = function
    | Tar.Write str ->
        ignore (safe (Unix.write_substring fd str 0) (String.length str))
    | Tar.Read len ->
        let b = Bytes.create len in
        let read = safe (Unix.read fd b 0) len in
        if read = 0 then failwith "Unexpected_end_of_file"
        else if len = (read : int) then Bytes.unsafe_to_string b
        else Bytes.sub_string b 0 read
    | Tar.Really_read len ->
        let rec loop fd buf offset len =
          if offset < (len : int) then
            let n = safe (Unix.read fd buf offset) (len - offset) in
            if n = 0 then failwith "Unexpected_end_of_file"
            else loop fd buf (offset + n) len
        in
        let buf = Bytes.create len in
        loop fd buf 0 len;
        Bytes.unsafe_to_string buf
    | Tar.Seek len -> ignore (safe (Unix.lseek fd len) Unix.SEEK_CUR)
    | Tar.Return (Ok x) -> x
    | Tar.Return (Error _) -> failwith "something's gone wrong"
    | Tar.High _ -> assert false
    | Tar.Bind (x, f) -> run (f (run x))
  in
  run t

let list fd =
  let go ?global:_ hdr () =
    Tar.bind
      (Tar.really_read (Int64.to_int hdr.Tar.Header.file_size))
      (fun content ->
        print_endline content;
        Tar.return (Ok ()))
  in
  run (Tar_gz.in_gzipped (Tar.fold go ())) fd

let () =
  let filename = Sys.argv.(1) in
  let fd = Unix.openfile filename [ Unix.O_RDONLY ] 0 in
  list fd *)
