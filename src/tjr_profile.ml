(** Profiling is controlled via optcomp flags. The {!Optcomp_config}
   module records those values as OCaml values. *)
include Optcomp_config

module Profile_single = Profile_single

module With_array = With_array

include Profile_intf

include Tjr_profile_core

(* module Util = Util *)
