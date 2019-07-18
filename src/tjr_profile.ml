(** Profiling is controlled via optcomp flags. The {!Optcomp_config}
   module records those values as OCaml values. *)
include Optcomp_config

module Profile_single = Profile_single

module With_array = With_array

include Profile_intf

include Tjr_profile_core


module Dummy_string_profiler = struct
  let mark (_s:string) = () [@@inline]
let profile (_s:string) (f:unit -> 'a) = f () [@@inline]
let print_summary () = () [@@inline]
end

module Dummy_int_profiler = struct
let allocate_int _s = 0
  let mark (_s:int) = () [@@inline]
let profile (_s:int) (f:unit -> 'a) = f () [@@inline]
let print_summary () = () [@@inline]
end

(* module Util = Util *)
