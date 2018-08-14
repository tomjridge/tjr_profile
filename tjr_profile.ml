(* simple profiling ---------------------------------------- *)

let dest_Some = function Some x -> x | _ -> (failwith "dest_Some")


(* waypoints *)
module P = struct

  type t = int

  (* waypoints, typically per-function *)
  let ab : t = 1
  let ac : t = 13
  let bc : t = 2
  let cd : t = 3
  let de : t = 4
  let ef : t = 5
  let fg : t = 6
  let gh : t = 7
  let hi : t = 8
  let ij : t = 9
  let jk : t = 10

  let p_to_string i = 
    match i with
    | _ when i = ab -> "ab"
    | _ when i = ac -> "ac"
    | _ when i = bc -> "bc"
    | _ when i = cd -> "cd"
    | _ when i = de -> "de"
    | _ when i = ef -> "ef"
    | _ when i = fg -> "fg"
    | _ when i = gh -> "gh"
    | _ when i = hi -> "hi"
    | _ when i = ij -> "ij"
    | _ when i = jk -> "jk"
    | _ -> string_of_int i
end

open P


type profiler = {
  mark: int -> unit;  (* imperative mark command *)
  (* mark': int -> bool; (* returns true, to make it easier to include in asserts *) *)
  get_marks: unit -> (int*int) list  (* return list of all marks *)
}



(* assume 64-bit ints, so last conversion is ok  *)
(*
let now () = Core.Time_stamp_counter.(
    now () |> to_int63 |> Core.Int63.to_int |> dest_Some)
*)

(* a list of points and their timestamps; typically per function *)
let mk_profiler ~now = 
  let xs = ref [] in
  (* record time at a particular point in the code; typically put this
     in an assert, and disable in production *)
  let mark waypoint = (xs := (waypoint,now())::!xs) in
  (* let mark' x = mark x; true in *)
  let get_marks () = !xs in
  { mark; (* mark'; *) get_marks} 


(* an interval between two waypoints *)
type interval = { p1:int; p2:int; delta: int }

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
  (if !warn then Printf.printf "Warning: overflow occurred\n%!");
  let xs = ref [] in
  Hashtbl.iter (fun (p1,p2) (count,delta) -> xs:=(count,{p1;p2;delta})::!xs) tbl;
  !xs

let interval2string {p1;p2;delta} = Printf.sprintf "%s %s %d" (p_to_string p1) (p_to_string p2) delta

let print_intervals intervals = 
  List.iter (fun i -> interval2string i |> print_endline) intervals


let print_profile_summary marks =
  marks |> marks2intervals |> summarize_intervals |> fun cis ->
  cis |> List.map
    (fun (count,i) ->
       let {p1;p2;delta} = i in
       (delta, Printf.sprintf "Time:%d  %s %s count:%d" delta (p_to_string p1) (p_to_string p2) count))
  |> List.sort (fun (d1,_) (d2,_) -> d1 - d2)
  |> List.iter (fun (_,s) -> print_endline s);
