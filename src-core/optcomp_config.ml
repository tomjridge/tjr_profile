(** This is an optcomp configuration file. It imports a raw optcomp
   file from "config.ml" which defines two optcomp variables:
   PROFILING_USE_TSC and PROFILING_ENABLED. The rest of the file is
   optcomp-filtered OCaml. *)

[%%import "config.ml"]

(** The underlying timing method is controlled by optcomp
   [PROFILING_USE_TSC] variable. *)

[%%if PROFILING_USE_TSC]

(** We ARE using TSC for profiling. *)
let profiling_use_tsc = true

let now : unit -> int = 
  let open Core in
  let open Time_stamp_counter in
  let calibrator = Lazy.force calibrator in
  fun () -> now () 
            |> to_time_ns ~calibrator 
            |> Time_ns.to_int_ns_since_epoch

[%%else]

(** We ARE NOT using TSC for profiling. *)
let profiling_use_tsc = false

let now : unit -> int = 
  let open Core_kernel in 
  let open Time_ns in
  fun () -> now ()
            |> to_int63_ns_since_epoch

[%%endif]



[%%if PROFILING_ENABLED]

(** Profiling IS enabled (for profilers) *)
let profiling_enabled = true

[%%else]

(** Profiling is NOT enabled *)
let profiling_enabled = false

[%%endif]


