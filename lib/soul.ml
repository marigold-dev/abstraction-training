let foo = 3 + 3

let zero =
  Number.ComplexG.(
    (* here you can access any identifier from ComplexG module *)
    identity + identity)

let zero =
  Number.ComplexG.( + ) Number.ComplexG.identity
    Number.ComplexG.{ r = 2; i = 3 }

module C = Number.ComplexG

let zero = C.identity

let thats_ok =
  let open struct
    include Number.ComplexM

    let one = { r = 1; i = 1 }

    let ( * ) x y =
      let r = (x.r * y.r) - (x.i * y.i) in
      let i = Stdlib.( + ) (x.r * y.i) (x.i * y.r) in
      { r; i }
  end in
  one * one
