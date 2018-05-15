


Question
========

Given the following information:

|                  |     |                  |     |                  |   |            |
|:----------------:|:---:|:----------------:|:---:|:----------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![banana](banana.png){width="0.85cm"} | = | $564$ |
| ![banana](banana.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $873$ |
| ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $864$ |

Compute:

|              |     |              |     |              |   |            |
|:------------:|:---:|:------------:|:---:|:------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = | $\text{?}$ |

Answerlist
----------
* $394$
* $555$
* $507$
* $873$
* $594$

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
\left( \begin{array}{rrr} 2 & 0 & 1 \\ 1 & 0 & 2 \\ 0 & 1 & 2 \end{array} \right) \cdot \left( \begin{array}{r} x_1 \\ x_2 \\ x_3 \end{array} \right) & = & \left( \begin{array}{r} 564 \\ 873 \\ 864 \end{array} \right)
\end{aligned}
$$
This can be solved using any solution algorithm, e.g., elimination:
$$
x_1 = 85, \, x_2 = 76, \, x_3 = 394.
$$
Based on the three prices for the different fruits it is straightforward to
compute the total price of the fourth fruit basket via:

|              |     |              |     |              |   |            |
|:------------:|:---:|:------------:|:---:|:------------:|:-:|-----------:|
| ![banana](banana.png){width="0.85cm"} | $+$ | ![orange](orange.png){width="0.85cm"} | $+$ | ![pineapple](pineapple.png){width="0.85cm"} | = |            |
| $x_1$        | $+$ | $x_2$        | $+$ | $x_3$        | = |            |
| $85$   | $+$ | $76$   | $+$ | $394$   | = | $555$  |

Answerlist
----------
* False
* True
* False
* False
* False


Meta-information
================
exname: Fruit baskets (single-choice)
extype: schoice
exsolution: 01000

