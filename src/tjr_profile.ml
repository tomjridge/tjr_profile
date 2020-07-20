(** Profiling is controlled via optcomp flags. The {!Optcomp_config}
   module records those values as OCaml values. *)


(** {2 Configuation} *)

include Optcomp_config


(** {2 Interface} *)

module Profile_intf = Intf_
include Profile_intf

module With_array = With_array

(** By default, we use the array-based profiler *)
let make_profiler = With_array.make_profiler

(** Waypoints are int (for efficiency); strings can be interned to
   convert them to ints; when interning a string "foo", we also intern
   the string "foo'" as the negative of the intern of foo; this allows
   a common "entry/exit" idiom *)
let intern = With_array.intern


(* let intern = Util.Intern.intern *)


(* let dummy_profiler = Util.dummy_profiler   *)

(** {2 Profile a single function} *)

module Profile_single_function = Profile_single_function

(** Measure execution time, and print result on output
   immediately. This is not affected by optcomp config. *)
let measure_execution_time_and_print msg f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  Printf.printf "%s %#d\n" msg (b-a);
  r

(*
(** Measure the execution time of a function, and return the function
   result and the execution time. This is not affected by optcomp
   config. *)
let measure_execution_time f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  let t = b - a in
  Timed_result.{result=r;time=t}
*)
