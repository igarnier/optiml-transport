open Bigarray

(* must match EMD.h order *)
type result =
  | Infeasible
  | Optimal
  | Unbounded
  | MaxIterReached

type mat = (float, float64_elt, c_layout) Array2.t
type vec = (float, float64_elt, c_layout) Array1.t

type fref = 
  {
    mutable field : float;
  }

external kanto_solve : vec -> vec -> mat -> mat -> vec -> vec -> fref -> int -> result = "camlot_stub_bytecode" "camlot_stub_native"

let kantorovich x y d num_iter =
  let n1     = Array1.dim x in
  let n2     = Array1.dim y in
  let gamma  = Array2.create Float64 c_layout n1 n2 in
  let u      = Array1.create Float64 c_layout n1 in
  let v      = Array1.create Float64 c_layout n2 in
  let cost   = { field = -. 1.0 } in
  let result = kanto_solve x y d gamma u v cost num_iter in
  (result, gamma, u, v, cost.field)
