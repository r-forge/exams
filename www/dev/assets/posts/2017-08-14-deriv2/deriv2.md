

Question
========
What is the derivative of $f(x) = x^{8} e^{3.4 x}$, evaluated at $x = 0.8$?

Answerlist
----------
* $25.47$
* $34.13$
* $38.76$
* $28.02$
* $28.97$

Solution
========
Using the product rule for $f(x) = g(x) \cdot h(x)$, where $g(x) := x^{8}$ and $h(x) := e^{3.4 x}$, we obtain
$$
\begin{aligned}
f'(x) &= [g(x) \cdot h(x)]' = g'(x) \cdot h(x) + g(x) \cdot h'(x) \\
      &= 8 x^{8 - 1} \cdot e^{3.4 x} + x^{8} \cdot e^{3.4 x} \cdot 3.4 \\
      &= e^{3.4 x} \cdot(8 x^7 + 3.4 x^{8}) \\
      &= e^{3.4 x} \cdot x^7 \cdot (8 + 3.4 x).
\end{aligned}
$$
Evaluated at $x = 0.8$, the answer is
$$ e^{3.4 \cdot 0.8} \cdot 0.8^7 \cdot (8 + 3.4 \cdot 0.8) = 34.127595. $$
Thus, rounded to two digits we have $f'(0.8) = 34.13$.

Answerlist
----------
* False
* True
* False
* False
* False

Meta-information
================
extype: schoice
exsolution: 01000
exname: derivative exp
