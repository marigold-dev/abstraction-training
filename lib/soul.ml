type complex = {
  r : int;
  i : int;
}

let add x y = { r = x.r + y.r; i = x.i + y.i }
let ( + ) = add
let identity = { r = 0; i = 0 }
let _complex_val = { r = 2; i = 0 } + { r = 3; i = 5 }