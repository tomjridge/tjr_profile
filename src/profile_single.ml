(** This is for profiling a single function.

Global control is profided by flag PROFILING_SINGLE_ENABLED. Dummy is
   a version you can use per-file. See the [Example] functor code for
   how to use on a per-file basis.
*)
open Tjr_profile_core

[%%import "profiling_optcomp_config.ml"]

type stats = {
  total:int;
  count:int
}

module type T = sig
  val enter : unit -> unit
  val exit : unit -> unit
  val get_stats : unit -> stats
end

module Make_profiler_for_single_function(S:sig 
    val print_at_exit: bool 
    val print_header:string 
  end) 
  : T
= 
struct
  open S

[%%if PROFILING_SINGLE_ENABLED]

  let total = ref 0
  let count = ref 0
  let current = ref 0
  let enter () = current := now() [@@inline]
  let exit () = (
    let delta = now () - !current in
    total:=!total+delta;
    count:=!count+1;
    current:=0) [@@inline]

  let _ = 
    if print_at_exit then 
      Pervasives.at_exit (fun () -> 
        print_endline print_header;
        Printf.printf "Total, count, total/count: %d, %d, %d" !total !count (!total / !count))

  let get_stats () = {total=(!total); count=(!count) }

[%%else]

  let enter () = ()[@@inline]
  let exit () = ()[@@inline]
  let get_stats () = {total= -1;count= -1}[@@inline]

[%%endif]

end

module Dummy : T = struct
  let enter () = ()[@@inline]
  let exit () = ()[@@inline]
  let get_stats () = {total= -1;count= -1}[@@inline]
end


(** This is example code for how to configure single profiling at runtime using a boolean config var *)
module Example() = struct
  let flag = true

  module X = (val 
    (if flag then 
       (module Make_profiler_for_single_function(struct let print_at_exit=true let print_header = "Example" end) : T)
   else
     (module Dummy : T))
  )
end
