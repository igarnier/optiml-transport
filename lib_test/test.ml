module type Metric_S = sig
  type t

  val dist : t -> t -> float
end

(* A probability on a metric space is given by an array of elements (its support) together with an array of mass *)
module Giry (X : Metric_S) = struct
  type t = { support : X.t array; mass : Camlot.vec }

  let dist pr1 pr2 =
    let len1 = Array.length pr1.support in
    let len2 = Array.length pr2.support in
    let supp1 = pr1.support in
    let supp2 = pr2.support in
    let d =
      Numerics.Float64.Mat.init ~lines:len1 ~cols:len2 ~f:(fun i j ->
          X.dist supp1.(i) supp2.(j))
    in
    match Camlot.kantorovich ~x:pr1.mass ~y:pr2.mass ~d ~num_iter:100 with
    | Camlot.Infeasible | Camlot.Unbounded ->
        failwith "infeasible or unbounded problem"
    | Camlot.Optimal { cost; _ } | Camlot.Max_iter_reached { cost; _ } -> cost

  let delta (x : X.t) =
    { support = [| x |]; mass = Numerics.Float64.Vec.of_array [| 1.0 |] }
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

let () =
  Format.printf
    "distance: %f\n"
    (GR2.dist
       (GR2.delta { R2.x = 0.0; y = 0.0 })
       (GR2.delta { R2.x = 1.0; y = 1.0 }))
