(** Profiling is controlled via optcomp flags. The {!Optcomp_config}
   module records those values as OCaml values. 

Example (see Example module in Tjr_profile):
{[
  let f () = 
    (* do something *)
    1+2

  (** waypoint *)
  let pt = intern "pt"

  let profiler = make_profiler ()
  let {mark;_} = profiler

  let profiled_f () = 
    mark pt;
    let r = f () in
    mark (-1*pt);
    r

  (** Run f 100 times, and print the profiling results at exit *)
  let do_it () = 
    for i = 0 to 100 do
      ignore(profiled_f())
    done
]}

*)


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


(** {2 Example} *)

module Example() = struct

  let f () = 
    (* do something *)
    1+2

  (** waypoint *)
  let pt = intern "pt"

  let profiler = make_profiler ()
  let {mark;_} = profiler

  let profiled_f () = 
    mark pt;
    let r = f () in
    mark (-1*pt);
    r

  (** Run f 100 times, and print the profiling results at exit *)
  let do_it () = 
    for i = 0 to 100 do
      ignore(profiled_f())
    done[@@warning "-35"]

end



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

