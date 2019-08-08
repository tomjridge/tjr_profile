(** Profiling is controlled via optcomp flags. The {!Optcomp_config}
   module records those values as OCaml values. *)
include Optcomp_config

module Profile_intf = Intf_
include Profile_intf

include Util

module Profile_single_function = Profile_single_function

module With_array = With_array

let intern = Intern.intern

let make_profiler = With_array.make_profiler

let dummy_profiler = Util.dummy_profiler  
