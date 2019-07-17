(** Simple profiling. *)

open Profile_intf

(** The underlying timing method is controlled by optcomp [PROFILING_USE_TSC] variable. *)

[%%import "profiling_optcomp_config.ml"]


[%%if PROFILING_USE_TSC]

let now = 
  let open Core in
  let open Time_stamp_counter in
  let calibrator = Lazy.force calibrator in
  fun () -> now () 
            |> to_time_ns ~calibrator 
            |> Time_ns.to_int_ns_since_epoch

[%%else]

let now = 
  let open Core_kernel in 
  let open Time_ns in
  fun () -> now ()
            |> to_int63_ns_since_epoch

[%%endif]

let make_string_profiler () =
  let marks = ref [] in
  let mark waypoint = marks := (waypoint,now())::!marks in
  let get_marks () = !marks in
  let print_summary () = 
    Pretty_print.print_profile_summary ~marks:!marks ~waypoint_to_string:(fun x -> x)
  in   
  { mark; get_marks; print_summary }

(** Measure execution time, and print result on output *)
let measure_execution_time_and_print s f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  Printf.printf "%s %d\n" s (b-a);
  r

(** Measure the execution time of a function, call a function
   [with_time] that takes the execution time and returns unit, and
   finally return the result of the function FIXME with_time bad name *)
let measure_execution_time ~with_time f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  with_time (b-a);
  r


(** A functorial version, which perhaps is better optimized than the record version *)
module Make_profiler() = 
struct
[%%if PROFILING_ENABLED]
(* NOTE this code parallels that in Tjr_profile_with_core *)
let internal_profiler = Tjr_profile.make_string_profiler ()
let mark = internal_profiler.mark [@@inline]
let profile s f = mark s; f() |> fun r -> mark (s^"'"); r [@@inline]
let print_summary () = internal_profiler.print_summary() [@@inline]
[%%else]
let mark (_s:string) = () [@@inline]
let profile (_s:string) (f:unit -> 'a) = f () [@@inline]
let print_summary () = () [@@inline]
[%%endif]
end
