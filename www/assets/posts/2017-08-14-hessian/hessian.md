

Question
========
Compute the Hessian of the function
$$
\begin{aligned}
  f(x_1, x_2) = -7 x_1^{2}  -5  x_1  x_2  -4  x_2^{2}
\end{aligned}
$$
at $(x_1, x_2) = (-2, 2)$.
What is the value of the upper left element?

Answerlist
----------
* $-8$
* $-5$
* $-16$
* $-14$
* $-4$

Solution
========
The first-order partial derivatives are 
$$
\begin{aligned}
  f'_1(x_1, x_2) &= -14 x_1  -5 x_2  \\
  f'_2(x_1, x_2) &= -5 x_1  -8 x_2
\end{aligned}
$$
and the second-order partial derivatives are
$$
\begin{aligned}
  f''_{11}(x_1, x_2) &= -14\\
  f''_{12}(x_1, x_2) &= -5\\
  f''_{21}(x_1, x_2) &= -5\\
  f''_{22}(x_1, x_2) &= -8
\end{aligned}
$$

Therefore the Hessian is
$$
\begin{aligned}
  f''(x_1, x_2) = \left( \begin{array}{rr} -14 &  -5 \\  -5 &  -8 \end{array} \right)
\end{aligned}
$$
independent of $x_1$ and $x_2$. Thus, the upper left element is:
$f''_{11}(-2, 2) = -14$.


Answerlist
----------
* False
* False
* False
* True
* False

Meta-information
================
extype: schoice
exsolution: 00010
exname: Hessian
