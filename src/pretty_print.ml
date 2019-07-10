(** Profile pretty printing; don't use directly *)

open Util

let print_profile_summary ~marks ~waypoint_to_string =

  let tbl = Hashtbl.create 100 in

  let _ = 
    match marks with 
    | [] -> ()
    | newer_mark::marks -> (
        (newer_mark,marks)
        |> iter_opt (function
            | _,[] -> None
            | (w2,t2),(w1,t1)::marks ->
              let delta = t2 - t1 in
              let (count,time) = 
                Hashtbl.find_opt tbl (w1,w2) |> function
                | None -> (0,0)
                | Some x -> x
              in
              Hashtbl.replace tbl (w1,w2) (count+1,time+delta);
              Some ((w1,t1),marks))
        |> fun _ -> ())
  in

  let bindings = 
    Hashtbl.to_seq tbl 
    |> List.of_seq
    |> List.sort (fun ((_,_),(_c1,t1)) ((_,_),(_c2,t2)) ->
        Pervasives.compare t1 t2)
  in
  
  match bindings with
  | [] -> Printf.printf "No profiling data available! Did you enable profiling?\n%!"
  | _ -> 
    let csv = 
      (" Total time | wp1 | wp2 | count | Unit cost" |> String_.split_on_all ~sub:"|")::
      (bindings |> List.map (fun ((w1,w2),(count,time)) -> 
           Printf.sprintf " %11d | %3s | %3s | %8d | %9d " 
             time 
             (waypoint_to_string w1) 
             (waypoint_to_string w2) 
             count
             (time / count)
           |> String_.split_on_all ~sub:"|"
         ))
    in
    String_.pp_csv csv


let _ = print_profile_summary
