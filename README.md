# Module Training

The purpose of this training is to understand the module system of OCaml and to train to use it.

## Preparation

Pre-requisite:
- Install [esy.sh](esy.sh) : `npm i -g esy`

- Clone this repository
- run `esy` 


## Basics

In `lib/soul.ml`, we defined a type to describe complex numbers in algebraic form and its addition:

```ocaml
type complex = {
  r : int;
  i : int;
}

let add x y = { r = x.r + y.r; i = x.i + y.i }
let ( + ) = add
let identity = { r = 0; i = 0 }
let _complex_val = { r = 2; i = 0 } + { r = 3; i = 5 }
```

Sadly when you write:

```OCaml
let foo = 3 + 3
```

You get:

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

> By convenvention, the main type inside `My_module` is named `t` ✅ (neither `my_module` ❌ nor `foo` ❌)
---

### Keeping things private

Signatures are interfaces for structures. A signature specifies which components of a structure are accessible from the outside, and with which type. It can be used to hide some components of a structure (e.g. local function definitions) or export some components with a restricted type. 

Right now our module signature is inferred by OCaml as
```ocaml
sig
  type t = { r : int; i : int; }
  val add : t -> t -> t
  val ( + ) : t -> t -> t
  val identity: t
  val _complex_val : t
end
```

---

#### Exercice 1:

Create a module signature for the module `ComplexM` which is the signature for the Monoïd of the complex number set with the addition. It means, it only exposes to the outside the type `t` and the infix operator for addition `+` and the `identity` element.

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
Create a new module `ComplexG` which is an abelian group for the complex number set with the addition. A **group** is a **monoïd** :
- where the operation is commutative (so is the addition)
- with an `inverse` element.

> For the complex addition, (-a, i(-b)) is the inverse element of (a, i b)

---

#### Opening

Opening a module brings all identifier defined inside the module in the scope of the current structure:
```ocaml
open Number.ComplexG

(* here `t` and `+` comes from the ComplexG module *)
```

Opened modules can shadow identifiers present in the current scope, potentially leading to confusing errors as previously shown.

To avoid unwanted shadowing we can also namespace everything:
```ocaml
let a =
  Number.ComplexG.( + ) Number.ComplexG.identity
    Number.ComplexG.{ r = 2; i = 3 }
```
But that's quite boring, so we can prefer to open module locally:
```ocaml
let b = 
    Number.ComplexG.(
        (* here you can access any identifier from ComplexG module *)
        identity + identity
    )
```
Parenthesis management is a hell, so we would rather use the `let open` syntax:
```ocaml
let b = 
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

### Type abstraction

We often want to make the type `t` opaque to avoid to manipulate it directly. It gives to direct benefits: module's users don't have to known the internal representation of the type and module's developers may change the internal representation without the fear to beak anything that use the module.

```ocaml
module Stupid_int : sig
    type t 
end = struct
    type t = int
end
```

In this exemple, we made the type `SupidInt.t` abstract, other modules do not know its shape. But now it is no more possible to create a value from another module! We need a value creator. By convention, it is often named `make`

```ocaml
module Stupid_int : sig
    type t 
    val make : int -> t
end = struct
    type t = int
    let make v = v
end
```

---

#### Exercice 4:
Abstract the type `t` of the modules `ComplexM` and `ComplexG`

---

### Module type

It is possible to isolate the signature of a module in a `module type` definition.

```ocaml
module type STUPID_INT = sig
    type t 
    val make : int -> t
end

module Stupid_int : STUPID_INT = struct
    type t = int
    let make v = v
end

```

> That module type annotations are therefore not only about checking to see whether a module defines certain items. The annotations also hide items.

We could also validate witout hidding anything:
```ocaml
module type STUPID_INT = sig
    type t 
    val make : int -> t
end

module Stupid_int = struct
    type t = int
    let make v = v
end

module Stupid_int_checked : STUPID_INT = Stupid_int
```

Here `StupidIntChecked.t` is abstract while `StupidInt.t` isn't

Using module types is way to use the same abstraction among several modules:
```ocaml
module Stupid_nat : STUPID_INT = struct
    type t = int
    let make v = if v>= 0 then v else failwith "this is not a natural integer"
end

```

---

#### Exercice 5:
- Replace the signatures by the module types `MONOID` and `GROUP`
- Create new modules `NaturalM` and `NaturalG` that use those module types
- Create an exeption and a smart constructor to avoid to create non natural integers

---

### Raw modules

Since module type are a way to specify the signature for a module, it serves also to seperate signatures from a single module. Those kind of modules are usally named "raw modules":

```ocaml
module type MONOID =
sig
  type t
  val ( + ) : t -> t -> t
  val identity : t
end

module type GROUP =
sig
  include MONOID
  val inverse : t -> t
end

module Int_raw = struct
 type t = int
 let identity = 0
 let ( + ) = Stdlib.( + )
 let inverse v = -v
end

module IntM : MONOID = Int_raw
module IntG : GROUP = Int_raw
```

---

#### Exercice 6:
- Create `Complex_raw` and `Natural_raw`
- Redefine all previous module from raw modules

---

Sometime you may need to remove an abstraction:
```ocaml
module IntM_public : MONOID with type t = int = Int_raw
```

Now the `IntM_public` module's signature specifies that `t` and `int` are the same type. It exposes or shares that fact with the world, so we could call these “sharing constraints.”

## Functor

**A functor is simply a “function” from modules to modules**
OCaml’s type system is stratified: module values are distinct from other values, so functions from modules to modules cannot be written or used in the same way as functions from values to values. But conceptually, functors really are just functions.

>  OCaml functors are neither [Haskell Functor](https://wiki.haskell.org/Functor) nor [C++ functors](https://en.cppreference.com/w/cpp/utility/functional)

### Index module by values

Sometime you have several modules that share the same module type while they have different immutable value. It is practical to use a functor to produce them:
```ocaml
module type X = sig
  val x : int
end

module IncX (M : X) = struct
  let x = M.x + 1
end

module Zero = struct let x = 0 end
module One = IncX (Zero)
```

A more complex exemple would be to encode some game rules in the module system, i wrote a long exemple about how to [encode D&D 5e Races with functors](https://dev.to/oteku/dungeon-dragons-fonctors-5aka)


### Autoextension of modules

Functors give you a way of extending existing modules with new functionality in a standardized way.

If we have those module types:
```ocaml
module type MONOID = sig
  type t

  val ( + ) : t -> t -> t
  val identity : t
end

module type INVERSE = sig
  type t

  val inverse : t -> t
end

module type GROUP = sig
  include MONOID
  include INVERSE with type t := t
end
```

We can define a functor `Group.Make` that create a Group from a MONOID and a module with the inverse operation:

```ocaml

module Group = struct
  module Make (M : MONOID) (I : INVERSE) = struct
    type t = M.t

    let ( + ) = M.( + )
    let identity = M.identity
    let inverse = I.inverse
  end
end

module IntM : MONOID = struct
  type t = int

  let identity = 0
  let ( + ) = Stdlib.( + )
end

module IntI : INVERSE = struct
  type t = int

  let inverse v = -v
end

module IntG = Group.Make (IntM) (IntI)
```

> Regarding this purpose, we can achieve the same goal with raw modules and functors. In general, prefere the raw modules tactic because it have better performance at runtime. But sometime it is usefull to compose module, so it is important to know how to do it.

---

#### Exercice 7: 
Create the `NatG` and `CompG`, respectively natural integer group and complex group, using functors.

---

### Dependency injection

Makes the implementations of some components of a system swappable. This is particularly useful when you want to mock up parts of your system for testing and simulation purposes. 

---

#### Exercice 8: 

We want to create stack data datastructure.
Here an exemple of a possible module type for a stack:
```ocaml
module type STACK = sig
  type 'a t
  exception Empty
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val pop : 'a t -> 'a t
  val size : 'a t -> int
  val to_list : 'a t -> 'a list
end
```

We want to be able to create stacks in memory but also to be able to serialize them with Irmin or PostgreSQL. The serialization layer is a dependency we would like to inject to our system.

- Create a functor that produce a `STACK` datastructure.
- Create all is needed to implement the module `Stack_memory` of type `STACK` and produced using a functor

---

> Virtual modules while dune specific is another tactic to achieve dependency injection. They would be preferred to functor for that purpose performance-wise. That said, they make code harder to debug.

## More on modules

### First class module

OCaml is broken up into two parts: 
- a core language that is concerned with values and types
- a module language that is concerned with modules and module signatures. 

OCaml provides a way around this stratification in the form of first-class modules. First-class modules are ordinary values that can be created from and converted back to regular modules.  

First class module are convenient if you have a function that produce a module from a value, or a value from a module.

```ocaml
module type X = sig
  val x : int
end


let make_X_from_int (x : int) : (module X) =
  (module struct
    let x = x
  end)


let two_module_as_value = make_X_from_int 2
(* produce a a first-class module from a value *)

module Two = (val two_module_as_value)
(* unwrap the module in the module level *)

let make_int_from_X (module A : X) : int = A.x
let two = make_int_from_X (module Two)
(* produce a value from a first-class module *)
```

> Syntax is a little bit awkward and most designs that can be done with first-class modules can be stimulated without them.

### Generative Functors

OCaml functors are applicative: when run repeatedly on the same input module, they generate the same types in the output.
This is sometime not what you want:
```ocaml
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
```
This is supposed to generate a new unique-id module with a distinct type every time it’s called. But if you call it on the same module, you’ll get the same type, which is totally wrong.
If you would run this code in [utop](https://opam.ocaml.org/packages/utop/):
```ocaml
module Empty = struct end
module Index1 = Make_index (Empty)
module Index2 = Make_index (Empty);;
    
Index1.allocate () = Index2.allocate ();;
```
We get:
```ocaml
Index1.allocate () = Index2.allocate () ;;

- : bool = true
```
This is clearly not what we want. If we used different (but identical) modules as inputs, however, we would have had no problem.
```ocaml
module Index1 = Make_index (struct end)
module Index2 = Make_index (struct end);;
    
Index1.allocate () = Index2.allocate ();;
```
We get an Error:
```ocaml
Error: This expression has type Index2.t but an expression was expected of type
  Index1.t
```
Generative functors work like the second case every time, which for this kind of functor makes more sense. 
We can mark a functor as generative by having a last of the form `()`.

So, we can redo our example as follows:

```ocaml
module Make_index () : sig
  type t

  val allocate : unit -> t
end = struct
  type t = int

  let id = ref 0

  let allocate () =
    let () = incr id in
    !id
end
```
And now, there’s every invocation of this functor produces a fresh type.
```ocaml
module Index1 = Make_index ()
module Index2 = Make_index ();;
    
Index1.allocate () = Index2.allocate ();;
```
We get an Error:
```ocaml
Error: This expression has type Index2.t but an expression was expected of type
  Index1.t
```

 In OCaml, generative functors are used in general in combination with first class modules to have functions that generates a fresh type at each application. 
 This has various use cases (heterogeneous maps, emulating singletons types, ...). 
 In particular, this sentence from the manual is of importance: 
 > As a side-effect of this generativity, one is allowed to unpack first-class modules in the body of generative functors.

_If you loved [SML](https://smlfamily.github.io/), you can make all functors generatives by passing this option `-no-app-funct` to [ocamlopt](https://www.ocaml.org/releases/4.13/htmlman/native.html) ... but you wouldn't_

## Take aways

- Encode your invariants in the module
- Fail as fast as possible


## References
- [OCaml Manual](https://ocaml.org/manual/moduleexamples.html#)
- [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/chapters/modules/intro.html)
- [OCaml Real World](https://dev.realworldocaml.org/files-modules-and-programs.html)
- [Xavier Leroy's Paper on applicative functors - 1995](https://caml.inria.fr/pub/papers/xleroy-applicative_functors-popl95.pdf)