(** This version attempts to reduce computation and GC costs during
   the profiling (there may be substantial processing costs at the end
   to compute the summary).

 *)
open Optcomp_config
open Intf_

module Intern = Util.Intern

(** Make a profiler which uses an 2D array of ints to record
   marks. NOTE this is affected by optcomp config. *)
let make_profiler ?(print_header="") ?(cap=10_000_000) 
    ?(print_at_exit=true) () 
  =
  match profiling_enabled with
  | false -> Util.dummy_profiler
  | true -> 
    let module Internal = struct

      module A = Bigarray.Array2

      (* (n,0) holds the time; (n,1) holds the mark id *)
      let marks = 
        A.create
          Bigarray.Int
          Bigarray.c_layout
          cap
          2

      let ptr = ref 0  (* index into marks *)

      let already_warned = ref false

      let mark i = A.(
          let n = !ptr in
          try
            set marks n 0 (now());
            set marks n 1 i;
            ptr:=n+1
          with Invalid_argument _ -> 
            (if !already_warned then () else 
               Printf.printf "WARNING!!! %s: too many marks; profiling data will be incomplete" __LOC__;
             already_warned:=true)
            (* Profiling_exception "index out of range... too many marks" |> raise *)
        )

      let time_thunk m f =
        mark m;
        let r = f () in
        mark (-1*m); (* NOTE assume this mark is present *)
        r
        
      let get_marks () = 
        (* build a list, then call the standard print routine based on
           strings FIXME horribly inefficient *)
        (0,[]) |> iter_break (fun (p,xs) -> 
            match p >= !ptr with 
            | true -> Break xs
            | false -> 
              let (t,i) = A.(get marks p 0,get marks p 1) in
              Cont(p+1,(i,t)::xs))

      let print_summary () = 
        get_marks () |> fun marks -> 
        Pretty_print.print_profile_summary ~print_header ~marks
          ~mark_to_string:Intern.i2s ()
        
      let _ = if print_at_exit then Pervasives.at_exit print_summary
    end
    in
    Internal.{mark;time_thunk;get_marks;print_summary}

let _
: ?print_header:string ->
?cap:int -> ?print_at_exit:bool -> unit -> int profiler
= make_profiler
