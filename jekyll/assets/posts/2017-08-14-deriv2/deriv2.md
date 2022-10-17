

Question
========
What is the derivative of $f(x) = x^{7} e^{3.9 x}$, evaluated at $x = 0.61$?

Answerlist
----------
* $3.89$
* $5.22$
* $4.23$
* $6.86$
* $3.01$

Solution
========
Using the product rule for $f(x) = g(x) \cdot h(x)$, where $g(x) := x^{7}$ and $h(x) := e^{3.9 x}$, we obtain
$$
\begin{aligned}
f'(x) &= [g(x) \cdot h(x)]' = g'(x) \cdot h(x) + g(x) \cdot h'(x) \\
      &= 7 x^{7 - 1} \cdot e^{3.9 x} + x^{7} \cdot e^{3.9 x} \cdot 3.9 \\
      &= e^{3.9 x} \cdot(7 x^6 + 3.9 x^{7}) \\
      &= e^{3.9 x} \cdot x^6 \cdot (7 + 3.9 x).
\end{aligned}
$$
Evaluated at $x = 0.61$, the answer is
$$ e^{3.9 \cdot 0.61} \cdot 0.61^6 \cdot (7 + 3.9 \cdot 0.61) = 5.215814. $$
Thus, rounded to two digits we have $f'(0.61) = 5.22$.

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
