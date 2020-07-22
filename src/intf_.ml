(** Profiling interfaces *)

(** Profiler ops:

- mark: imperative mark command
- (pvt) get_marks: a list of all marked waypoints and the corresponding
  times at which they were marked
- print_summary: print a human-readable summary (see {!Pretty_print})
*)
type 'waypoint profiler = {
  mark          : 'waypoint -> unit; 
  get_marks     : unit -> ('waypoint*int) list;
  print_summary : unit -> unit;
  time_thunk : 'a. 'waypoint -> (unit -> 'a) -> 'a;
}

let dummy_profiler = { 
  mark          = (fun _m -> ());
  get_marks     = (fun () -> []);
  print_summary = (fun () -> ());
  time_thunk    = (fun _m f -> f());
}


(*
type stats = {
  total:int;
  count:int
}

type profile_single = {
  enter : unit -> unit;
  exit : unit -> unit;
  get_stats : unit -> stats
}

module Timed_result = struct
  type 'a timed_result = {
    result:'a;
    time:int
  }
end
type 'a timed_result = 'a Timed_result.timed_result
*)  

exception Profiling_exception of string
