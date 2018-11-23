include Types

module P = Waypoints 

let mk_profiler = Core.mk_profiler

let print_profile_summary = Core.print_profile_summary

let get_mark = Profile_manager.get_mark

let get_profiler = Profile_manager.get_profiler

module Profile_manager = Profile_manager
