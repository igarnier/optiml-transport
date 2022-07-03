module type Metric_S = sig
  type t

  val dist : t -> t -> float
end

(* A probability on a metric space is given by an array of elements (its support) together with an array of mass *)

(* The Giry functor is an endofunctor on the category of metric spaces, mapping a space to the
   space of Borel probability measures with the Wasserstein-Kantorovich metric. *)
module Giry (X : Metric_S) = struct
  type t = { support : X.t array; mass : Transport.vec }

  let dist pr1 pr2 =
    let len1 = Array.length pr1.support in
    let len2 = Array.length pr2.support in
    let supp1 = pr1.support in
    let supp2 = pr2.support in
    let d =
      Bigarray.Array2.create Bigarray.float64 Bigarray.c_layout len1 len2
    in
    for i = 0 to len1 - 1 do
      for j = 0 to len2 - 1 do
        d.{i, j} <- X.dist supp1.(i) supp2.(j)
      done
    done ;
    match Transport.kantorovich ~x:pr1.mass ~y:pr2.mass ~d ~num_iter:100 with
    | Transport.Infeasible | Transport.Unbounded ->
        failwith "infeasible or unbounded problem"
    | Transport.Optimal { cost; _ } | Transport.Max_iter_reached { cost; _ } ->
        cost

  let delta (x : X.t) =
    { support = [| x |];
      mass =
        Bigarray.Array1.of_array Bigarray.float64 Bigarray.c_layout [| 1.0 |]
    }
end

(* Testing Kantorovich in 1d (i.e. discrete probabilities on the reals) *)

module R2 = struct
  type t = { x : float; y : float }

  let dist a b =
    let dx = b.x -. a.x in
    let dy = b.y -. a.y in
    sqrt ((dx *. dx) +. (dy *. dy))
end

module GR2 = Giry (R2)

let eps_eq ?(eps = 0.0001) f1 f2 = abs_float (f1 -. f2) < eps

(* Dirac is an isometry from X to Giry(X) *)
let () =
  assert (
    eps_eq
      (GR2.dist
         (GR2.delta { R2.x = 0.0; y = 0.0 })
         (GR2.delta { R2.x = 1.0; y = 1.0 }))
      (sqrt 2.))
