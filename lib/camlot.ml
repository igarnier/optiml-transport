open Bigarray

type mat = (float, float64_elt, c_layout) Array2.t

type vec = (float, float64_elt, c_layout) Array1.t

(* must match EMD.h order *)
type result_internal =
  | Camlot_Infeasible
  | Camlot_Optimal
  | Camlot_Unbounded
  | Camlot_Max_iter_reached

type result =
  | Infeasible
  | Unbounded
  | Optimal of { cost : float; coupling : mat; u : vec; v : vec }
  | Max_iter_reached of { cost : float; coupling : mat; u : vec; v : vec }

type fref = { mutable field : float }

external kanto_solve :
  vec -> vec -> mat -> mat -> vec -> vec -> fref -> int -> result_internal
  = "camlot_stub_bytecode" "camlot_stub_native"

(* let kantorovich_raw x y d num_iter =
 *   let n1     = Array1.dim x in
 *   let n2     = Array1.dim y in
 *   let gamma  = Array2.create Float64 c_layout n1 n2 in
 *   let u      = Array1.create Float64 c_layout n1 in
 *   let v      = Array1.create Float64 c_layout n2 in
 *   let cost   = { field = -. 1.0 } in
 *   let result = kanto_solve x y d gamma u v cost num_iter in
 *   (result, gamma, u, v, cost.field) *)

let kantorovich ~x ~y ~d ~num_iter =
  let n1 = Array1.dim x in
  let n2 = Array1.dim y in
  let gamma = Array2.create Float64 c_layout n1 n2 in
  let u = Array1.create Float64 c_layout n1 in
  let v = Array1.create Float64 c_layout n2 in
  let cost = { field = -1.0 } in
  let result = kanto_solve x y d gamma u v cost num_iter in
  match result with
  | Camlot_Infeasible -> Infeasible
  | Camlot_Unbounded -> Unbounded
  | Camlot_Optimal -> Optimal { cost = cost.field; coupling = gamma; u; v }
  | Camlot_Max_iter_reached ->
      Max_iter_reached { cost = cost.field; coupling = gamma; u; v }
