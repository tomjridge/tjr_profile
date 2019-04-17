(** Simple profiling. *)

include Types


(** The [now] argument is a timer. This should be eg 
      [Core.Time_stamp_counter.(fun () -> now () |> to_int63 |> Core.Int63.to_int |> fun (Some x) -> x)] *)
let make_int_profiler ~now = 
  let marks = ref [] in
  (* record time at a particular point in the code; typically put this
     in an assert, and disable in production *)
  let mark waypoint = marks := (waypoint,now())::!marks in
  let get_marks () = !marks in
  let print_summary () = 
    Pretty_print.print_profile_summary ~marks:!marks ~waypoint_to_string:string_of_int
  in   
  { mark; get_marks; print_summary }

let make_string_profiler ~now =
  let marks = ref [] in
  let mark waypoint = marks := (waypoint,now())::!marks in
  let get_marks () = !marks in
  let print_summary () = 
    Pretty_print.print_profile_summary ~marks:!marks ~waypoint_to_string:(fun x -> x)
  in   
  { mark; get_marks; print_summary }


(** Use this as a placeholder (eg via a reference) which is
   subsequently replaced by the main executable. *)
let dummy_profiler = {
  mark=(fun _ -> ());
  get_marks=(fun _ -> []);
  print_summary=(fun () ->
      Printf.printf "%s: this is a dummy profiler!\n%!" __FILE__)
}

let _ = dummy_profiler
