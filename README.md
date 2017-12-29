# Very simple profiling library

This uses `Core.Time_stamp_counter`. It was formerly in `tjr_lib`, but
was moved to a separate package so that `tjr_lib` does not depend on
`Core`. 

For an example of use, see `tjr_simple_earley`. The idea is to log the
time at various "waypoints" in the code, then to print out the time
between each waypoint to establish code paths that need to be
optimized. `Tjr_profile.P` contains some pre-defined waypoint labels,
but labels can be any integer.
