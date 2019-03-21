(** Provide support for accessing profilers by name *)

(* open Misc.StringMap *)
module StringMap = Map.Make(struct type t = string let compare : t -> t -> int = Pervasives.compare end)
open Core



let profilers : prof_ops StringMap.t ref = ref StringMap.empty

let register_profiler ~name ~profiler =
  profilers:=StringMap.add name profiler (!profilers)

let get_profiler ~name =
  StringMap.find_opt name (!profilers)

(** The default profiler. This must be replaced eg with
    [Core.Time_stamp_counter.(fun () -> now () |> to_int63 |> Core.Int63.to_int |> fun (Some x) -> x)]
*)

let now : (unit -> int) ref = ref (fun () -> 
    Printf.printf "FATAL ERROR! no timer installed, at:\n %s\n%!" __LOC__;
    failwith __LOC__)

let create_profiler ~name =
  let profiler = mk_profiler ~now:(!now) in
  register_profiler ~name ~profiler;
  profiler
    

let get_mark ~name =
  get_profiler ~name |> function
  | None -> 
    let profiler = mk_profiler ~now:(!now) in
    register_profiler ~name ~profiler;
    profiler.mark
  | Some profiler ->
    profiler.mark


