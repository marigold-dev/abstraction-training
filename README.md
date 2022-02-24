# Soul Removal

The purpose of this training is to understand the module system of OCaml and to train to use it.

## Preparation

Pre-requisite:
- Install [esy.sh](esy.sh) : `npm i -g esy`

- Clone this repository
- run `esy` 


## Basics

In `lib/soul.ml`, you can define a (bad) type to descibe complex numbers in algebraic form and its addition:

```ocaml
type complex = { r : int ; i: int}

let add x y = {r = x.r + y.r ; i = x.i + y.i}
let ( + ) = add
let _complex_val = { r = 2 ; i = 0 } + { r = 3 ; i = 5
```

Sadly when you write:

```OCaml
let foo = 3 + 3
```

You get

```sh
let foo = 3 + 3
              ^
Error: This expression has type int but an expression was expected of type
         complex
```

**OCaml uses lexical scoping which means that our addition is shadowing the integer addition from OCaml.**

### Namespacing

A namespace provides a set of names that are grouped together, are usually logically related, and are distinct from other namespaces. That enables a name `alice` in one namespace to have a distinct meaning from `alice` in another namespace. A namespace is thus a scoping mechanism. Namespaces are essential for modularity.

A primary motivation for modular programming is to package together related definitions (such as the definitions of a data type and associated operations over that type) and enforce a consistent naming scheme for these definitions. Such a package is called a module structure and is introduced by the `struct…end` construct. That way we can say OCaml module are a namespacing system.

---

#### Exercice0:

Create a `ComplexM` module wich scopes our type and its operation

---

### Keeping things private

Signatures are interfaces for structures. A signature specifies which components of a structure are accessible from the outside, and with which type. It can be used to hide some components of a structure (e.g. local function definitions) or export some components with a restricted type. 

Right now our module signature is infered by OCaml as
```ocaml
sig
  type t = { r : int; i : int; }
  val add : t -> t -> t
  val ( + ) : t -> t -> t
  val _complex_val : t
end
```

---

#### Exercice 1:

Create a module signature for the module `ComplexM` which is the signature for the Monoïd of the complex number set with the addition. It means, it only exposes to the outside the type `t` and the infix operator for addition `+`

---

From now everything is in the same place. 

---

#### Exercice 2:

Create a new file `number.ml` with a sub-module `ComplexM`  

---

### Access to your things

There is several way to access the content of a module from another.

#### open vs include

The include and open statements are quite similar, but they have a subtly different effect on a structure. Consider this code:
```ocaml
module M = struct
  let x = 0
end

module N = struct
  include M
  let y = x + 1
end

module O = struct
  open M
  let y = x + 1
end
```
```ocaml
module M : sig val x : int end

module N : sig val x : int val y : int end

module O : sig val y : int end
```
open `M` imports definitions from `M` and makes them available for local consumption, but they aren’t exported to the outside world. Whereas include `M` imports definitions from `M`, makes them available for local consumption, and additionally exports them to the outside world.

> `open` a module enables lighter access to its components whereas `include` copy the components of a module inside another module

---

#### Exercice 3
Create a new module `ComplexG` which is an algrebraic group for the complex number set with the addition. A group is a monoïd whith an `identity` element and an `inverse` element.

> For the complex addition:
> - (0, 0) is the neutral additive element
> -  (-a, i(-b)) is the inverse element of (a, i b)

---

#### opening

Opening a module brings all identifier defined inside the module in the scope of the currrent structure:
```ocaml
open Number.ComplexG

(* here `t` and `+` comes from the ComplexG module *)
```

Opened modules can shadow identifiers present in the current scope, potentially leading to confusing errors as previously shown.

To avoid unwanted shadowing we can also namespace everything:
```ocaml
let zero =
  Number.ComplexG.( + ) Number.ComplexG.identity
    Number.ComplexG.{ r = 2; i = 3 }
```
But that's quite boring, so we can prefere to open module locally:
```ocaml
let zero = 
    Number.ComplexG.(
        (* here you can access any identifier from ComplexG module *)
        identity + identity
    )
```
Parenthesis management is a hell, so we would rather use the `let open` syntax:
```ocaml
let zero = 
    let open Number.ComplexG in
    identity + identity
```

Another common tactic is also to use module aliasing:
```ocaml
module C = Number.ComplexG
let zero = C.identity
```

Sometime you want to extend a module but you neither can modify the original code nor want to create a new module. That's ok:
```ocaml
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
```

## Abstraction



- Abstratcion
    - common interface for multiple modules
        - functorize the test
        - functorize the use
    - separate interfaces for a single module
        - define a raw module that matches


RAW si INT and you may have multiple interface

- Contracts
    - FSM
    - invariancts in the module (fail as early as possible)



## References
- [OCaml Manual](https://ocaml.org/manual/moduleexamples.html#)
- [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/chapters/modules/intro.html)
- [OCaml Real World](https://dev.realworldocaml.org/files-modules-and-programs.html)