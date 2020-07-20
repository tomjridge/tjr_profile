# Tjr_profile: A simple profiling library


OCamldoc: <https://tomjridge.github.io/ocamldocs/>

Usage:

~~~
  let { mark; _ } = 
    if profiling_enabled 
    then make_profiler 
        ~print_header:(Printf.sprintf "bt blk profiler (bt/%s)" __FILE__) ()
    else dummy_profiler

  (* Locations / waypoints *)
  let [loc1;loc2] = 
    ["loc1";"loc2"] |> List.map intern
  [@@ocaml.warning "-8"]

  (* Measure execution time of f (for each invocation) and print summary at exit. *)
  let mark' f = 
    mark loc1;
    f () |> fun r ->
    mark (-1*loc1);
    r
~~~


## Notes

We are trying to keep most of the code platform independent. Our
preferred timing mechanism is the very low level kernel "Time stamp
counters (TSC)". This is currently supported only by Jane Street's
Core library. But Core is dependent on a Linux environment. So we need
to provide a way to avoid dependence on Core when deploying to other
environments. At the moment this is controlled via optcomp
configuration.
