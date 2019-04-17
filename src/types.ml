
(** Profiler ops:

- mark: imperative mark command
- get_marks: a list of all marked waypoints and the corresponding
  times at which they were marked
- print_summary: print a human-readable summary (see {!Pretty_print})
*)
type 'waypoint profiler = {
  mark: 'waypoint -> unit; 
  get_marks: unit -> ('waypoint*int) list;
  print_summary: unit -> unit
}


