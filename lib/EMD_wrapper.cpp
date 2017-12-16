/* This file is a c++ wrapper function for computing the transportation cost
 * between two vectors given a cost matrix.
 *
 * It was written by Antoine Rolet (2014) and mainly consists of a wrapper
 * of the code written by Nicolas Bonneel available on this page
 *          http://people.seas.harvard.edu/~nbonneel/FastTransport/
 *
 * It was then modified to make it more amenable to python inline calling by Rémi Flamary,
 * and subsequently adapted for OCaml by Ilias Garnier.
 *
 * Please give relevant credit to the original author (Nicolas Bonneel) if
 * you use this code for a publication.
 *
 */

/*
  MIT License

  Copyright (c) 2016 Rémi Flamary
  Copyright (c) 2017 Ilias Garnier

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

extern "C" {
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/bigarray.h>
}

#include "EMD.h"

extern "C" {

// X is a double array of size n1, the first marginal
// Y is a double array of size n2, the second marginal
// D is the cost matrix, of size n1 x n2, such that D[n][m] = D[i * n + j]
// G is the result coupling
// alpha, beta are the dual variables
// cost is the optimal cost
problem_type_t EMD_wrap(int n1, int n2, double *X, double *Y, double *D, double *G,
             double* alpha, double* beta, double *cost, int maxIter)  {
  // beware M and C are strored in row major C style!!!
  int n, m, i, cur;

  typedef FullBipartiteDigraph Digraph;
  DIGRAPH_TYPEDEFS(FullBipartiteDigraph);

  // Get the number of non zero coordinates for r and c
  n=0;
  for (int i=0; i<n1; i++) {
    double val=*(X+i);
    if (val>0) {
      n++;
    }else if(val<0){
      return INFEASIBLE;
    }
  }
  m=0;
  for (int i=0; i<n2; i++) {
    double val=*(Y+i);
    if (val>0) {
      m++;
    }else if(val<0){
      return INFEASIBLE;
    }
  }

  // Define the graph

  std::vector<int> indI(n), indJ(m);
  std::vector<double> weights1(n), weights2(m);
  Digraph di(n, m);
  NetworkSimplexSimple<Digraph,double,double, node_id_type> net(di, true, n+m, n*m, maxIter);

  // Set supply and demand, don't account for 0 values (faster)

  cur=0;
  for (int i=0; i<n1; i++) {
    double val=*(X+i);
    if (val>0) {
      weights1[ cur ] = val;
      indI[cur++]=i;
    }
  }

  // Demand is actually negative supply...

  cur=0;
  for (int i=0; i<n2; i++) {
    double val=*(Y+i);
    if (val>0) {
      weights2[ cur ] = -val;
      indJ[cur++]=i;
    }
  }


  net.supplyMap(&weights1[0], n, &weights2[0], m);

  // Set the cost of each edge
  for (int i=0; i<n; i++) {
    for (int j=0; j<m; j++) {
      double val=*(D+indI[i]*n2+indJ[j]);
      net.setCost(di.arcFromId(i*m+j), val);
    }
  }


  // Solve the problem with the network simplex algorithm

  int ret=net.run();
  if (ret==(int)net.OPTIMAL || ret==(int)net.MAX_ITER_REACHED) {
    *cost = 0;
    Arc a; di.first(a);
    for (; a != INVALID; di.next(a)) {
      int i = di.source(a);
      int j = di.target(a);
      double flow = net.flow(a);
      *cost += flow * (*(D+indI[i]*n2+indJ[j-n]));
      *(G+indI[i]*n2+indJ[j-n]) = flow;
      *(alpha + indI[i]) = -net.potential(i);
      *(beta + indJ[j-n]) = net.potential(j);
    }

  }

  return (problem_type_t)ret;
}


CAMLprim value camlot_stub_native(value X, value Y, value D, value G, value alpha, value beta, value cost, value max_iter)
{
  CAMLparam5(X,Y,D,G,alpha);
  CAMLxparam1(beta);
  CAMLxparam1(cost);
  CAMLxparam1(max_iter);
  
  double costv = 0.0d;

  int maxit = Int_val(max_iter);
 
  int result = EMD_wrap(Caml_ba_array_val(X)->dim[0],
                        Caml_ba_array_val(Y)->dim[1],
                        (double*) Caml_ba_data_val(X),
                        (double*) Caml_ba_data_val(Y),
                        (double*) Caml_ba_data_val(D),
                        (double*) Caml_ba_data_val(G),
                        (double*) Caml_ba_data_val(alpha),
                        (double*) Caml_ba_data_val(beta),
                        &costv,
                        Int_val(max_iter));

  Store_double_field(cost, 0, costv);

  CAMLreturn(Val_int(result));
}

CAMLprim value camlot_stub_bytecode(value * argv, int argn)
{
  return camlot_stub_native(argv[0], argv[1], argv[2], argv[3], argv[4],
                            argv[5], argv[6], argv[7]);
}

} // end of extern "C"
