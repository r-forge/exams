

Question
========
What is the derivative of $f(x) = x^{8} e^{3.4 x}$, evaluated at $x = 0.7$?

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
Evaluated at $x = 0.7$, the answer is
$$ e^{3.4 \cdot 0.7} \cdot 0.7^7 \cdot (8 + 3.4 \cdot 0.7) = 9.236438. $$
Thus, rounded to two digits we have $f'(0.7) = 9.24$.

Meta-information
================
extype: num
exsolution: 9.24
exname: derivative exp
extol: 0.01
