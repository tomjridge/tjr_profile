(** This version attempts to reduce computation and GC costs during
   the profiling (there may be substantial processing costs at the end
   to compute the summary).

 *)

open Optcomp_config

open Intf_

module Pvt = struct
  (* similar, but adding s->n also adds s'->-n; useful for making pairs
     of marks eg for begin and end of a function *)
  module Make_intern_2(S:sig type t val prime: t -> t end) = struct
    open S
    let to_int = Hashtbl.create 100
    let from_int = Hashtbl.create 100
    let free = ref 1 (* reserve 0 for special cases *)

    let t2i s = Hashtbl.find to_int s
    let t2i_opt s = Hashtbl.find_opt to_int s

    let i2t i = Hashtbl.find from_int i
    let i2t_opt i = Hashtbl.find_opt from_int i

    (** Intern an object (allocate an integer for it) *)
    let intern (s:S.t) = 
      t2i_opt s |> function
      | None -> 
        let n = !free in
        Hashtbl.add to_int s n;
        Hashtbl.add to_int (prime s) (-1*n); (* add s' as -n *)
        Hashtbl.add from_int n s;
        Hashtbl.add from_int (-1*n) (prime s);
        free:=n + 1;
        n
      | Some i -> i
  end

  module Intern = struct
    include Make_intern_2(struct type t = string let prime s = s^"'" end)
    let s2i = t2i
    let s2i_opt = t2i_opt
    let i2s = i2t
    let i2s_opt = i2t_opt
  end
end

open Pvt

let intern = Intern.intern

(** Make a profiler which uses an 2D array of ints to record
   marks. NOTE this is affected by optcomp config. *)
let make_profiler ?(print_header="") ?(cap=10_000_000) 
    ?(print_at_exit=true) () 
  =
  match profiling_enabled with
  | false -> dummy_profiler
  | true -> 
    let open (struct
      module A = Bigarray.Array2

      (* (n,0) holds the time; (n,1) holds the mark id *)
      let marks = 
        A.create
          Bigarray.Int
          Bigarray.c_layout
          cap
          2

      let ptr = ref 0  (* index into marks *)

      let warning = lazy (
        Printf.printf "WARNING!!! %s: too many marks; profiling data \
                       will be incomplete" __LOC__)

      let mark i = A.(
          let n = !ptr in
          try
            set marks n 0 (now());
            set marks n 1 i;
            ptr:=n+1
          with Invalid_argument _ -> 
            Lazy.force warning)

      let _time_thunk m f =
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
    end)
    in
    {mark;get_marks;print_summary}

let _
: ?print_header:string ->
?cap:int -> ?print_at_exit:bool -> unit -> int profiler
= make_profiler
