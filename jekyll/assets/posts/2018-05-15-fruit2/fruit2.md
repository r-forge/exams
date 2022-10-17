


Question
========

Given the following information:

|                  |     |                  |     |                  |   |            |
|:----------------:|:---:|:----------------:|:---:|:----------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $909$ |
| ![banana](banana.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![banana](banana.png){width="0.85cm"} | = | $516$ |
| ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $921$ |

Compute:

|              |     |              |     |              |   |            |
|:------------:|:---:|:------------:|:---:|:------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $\text{?}$ |

Answerlist
----------
* $434$
* $378$
* $921$
* $678$
* $528$

Solution
========

The information provided can be interpreted as the price for three fruit baskets
with different combinations of the three fruits. This corresponds to a system of
linear equations where the price of the three fruits is the vector of unknowns $x$:

|         |              |         |              |         |              |
|--------:|:-------------|--------:|:-------------|--------:|:-------------|
| $x_1 =$ | ![banana](banana.png){width="0.85cm"} | $x_2 =$ | ![orange](orange.png){width="0.85cm"} | $x_3 =$ | ![pineapple](pineapple.png){width="0.85cm"} |

The system of linear equations is then:
$$
\begin{aligned}
\left( \begin{array}{rrr} 1 & 0 & 2 \\ 2 & 0 & 1 \\ 0 & 1 & 2 \end{array} \right) \cdot \left( \begin{array}{r} x_1 \\ x_2 \\ x_3 \end{array} \right) & = & \left( \begin{array}{r} 909 \\ 516 \\ 921 \end{array} \right)
\end{aligned}
$$
This can be solved using any solution algorithm, e.g., elimination:
$$
x_1 = 41, \, x_2 = 53, \, x_3 = 434.
$$
Based on the three prices for the different fruits it is straightforward to
compute the total price of the fourth fruit basket via:

|              |     |              |     |              |   |            |
|:------------:|:---:|:------------:|:---:|:------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = |            |
| $x_1$        | $+$ | $x_2$        | $+$ | $x_3$        | = |            |
| $41$   | $+$ | $53$   | $+$ | $434$   | = | $528$  |

Answerlist
----------
* False
* False
* False
* False
* True


Meta-information
================
exname: Fruit baskets (single-choice)
extype: schoice
exsolution: 00001

