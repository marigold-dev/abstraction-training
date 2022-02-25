type complex = {
  r : int;
  i : int;
}

let add x y = { r = x.r + y.r; i = x.i + y.i }
let ( + ) = add
let identity = { r = 0; i = 0 }
let _complex_val = { r = 2; i = 0 } + { r = 3; i = 5 }

module Make_index (Unit : sig end) : sig
  type t

  val allocate : unit -> t
end = struct
  type t = int

  let id = ref 0

  let allocate () =
    let () = incr id in
    !id
end

module Empty = struct end
module Index1 = Make_index (Empty)
module Index2 = Make_index (Empty)

let _ = assert false
