

Question
========
Compute the Hessian of the function
$$
\begin{aligned}
  f(x_1, x_2) = 7 x_1^{2} + 5  x_1  x_2 + 3  x_2^{2}
\end{aligned}
$$
at $(x_1, x_2) = (1, 4)$.
What is the value of the upper left element?

Answerlist
----------
* $6$
* $7$
* $14$
* $5$
* $-19$

Solution
========
The first-order partial derivatives are 
$$
\begin{aligned}
  f'_1(x_1, x_2) &= 14 x_1 + 5 x_2  \\
  f'_2(x_1, x_2) &= 5 x_1 + 6 x_2
\end{aligned}
$$
and the second-order partial derivatives are
$$
\begin{aligned}
  f''_{11}(x_1, x_2) &= 14\\
  f''_{12}(x_1, x_2) &= 5\\
  f''_{21}(x_1, x_2) &= 5\\
  f''_{22}(x_1, x_2) &= 6
\end{aligned}
$$

Therefore the Hessian is
$$
\begin{aligned}
  f''(x_1, x_2) = \left( \begin{array}{rr} 14 &  5 \\  5 &  6 \end{array} \right)
\end{aligned}
$$
independent of $x_1$ and $x_2$. Thus, the upper left element is:
$f''_{11}(1, 4) = 14$.


Answerlist
----------
* False
* False
* True
* False
* False

Meta-information
================
extype: schoice
exsolution: 00100
exname: Hessian
