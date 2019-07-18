(** This version attempts to reduce computation and GC costs during
   the profiling (there may be substantial processing costs at the end
   to compute the summary).

FIXME this should be enabled/disabled via optcomp
 *)

module Make_enumeration(S:sig type t end) = struct

  let to_int = Hashtbl.create 100
  let from_int = Hashtbl.create 100
  let free = ref 1 (* reserve 0 for special cases *)

  let allocate_int (s:S.t) = 
    let n = !free in
    Hashtbl.add to_int s n;
    Hashtbl.add from_int n s;
    free:=n + 1;
    n

  let s2i s = Hashtbl.find to_int s
  let s2i_opt s = Hashtbl.find_opt to_int s

  let i2s i = Hashtbl.find from_int i
  let i2s_opt i = Hashtbl.find_opt from_int i
end

module Make_string_enumeration() = struct
  include Make_enumeration(struct type t = string end)
end

(** NOTE we do not check access to the array; if profiling exceeds the cap an exception will occur *)
module Make_profiler(S:sig val cap:int end) 
: sig
  val allocate_int : string -> int
  (* val s2i : string -> int *)
  (* val s2i_opt : string -> int option *)
  (* val i2s : int -> string *)
  (* val i2s_opt : int -> string option *)
  (* val cap : int *)
  (* module A = Bigarray.Array2 *)
  (* val marks : (int, Bigarray.int_elt, Bigarray.c_layout) A.t *)
  (* val ptr : int ref *)
  val mark : int -> unit
  val print_summary : unit -> unit
end
= struct

  include Make_string_enumeration()

  (* we record marks in an array *)

  (* FIXME not sure what initial cap should be; presumably this takes
     a long time to allocate? *)
  let cap = S.cap

  module A = Bigarray.Array2

  let marks = 
    A.create 
      Bigarray.Int
      Bigarray.c_layout
      cap
      2

  let ptr = ref 0  (* index into marks *)

  let mark i = 
    let n = !ptr in
    A.(
      set marks n 0 (Tjr_profile_core.now());
      set marks n 1 i;
      ptr:=n+1)

  let print_summary () = 
    (* build a list, then call the standard print routine based on
       strings FIXME horribly inefficient *)
    (0,[]) |> List_.iter_break (fun (p,xs) -> 
        match p >= !ptr with 
        | true -> `Break xs
        | false -> 
          let (t,i) = A.(get marks p 0,get marks p 1) in
          `Continue(p+1,(i,t)::xs))
    |> fun marks -> 
    Pretty_print.print_profile_summary ~marks ~waypoint_to_string:i2s

end
