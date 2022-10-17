


Question
========

For the matrix
$$
\begin{aligned}
  A &= \left( \begin{array}{rrrr}  16 &   4 &  16 &  -4 \\   4 &   5 &   6 &  -9 \\  16 &   6 &  33 & -28 \\  -4 &  -9 & -28 &  58 \end{array} \right).
\end{aligned}
$$
compute the matrix $L = (\ell_{ij})_{1 \leq i,j \leq 4}$ from the
Cholesky decomposition $A = L L^\top$.

Which of the following statements are true?

Answerlist
----------
* $\ell_{41} = -1$
* $\ell_{44} < 4$
* $\ell_{22} = -1$
* $\ell_{11} > 0$
* $\ell_{32} \le 1$

Solution
========

The decomposition yields
$$
\begin{aligned}
  L &= \left( \begin{array}{rrrr}  4 &  0 &  0 &  0 \\  1 &  2 &  0 &  0 \\  4 &  1 &  4 &  0 \\ -1 & -4 & -5 &  4 \end{array} \right)
\end{aligned}
$$
and hence:

Answerlist
----------
* True. $\ell_{41} = -1$
* False. $\ell_{44} = 4 \not< 4$
* False. $\ell_{22} = 2 \not= -1$
* True. $\ell_{11} = 4$
* True. $\ell_{32} = 1$

Meta-information
================
extype: mchoice
exsolution: 10011
exname: Cholesky decomposition
