module ComplexM : sig
  type t = {
    r : int;
    i : int;
  }

  val ( + ) : t -> t -> t
end = struct
  type t = {
    r : int;
    i : int;
  }

  let add x y = { r = x.r + y.r; i = x.i + y.i }
  let ( + ) = add
  let _foo = { r = 2; i = 0 } + { r = 3; i = 5 }
end

module ComplexG : sig
  include module type of ComplexM

  val identity : t
end = struct
  include ComplexM

  let identity = { r = 0; i = 0 }
end
