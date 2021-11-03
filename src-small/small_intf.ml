(** Small interfaces *)

(** This interface allows to create references; refs have an
   associated "at_exit" function which is called when the process
   exits; each reference tracks the number of calls (eg to a
   particular function) and the duration of each call; this is what is
   printed at exit. *)
module type T = sig
  type t

  (** The string argument is a "name" used to distinguish different
     refs *)
  val create: string -> t

  val now: unit -> int

  val incr: t -> dur:int -> unit
end
