

Question
========

A firm has the following production function:
$$
F(K,L)= K L^{2}.
$$
The price for one unit of _capital_ is $p_K = 13$ 
and the price for one unit of _labor_ is $p_L = 13$.
Minimize the costs of the firm considering its production function and given a target production output of 430 units.

How high are in this case the minimal costs?

Solution
========
_Step 1_: Formulating the minimization problem.
$$
\begin{aligned}
\min_{K,L} C(K,L) & = p_K K + p_L L\\
 & = 13 K + 13 L\\
\mbox{subject~to:} &  F(K,L) = Q \\
& K L^{2} = 430 
\end{aligned}
$$
_Step 2_: Lagrange function.
$$
\begin{aligned}
\mathcal{L}(K, L, \lambda) & = C(K, L) - \lambda (F(K, L) - Q) \\
  & = 13 K + 13 L - \lambda (K L^{2} -430)
\end{aligned}
$$
_Step 3_: First order conditions.
$$
\begin{aligned}
\frac{\partial {\mathcal {L}}}{\partial K} & = 13 - \lambda L^{2} = 0\\
\frac{\partial {\mathcal {L}}}{\partial L} & = 13 - {2} \lambda K L^{2 - 1} = 0 \\
\frac{\partial {\mathcal {L}}}{\partial \lambda} & = -(K L^{2}-430) = 0
\end{aligned}
$$
_Step 4_: Solve the system of equations for $K$, $L$, and $\lambda$.

Solving the first two equations for $\lambda$ and equating them gives:
$$
\begin{aligned}
\frac{13}{L^{2}} & = \frac{13}{{2} K L^{2 - 1}}\\
K & = \frac{13}{2 \cdot 13} \cdot L^{2 - (2 - 1)}\\
K & = \frac{13}{26} \cdot L
\end{aligned}
$$
Substituting this in the optimization constraint gives:
$$
\begin{aligned}
K L^{2} & = 430\\
\left(\frac{13}{26}\cdot L \right) L^{2} & = 430\\
\frac{13}{26} L^{3} & = 430\\
L & = \left(\frac{26}{13} \cdot 430\right)^{\frac{1}{3}} = 9.5096854 \approx 9.51\\
K & = \frac{13}{26} \cdot L = 4.7548427 \approx 4.75
\end{aligned}
$$

The minimal costs can be obtained by substituting the optimal factor combination in the objective function:
$$
\begin{aligned}
C(K, L) & = 13 K + 13 L\\
        & = 61.812955 + 123.62591 \\
        & = 185.438865 \approx 185.44
\end{aligned}
$$

Given the target output, the minimal costs are $185.44$.
\
![](contourplot-1.svg)


Meta-information
================
extype: num
exsolution: 185.44
exname: Lagrange cost minimization
extol: 0.01
