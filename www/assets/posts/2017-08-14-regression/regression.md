

Question
========

For 60 firms the number of employees $X$ and the amount of
expenses for continuing education $Y$ (in EUR) were recorded. The
statistical summary of the data set is given by:

|          | Variable $X$ | Variable $Y$ |
|:--------:|:------------:|:------------:|
| Mean     | 56       | 259       |
| Variance | 113     | 1792     |

The correlation between $X$ and $Y$ is equal to 0.52.

Estimate the expected amount of money spent for continuing education
by a firm with 62 employees using least squares regression.


Solution
========

First, the regression line $y_i = \beta_0 + \beta_1 x_i +
\varepsilon_i$ is determined.  The regression coefficients are given by:
\begin{eqnarray*}
&& \hat \beta_1 = r \cdot \frac{s_y}{s_x} = 
0.52 \cdot \sqrt{\frac{1792}{113}} = 2.07078, \\
&& \hat \beta_0 = \bar y - \hat \beta_1 \cdot \bar x = 
259 - 2.07078 \cdot 56 = 143.03654.
\end{eqnarray*}

The estimated amount of money spent by a firm with
62 employees is then given by:
\begin{eqnarray*}
\hat y = 143.03654 + 2.07078 \cdot 62 = 271.425.
\end{eqnarray*}

Meta-information
================
extype: num
exsolution: 271.425
exname: Prediction
extol: 0.01
