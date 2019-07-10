(** Set the default timer to use J. St. Core timing *)

(** NOTE: this library implicitly sets
   {!Tjr_profile.now} to use Core.Time_stamp_counter by
   default *)

let now = Core.(Time_stamp_counter.(fun () ->
  now () 
  |> to_time_ns ~calibrator:(Lazy.force calibrator) 
  |> Time_ns.to_int_ns_since_epoch))


let initialize () = 
  (* Printf.printf "Initializing Tjr_profile.now\n"; *)
  Tjr_profile.now := Some now
