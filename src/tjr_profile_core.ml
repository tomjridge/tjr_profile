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

(** This is a profiler that fails if any method is called; useful for
   checking that all profilers have been initialized (even if only to
   dummy_profiler) *)
let failing_profiler = {
  mark=(fun _ -> failwith (Printf.sprintf "%s: mark\n%s" __MODULE__ __LOC__));
  get_marks=(fun _ -> failwith (Printf.sprintf "%s: get_marks\n%s" __MODULE__ __LOC__));
  print_summary=(fun () ->
    failwith (Printf.sprintf "%s: print_summary\n%s" __MODULE__ __LOC__))      
}
  

(** A reference to a dummy profiler, for quick and dirty single-profiler use *)
let string_profiler : string profiler ref = ref dummy_profiler
