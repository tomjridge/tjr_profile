(** Profiler ops:

- mark: imperative mark command
- get_marks: a list of all marked waypoints and the corresponding
  times at which they were marked
- print_summary: print a human-readable summary (see {!Pretty_print})
*)
type 'waypoint profiler = {
  mark: 'waypoint -> unit; 
  time_thunk: 'a. 'waypoint -> (unit -> 'a) -> 'a;
  get_marks: unit -> ('waypoint*int) list;
  print_summary: unit -> unit;
}

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
  
