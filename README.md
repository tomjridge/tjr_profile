# Tjr_profile: A simple profiling library


OCamldoc: <https://tomjridge.github.io/ocamldocs/>

Usage: See the ocamldoc


## Notes

We are trying to keep most of the code platform independent. Our
preferred timing mechanism is the very low level kernel "Time stamp
counters (TSC)". This is currently supported only by Jane Street's
Core library. But Core is dependent on a Linux environment. So we need
to provide a way to avoid dependence on Core when deploying to other
environments. At the moment this is controlled via optcomp
configuration.
