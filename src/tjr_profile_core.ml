(** Simple profiling. *)

open Profile_intf

(** This is a reference to an (optional) timer; it must be initialized
   before calling make_string_profiler *)
let now : (unit -> int) option ref = 
  (* Printf.printf "%s: now is a mutable reference\n" __MODULE__; *)
  ref None 

let make_string_profiler () =
  let now = !now |> function Some now -> now | None -> 
      failwith (Printf.sprintf "%s: now reference not set" __MODULE__)
  in
  let marks = ref [] in
  let mark waypoint = marks := (waypoint,now())::!marks in
  let get_marks () = !marks in
  let print_summary () = 
    Pretty_print.print_profile_summary ~marks:!marks ~waypoint_to_string:(fun x -> x)
  in   
  let time_function s f = 
    let a = now () in
    let r = f () in
    let b = now () in
    Printf.printf "%s, %s: %d\n" "Profiling" s (b-a);
    r
  in
  { mark; get_marks; print_summary; time_function }


(** Use this as a placeholder (eg via a reference) which is
   subsequently replaced by the main executable. *)
let dummy_profiler : string profiler = {
  mark=(fun _ -> ());
  get_marks=(fun _ -> []);
  print_summary=(fun () ->
      Printf.printf "%s: this is a dummy profiler!\n%!" __FILE__);
  time_function=(fun _s f -> f ())
}

let _ = dummy_profiler

