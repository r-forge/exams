


Question
========

For the matrix
$$
\begin{aligned}
  A &= \left( \begin{array}{rrrr}  16 & -12 & -12 & -16 \\ -12 &  25 &   1 &  -4 \\ -12 &   1 &  17 &  14 \\ -16 &  -4 &  14 &  57 \end{array} \right).
\end{aligned}
$$
compute the matrix $L = (\ell_{ij})_{1 \leq i,j \leq 4}$ from the
Cholesky decomposition $A = L L^\top$.

Which of the following statements are true?

Answerlist
----------
* $\ell_{41} \ge -4$
* $\ell_{33} \ge 2$
* $\ell_{11} \le 4$
* $\ell_{31} \ge -3$
* $\ell_{32} \ge -2$

Solution
========

The decomposition yields
$$
\begin{aligned}
  L &= \left( \begin{array}{rrrr}  4 &  0 &  0 &  0 \\ -3 &  4 &  0 &  0 \\ -3 & -2 &  2 &  0 \\ -4 & -4 & -3 &  4 \end{array} \right)
\end{aligned}
$$
and hence:

Answerlist
----------
* True. $\ell_{41} = -4$
* True. $\ell_{33} = 2$
* True. $\ell_{11} = 4$
* True. $\ell_{31} = -3$
* True. $\ell_{32} = -2$

Meta-information
================
extype: mchoice
exsolution: 11111
exname: Cholesky decomposition
