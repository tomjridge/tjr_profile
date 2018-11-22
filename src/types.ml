(** Waypoints *)
type wp = int


(** Profiler ops *)
type prof_ops = {
  mark: int -> unit;  (* imperative mark command *)
  get_marks: unit -> (int*int) list  (* return list of all marks *)
}


(** An interval between two waypoints *)
type interval = { p1:int; p2:int; delta: int }
