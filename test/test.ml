(** Simple test *)

module P = Tjr_profile_small.Small_impl

let _ = 
  Printf.printf "Test begins\n%!";
  let t = P.create "test" in
  P.incr t ~dur:10;
  ()

(* On exit, should print a message:
Test begins
tjr_profile.small: name=test, count=1, total_time=10, avg_time=10
tjr_profile.small: profiling_use_tsc=true
*)
