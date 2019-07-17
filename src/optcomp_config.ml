[%%import "profiling_optcomp_config.ml"]

[%%if PROFILING_USE_TSC]

(** We ARE using TSC for profiling. *)
let profiling_use_tsc = true

[%%else]

(** We ARE NOT using TSC for profiling. *)
let profiling_use_tsc = false
[%%endif]



[%%if PROFILING_ENABLED]

(** Profiling is enabled (for profilers) *)
let profiling_enabled = true

[%%else]

(** Profiling is not enabled *)
let profiling_enabled = false

[%%endif]



[%%if PROFILING_SINGLE_ENABLED]

(** Profiling single is enabled *)
let profiling_single_enabled = true

[%%else]

(** Profiling single is not enabled *)
let profiling_single_enabled = false

[%%endif]

