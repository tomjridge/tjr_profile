(** Make profiling slightly easier by allowing open Tjr_profile.Profiler or open Tjr_profile.No_profiler *)

open Tjr_profile_core

module type PROFILER = sig
  val mark: string -> unit
  val profile: string -> (unit -> 'a) -> 'a 
end

module Profiler : PROFILER = struct
  let profiler: string profiler ref = string_profiler

  let profile x y z =
    !profiler.mark x;
    let r = z() in
    !profiler.mark y;
    r

  let profile x z = 
    profile x (x^"'") z

  let mark x = !profiler.mark x
end
(* include Profiler *)

module No_profiler : PROFILER = struct
  let mark _x = ()
  let profile _x y = y ()
end
