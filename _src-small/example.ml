(** Example of chosing between stub and real impls at runtime *)

module Example() = struct

  module X : Small_intf.T = 
    (val 
      (if 1 = 0 (* or ENVVAR=... *) then (module Small.Make_2) else (module Small.Make_3)) 
      : Small_intf.T)

end
