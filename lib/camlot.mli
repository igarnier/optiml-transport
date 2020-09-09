type mat = (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array2.t

type vec = (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

(** Low-level interface to the optimal transportation solver. *)

type result_internal =
  | Camlot_Infeasible
  | Camlot_Optimal
  | Camlot_Unbounded
  | Camlot_Max_iter_reached

(** Only ever useful if you plan to use the stubs directly. This is used to store
    the cost of the transportation plan produced by [kanto_solve]. *)
type fref = { mutable field : float }

(** [kanto_solve x y D G u v cost num_iter] computes an optimal transportation plan from
    [x] to [y] according to the cost matrix [D]. The optimal plan is stored in the matrix [G],
    and the dual optimal variables (the "prices") are stored in [u] and [v].
    Note that [D] need not satisfy the triangle inequality.

    The cost associated to [G] is stored in the reference cell [cost]. [num_iter] specifies the
    maximum number of iterations of the algorithm. [kanto_solve] also returns the
    state of the solver at the end of the process as a value of type [result_internal].

    NB: [kanto_solve] does not allocate memory. All matrices and vectors must be
    preallocated by the user.
*)
external kanto_solve :
  vec -> vec -> mat -> mat -> vec -> vec -> fref -> int -> result_internal
  = "camlot_stub_bytecode" "camlot_stub_native"

(** High-level interface to the optimal transportation solver. *)

(** The [result] type encodes the outcome of solving an instance of the optimal mass transportation
    problem. *)
type result =
  | Infeasible
  | Unbounded
  | Optimal of { cost : float; coupling : mat; u : vec; v : vec }
  | Max_iter_reached of { cost : float; coupling : mat; u : vec; v : vec }

(** [kantorovich x y d num_iter] is a wrapper around [kanto_solve] which will
    allocate all intermediate structures for you. If you plan to perform a lot
    of calls to the solver for fixed sizes of [x] and [y] you might want to
    consider using the low-level interface, to avoid reallocating
    those intermediate structures. *)
val kantorovich : x:vec -> y:vec -> d:mat -> num_iter:int -> result
