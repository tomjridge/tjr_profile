(** Profile pretty printing; don't use directly *)

open Util


let head = 
  " Total time | wp1 | wp2 | count | Unit cost" |> String.split_on_char '|'

let print_profile_summary ?(print_header="(unnamed profiler)") ~marks
    ~mark_to_string () 
  =
  let module A = struct

    let tbl = Hashtbl.create 100

    (* traverse the marks, recording the time deltas *)
    let _ = 
      marks |> iter_k (fun ~k marks ->           
          match marks with 
          | [] -> ()
          | [_] -> ()
          | (w2,t2)::(w1,t1)::marks ->
            let delta = t2 - t1 in
            let (count,time) = 
              Hashtbl.find_opt tbl (w1,w2) |> function
              | None -> (0,0)
              | Some x -> x
            in
            Hashtbl.replace tbl (w1,w2) (count+1,time+delta);
            k ((w1,t1)::marks))

    let f ((m1,m2),(c,t)) = t [@@ocaml.warning "-27"]

    let cmp e1 e2 = Pervasives.compare (f e1) (f e2)

    let bindings = 
      tbl |> Hashtbl.to_seq 
      |> List.of_seq
      |> List.sort cmp

    let _ = 
      match bindings with
      | [] -> 
        Printf.printf 
          "%s: No profiling data available!\n%!"
          print_header
      | _ -> 
        let f e = e |> fun ((w1,w2),(count,time)) -> 
                  Printf.sprintf " %11d | %3s | %3s | %8d | %9d " 
                    time 
                    (mark_to_string w1) 
                    (mark_to_string w2) 
                    count
                    (time / count)
                  |> String.split_on_char '|'
        in
        let csv = head::(bindings |> List.map f) in
        (if print_header <> "" then print_endline print_header);
        pp_csv csv
  end
  in
  ()

let _ 
: ?print_header:string ->
marks:('a * int) list -> mark_to_string:('a -> string) -> unit -> unit
= print_profile_summary
