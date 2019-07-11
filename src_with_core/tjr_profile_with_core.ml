(** Set the default timer to use J. St. Core timing *)

(** NOTE: this library implicitly sets
   {!Tjr_profile.now} to use Core.Time_stamp_counter by
   default.

NOTE do not open this module - Make_profiler clashes with a similar functor in {!Tjr_fs_shared}.
 *)

let now = Core.(Time_stamp_counter.(fun () ->
  now () 
  |> to_time_ns ~calibrator:(Lazy.force calibrator) 
  |> Time_ns.to_int_ns_since_epoch))


let initialize () = 
  (* Printf.printf "Initializing Tjr_profile.now\n"; *)
  Tjr_profile.now := Some now

let _ = initialize()

(** Make profiling functions profile and mark, without indirecting via
   an object. Note also that this functor ignores whether profiling is
   actually enabled or not via ppx_optcomp *)
module Make_profiler() = struct
  let internal_profiler = Tjr_profile.make_string_profiler()
  let mark = internal_profiler.mark
  let profile s f = mark s; f() |> fun r -> mark (s^"'"); r
end

module Internal = Make_profiler()

let time_function s f =
  Internal.internal_profiler.time_function s f 

let _ = time_function
