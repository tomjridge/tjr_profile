(** Profile a single function using "enter" and "exit". The function
   may be called many times. This keeps track of the number of times,
   and the total time. *)

open Optcomp_config
open Intf_

let make ?(print_at_exit=true) ?(print_header="") () = 
  match profiling_enabled with
  | false -> 
    let dummy () = () in 
    { enter=dummy; 
      exit=dummy; 
      get_stats=(fun () -> {total= -1;count= -1}) }
  | true ->   
    let module A = struct
      let total = ref 0
      let count = ref 0
      let current = ref 0
      let enter () = current := now()
      let exit () = 
        let delta = now () - !current in
        total:=!total+delta;
        count:=!count+1

      let print () = 
        (if print_header <> "" then print_endline print_header);
        Printf.printf "Total, count, total/count: %d, %d, %d\n" 
          !total !count (!total / !count)
      
      let _ = if print_at_exit then Pervasives.at_exit print

      let get_stats () = { total=(!total); count=(!count) }
    end
    in
    A.{enter;exit;get_stats}

