(* simple profiling ---------------------------------------- *)

open Types
open Waypoints

let dest_Some = function Some x -> x | _ -> (failwith "dest_Some")

(* a list of points and their timestamps; typically per function *)
let mk_profiler ~now = 
  let xs = ref [] in
  (* record time at a particular point in the code; typically put this
     in an assert, and disable in production *)
  let mark waypoint = xs := (waypoint,now())::!xs in
  let get_marks () = !xs in
  { mark;  get_marks}


let marks2intervals marks : interval list =
  marks |> List.fold_left 
    (fun (`A(acc,newer_mark)) mark -> 
       let (p2,t2) = newer_mark in
       let (p1,t1) = mark in
       let delta = t2 - t1 in
       `A({p1;p2;delta}::acc,(p1,t1)))
    (`A([],List.hd marks))  (* FIXME marks <> [] *)
  |> fun (`A(intervals,_)) -> 
  intervals


let summarize_intervals intervals : (int*interval) list = 
  let tbl = Hashtbl.create 10 in
  let warn = ref false in
  let _ = 
    intervals |> List.iter 
      (fun {p1;p2;delta} -> 
         begin
           try 
             Hashtbl.find tbl (p1,p2) |> fun (count,time) ->
             (if (time > max_int - delta) then warn:=true);
             Hashtbl.replace tbl (p1,p2) (count+1,time+delta)
           with _ -> Hashtbl.add tbl (p1,p2) (1,delta)
         end)
  in
  if !warn then Printf.printf "Warning: overflow occurred\n%!" else ();
  let xs = ref [] in
  Hashtbl.iter 
    (fun (p1,p2) (count,delta) -> xs:=(count,{p1;p2;delta})::!xs) tbl;
  !xs


let interval2string {p1;p2;delta} = 
  Printf.sprintf "%s %s %d" 
    (wp_to_string p1) 
    (wp_to_string p2) 
    delta


let print_intervals intervals = 
  List.iter (fun i -> interval2string i |> print_endline) intervals


let print_profile_summary marks =
  match marks with
  | [] -> Printf.printf "No marks available! Did you enable profiling?\n%!"
  | _ -> 
    Printf.printf "| Total time | wp1 | wp2 | count | Unit cost |\n%!";
    marks |> marks2intervals |> summarize_intervals |> fun cis ->
    cis |> List.map
      (fun (count,i) ->
         let {p1;p2;delta} = i in
         (delta, 
          Printf.sprintf "| %d | %s | %s | %d | %d |" 
            delta 
            (wp_to_string p1) 
            (wp_to_string p2) 
            count
            (delta / count)
         ))
    |> List.sort (fun (d1,_) (d2,_) -> d1 - d2)
    |> List.iter (fun (_,s) -> print_endline s);
