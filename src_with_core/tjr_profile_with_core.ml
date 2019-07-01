(** Set the default profilers to use J. St. Core timing *)

let now = Core.Time_stamp_counter.(fun () ->
  now () |> to_int63 |> Core.Int63.to_int |> fun (Some x) -> x)[@@ocaml.warning "-8"]

(** NOTE: this library implicitly sets
   {!Tjr_profile.string_profiler} to use Core.Time_stamp_counter by
   default *)

let _ = 
  Tjr_profile.(string_profiler := make_string_profiler ~now)

let string_profiler = Tjr_profile.make_string_profiler ~now

let make_string_profiler () = Tjr_profile.make_string_profiler ~now
