
(* NOTE defns from tjr_lib *)

(** Essentially the Y combinator; useful for anonymous recursive
    functions. The k argument is the recursive callExample:

    {[
      iter_k (fun ~k n -> 
          if n = 0 then 1 else n * k (n-1))

    ]}


*)
let iter_k f (x:'a) =
  let rec k x = f ~k x in
  k x

let pad_to ?(trim=true) n s = 
  let l = String.length s in
  match Pervasives.compare l n with
  | 0 -> s
  | x when x < 0 -> (* l < n; pad *)
    s^(String.make (n-l) ' ')
  | _ -> (* l > n; maybe trim *)
    (if trim then String.sub s 0 n else s)

(** Formatting of a table (a list of string list). By default, this
    uses "|" as a separator, and examines all lines before computing
    the pad *)
let pp_csv' csv = 
  (* the max length of each col *)
  let tbl = Hashtbl.create 100 in
  csv |> List.iter (fun row -> 
      row |> List.iteri (fun col s -> 
          Hashtbl.find_opt tbl col |> function
          | None -> Hashtbl.replace tbl col (String.length s)
          | Some i -> Hashtbl.replace tbl col (max (String.length s) i)));
  csv |> List.map (fun row -> 
      row |> List.mapi (fun col s -> 
          Hashtbl.find tbl col |> fun n -> 
          s |> pad_to n))

let pp_csv ?(sep=" | ") ?(frame=true) csv = 
  csv |> pp_csv' |> fun csv -> 
  csv |> List.iter (fun row -> 
      row |> String.concat sep |> fun s -> 
      if frame then Printf.printf "%s %s %s\n" sep s sep
      else Printf.printf "%s\n" s)
