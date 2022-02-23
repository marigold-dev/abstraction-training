# Soul Removal

The purpose of this training is to understand the module system of OCaml and to train to use it.

## Preparation

Pre-requisite:
- Install [esy.sh](esy.sh) : `npm i -g esy`

- Clone this repository
- run `esy` 


## Basics




Exercice: you have something that don't work
- You have VARIOUS declaration
    - You need them in the scope
        - keep thing private
            - Signature
            - open struct end (when you don't have a signature)
    - Have access to other thing
        - open 
        - let open, etc.
    - expose things
        - include
        - redefine

- Abstratcion
    - common interface for multiple modules
        - functorize the test
        - functorize the use
    - separate interfaces for a single module
        - define a raw module that matches


- Contracts
    - FSM
    - invariancts in the module (fail as early as possible)

## Primer on module
-> Basics
    -> NOT ALLOWED TO USE OBJECT BEFORE YOU UNDERSTAND MODULES
    -> struct vs sig
    -> ml vs mli
        -> not for common use case, use library
        -> .mli not for common use case
            -> separate compilation (faster build time)
            -> virtual libraries
                -> use functors by default
        -> .mli for library interfaces
        -> .mld : not production ready ?

-> namespacing
    -> open vs include
    -> let open ; M.() ; M.{}
    -> open struct end
    -> M.Construyctor, M.type
    
-> abstraction = don't care about implementation
    -> type abstraction

-> contracts = constructors/destructors/accessors
    -> pure code vs effectful
        - exceptions
        - mutation
    -> generative vs applicative functors
        -> MakeIndex() => generative functor

-> hacks
    -> `module type of` (include hacks)

-> type substitutions


