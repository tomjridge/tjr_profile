(** Very basic profiling support on top of core *)

module Small_intf = Small_intf

(** Standard implementation *)
module Small_impl : Small_intf.T = Small.Make_2

(** Stub implementation *)
module Small_stub : Small_intf.T = Small.Make_3

module Private = struct

  module Small = Small

end
