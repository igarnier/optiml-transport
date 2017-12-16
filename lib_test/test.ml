open Bigarray
open Owl
open Batteries
open Gromov

open Camlot



let matrix_of_genarray (arr : (float, float64_elt, c_layout) Genarray.t) =
  let dims = Genarray.dims arr in
  reshape_2 arr dims.(0) dims.(1)


(* A probability on a metric space is given by an array of elements (its support) together with an array of mass *)
module Giry(X : Metric.S) =
  struct

    type t =
      {
        support : X.t array;
        mass    : vec;
      }

    let dist pr1 pr2 =
      let len1  = Array.length pr1.support in
      let len2  = Array.length pr2.support in
      let supp1 = pr1.support in
      let supp2 = pr2.support in
      let d =
        Mat.init_nd len1 len2 (fun i j ->
            X.dist supp1.(i) supp2.(j)
          )
      in
      let d = matrix_of_genarray d in
      match kantorovich pr1.mass pr2.mass d 100 with
      | Camlot.Infeasible | Camlot.Unbounded ->
        failwith "infeasible or unbounded problem"
      | Camlot.Optimal { cost }
      | Camlot.MaxIterReached { cost } ->
        cost

    let delta (x : X.t) =
      {
        support = [| x |];
        mass    = Array1.of_array Float64 c_layout [| 1.0 |]
      }

  end



(* Discretising a distance function on the naturals as a matrix *)
let discretise d size =
  Mat.init_nd size size d

(* Testing Kantorovich in 1d (i.e. discrete probabilities on the reals) *)

module  R2 = Gromov.Spaces.R2
module GR2 = Giry(R2)

let _ =
  Printf.printf "distance: %f\n" (GR2.dist (GR2.delta { R2.x = 0.0; y = 0.0 }) (GR2.delta { R2.x = 1.0; y = 1.0 }))
