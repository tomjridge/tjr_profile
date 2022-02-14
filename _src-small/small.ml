(** Small implementation *)

open Small_intf

module Make_1 = struct

  type t = { count: int ref; mutable total_time: int }

  let libname = "tjr_profile.small"

  (* NOTE This gets forced if we ever create a single t *)
  let print_at_exit = lazy (
    Stdlib.at_exit (fun () -> 
        Printf.printf "%s: profiling_use_tsc=%b\n%!"
          libname
          Tjr_profile_core.Optcomp_config.profiling_use_tsc))

  let create s = 
    Lazy.force print_at_exit;
    let t = {count=ref 0;total_time=0} in
    Stdlib.at_exit (fun () -> 
        Printf.printf "%s: name=%s, count=%d, total_time=%d, avg_time=%d\n%!"
          libname
          s
          !(t.count)
          t.total_time
          (t.total_time / !(t.count)));
    t

  let now () = Tjr_profile_core.Optcomp_config.now ()

  let incr t ~dur = 
    incr t.count;
    t.total_time <- t.total_time + dur    

end

(** Functionality to create a named timer, get the current time, and
   add a given duration to a timer *)
module Make_2 : T = Make_1


(** Trivial stub implementation, which doesn't do anything;  *)
module Make_3 : T = struct

  type t = unit
    
  let create _s = ()

  let now () = 0

  let incr _t ~dur:_ = ()

end
