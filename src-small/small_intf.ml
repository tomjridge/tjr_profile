(** Small interfaces *)

(** This interface allows to create timers (essentially, a mutable
   count and a mutable total time); timers have an associated
   "at_exit" function which is called when the process exits; each
   timer tracks the number of calls (eg to a particular function) and
   the total duration of all calls; this is what is printed at
   exit. *)
module type T = sig
  type t

  (** The string argument is a "name" used to distinguish different
     timers *)
  val create: string -> t

  val now: unit -> int

  val incr: t -> dur:int -> unit
end
