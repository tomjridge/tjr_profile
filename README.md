# Very simple profiling library

This was formerly in `tjr_lib`, but was moved to a separate package so
that `tjr_lib` does not depend on `Core`.

Actually, now the code is independent of Core (you can provide
`Core.Time_stamp_counter` when constructing a profiler).

For an example of use, see `tjr_simple_earley`. The idea is to log the
time at various "waypoints" in the code, then to print out the time
between each waypoint to establish code paths that need to be
optimized. `Waypoints` contains some pre-defined waypoint labels, but
labels can be any integer.

More recent example in `Tjr_kv.store_with_lru,test`, with marking in
`multithreaded_lru.ml`
