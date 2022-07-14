(** Single file minimal implementation, 2022Q3; depends on "landmarks" library for clock
    function which uses the TSC https://en.wikipedia.org/wiki/Time_Stamp_Counter (could
    also get from Jane St. libs, but they change a lot while landmarks is stable); copy
    into a file "waypts.ml" in your project *)

let clock : unit -> int = fun () -> Landmark.clock () |> Int64.to_int

module Private = struct
  type t = {
    description : string;
        (* when we print the results, we use this to distinguish different instances *)
    print_at_exit : (unit -> bool) option;
        (* called at_exit, to determine whether to print results or not; if None, always
           print *)
    mutable min_free : int;
    mutable waypt_to_string : (int * string) list; (* assumed small *)
    mutable count : int array array;
        (* 2D array, indexed by (w1,w2); counts the number of times the (w1,w2) path was
           executed *)
    mutable time : int array array;
        (* counts the total time on the (w1,w2) path *)
    mutable last_idx : int;
        (* last waypt marked; initially 0 *)
    mutable last_clock : int; 
    (* value of the clock when we visited last_idx *)
        (* pid : int; (\* at_exit, we print out the results; but we only want to do this
           for the current process (not in any child, for example) *\) *)
  }

  let print t =
    let tbl = Hashtbl.create 10 in
    t.waypt_to_string |> List.iter (fun (i, s) -> Hashtbl.replace tbl i s);
    let to_string wi = Hashtbl.find tbl wi in
    let waypts = List.init t.min_free (fun i -> i) |> List.tl (* drop 0 *) in
    (* includes 0 *)
    let waypts_s =
      List.map (fun i -> Printf.sprintf "%d,%s" i (to_string i)) waypts
      |> String.concat ","
    in
    (* for each pair (w,w') that is actually traversed, we print the count, total time and
       avg time *)
    (* FIXME we may want to sort by total time... *)
    let table_header = "| w | w' | count | total time | avg time |" in
    let table = ref "" in
    let _ =
      for i = 1 to t.min_free-1 do
        for j = 1 to t.min_free-1 do
          (* Printf.printf "i,j %d,%d\n" i j; *)
          let count, time = (t.count.(i).(j), t.time.(i).(j)) in
          if count > 0 then (
            let line =
              Printf.sprintf "| %s | %s | %d | %d | %d |" (to_string i)
                (to_string j) count time (time / count)
            in
            table := !table ^ line ^ "\n";
            ())
        done
      done
    in
    Printf.printf "\n(Waypts description: %s\nWaypts: %s\n%s\n%s)"
      t.description waypts_s table_header !table;
    ()

  let init ?print_at_exit description =
    let t =
      {
        description;
        print_at_exit;
        min_free = 1;
        (* ensure 0 is kept as a dummy value *)
        waypt_to_string = [ (0, "-") ];
        count = Array.make_matrix 0 0 0;
        time = Array.make_matrix 0 0 0;
        last_idx = 0; (* dummy value; never used as a waypt *)
        last_clock = clock(); (* dummy value; only used when moving from "0 waypt" to first
                           waypt *)
      }
    in
    let _setup_print_at_exit =
      let f () = match print_at_exit with None -> true | Some f -> f () in
      Stdlib.at_exit (fun () -> match f () with true -> print t | false -> ())
    in
    t

  type waypt = { idx : int; t : t }

  (* needs [initialise_arrays_from_waypts] calling when finished adding waypts *)
  let mk_waypt (t : t) s : waypt =
    let idx = t.min_free in
    t.min_free <- t.min_free + 1;
    t.waypt_to_string <- (idx, s) :: t.waypt_to_string;
    { idx; t }

  (* should be called after declaring waypts but before marking waypts *)
  let initialise_arrays_from_waypts t =
    let sz = t.min_free in
    t.count <- Array.make_matrix sz sz 0;
    t.time <- Array.make_matrix sz sz 0;
    ()

  (* call mk_waypt for each s; then call initialise_arrays_from_waypts; can be called
     multiple times if further waypts added *)
  let mk_waypts t xs =
    let r = xs |> List.map (mk_waypt t) in
    initialise_arrays_from_waypts t;
    r

  let mark w =
    let tm = clock () in
    let last_idx, last_clock = w.t.last_idx, w.t.last_clock in
    let time_elapsed = tm - last_clock in
    w.t.count.(last_idx).(w.idx) <- 1 + w.t.count.(last_idx).(w.idx);
    w.t.time.(last_idx).(w.idx) <- time_elapsed + w.t.time.(last_idx).(w.idx);
    w.t.last_idx <- w.idx;
    w.t.last_clock <- tm;
    ()
end

(** Interface we expose to users *)
module type S = sig
  type t
  val print : t -> unit
  val init : ?print_at_exit:(unit -> bool) -> string -> t
  type waypt
  val mk_waypt : t -> string -> waypt
  val initialise_arrays_from_waypts : t -> unit
  val mk_waypts : t -> string list -> waypt list
  val mark : waypt -> unit
end

include (Private:S)

module Example () = struct 

  (* NOTE here we have only 1 instance; but often you need 2 or more instances within a
     single file e.g. one instance for measuring the complete execution time of a
     function, and another instance for waypoints within the function, to measure
     individual sections *)
  let t = init "Example waypt usage"

  let [w1;w2;w2';w3;w3'] = mk_waypts t ["w1";"w2";"w2'";"w3";"w3'"][@@warning "-8"]
      
  let run () = 
    let delta = 0.1 in
    for _i=1 to 10 do
      mark w1;
      Unix.sleepf (10.0 *. Random.float delta);
      match 0.3 < Random.float 1.0 with
      | true -> 
        mark w2;
        Unix.sleepf (20.0 *. Random.float delta);
        mark w2';
        ()
      | false -> 
        mark w3;
        Unix.sleepf (1.0 *. Random.float delta);
        mark w3';
        ()
    done

  let _ = run ()  

(* Example output (with aligned cols):

(Waypts description: Example waypt usage
Waypts: 1,w1,2,w2,3,w2',4,w3,5,w3'
| w   | w'  | count |  total time |   avg time |
| w1  | w2  |     9 | 14131682821 | 1570186980 |
| w1  | w3  |     1 |   462451867 |  462451867 |
| w2  | w2' |     9 | 34493230385 | 3832581153 |
| w2' | w1  |     8 |       41679 |       5209 |
| w3  | w3' |     1 |   227305900 |  227305900 |
| w3' | w1  |     1 |        3820 |       3820 |
)
*)

end

module _ = Example()
