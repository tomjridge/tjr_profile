open Intf_
open Optcomp_config

(*
let iter_opt (f:'a -> 'a option) = 
  let rec loop x = 
    match f x with
    | None -> x
    | Some x -> loop x
  in
  fun x -> loop x
*)


(** Intern (allocate an integer for) objects FIXME move to tjr_lib *)
module Make_intern(S:sig type t end) = struct
  (* open S *)
  let to_int = Hashtbl.create 100
  let from_int = Hashtbl.create 100
  let free = ref 1 (* reserve 0 for special cases *)

  let t2i s = Hashtbl.find to_int s
  let t2i_opt s = Hashtbl.find_opt to_int s

  let i2t i = Hashtbl.find from_int i
  let i2t_opt i = Hashtbl.find_opt from_int i

  (** Intern an object (allocate an integer for it) *)
  let intern (s:S.t) = 
    t2i_opt s |> function
    | None -> 
      let n = !free in
      Hashtbl.add to_int s n;
      (* Hashtbl.add to_int (prime s) (-1*n); (\* add s' as -n *\) *)
      Hashtbl.add from_int n s;
      (* Hashtbl.add from_int (-1*n) (prime s); *)
      free:=n + 1;
      n
    | Some i -> i
end

(* similar, but adding s->n also adds s'->-n; useful for making pairs
   of marks eg for begin and end of a function *)
module Make_intern_2(S:sig type t val prime: t -> t end) = struct
  open S
  let to_int = Hashtbl.create 100
  let from_int = Hashtbl.create 100
  let free = ref 1 (* reserve 0 for special cases *)

  let t2i s = Hashtbl.find to_int s
  let t2i_opt s = Hashtbl.find_opt to_int s

  let i2t i = Hashtbl.find from_int i
  let i2t_opt i = Hashtbl.find_opt from_int i

  (** Intern an object (allocate an integer for it) *)
  let intern (s:S.t) = 
    t2i_opt s |> function
    | None -> 
      let n = !free in
      Hashtbl.add to_int s n;
      Hashtbl.add to_int (prime s) (-1*n); (* add s' as -n *)
      Hashtbl.add from_int n s;
      Hashtbl.add from_int (-1*n) (prime s);
      free:=n + 1;
      n
    | Some i -> i
end


module Intern = struct
  include Make_intern_2(struct type t = string let prime s = s^"'" end)
  let s2i = t2i
  let s2i_opt = t2i_opt
  let i2s = i2t
  let i2s_opt = i2t_opt
end



(** Measure execution time, and print result on output
   immediately. This is not affected by optcomp config. *)
let measure_execution_time_and_print msg f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  Printf.printf "%s %d\n" msg (b-a);
  r

(** Measure the execution time of a function, and return the function
   result and the execution time. This is not affected by optcomp
   config. *)
let measure_execution_time f =
  let a = now () in
  f () |> fun r -> 
  let b = now () in
  let t = b - a in
  Timed_result.{result=r;time=t}
