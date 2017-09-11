


Question
========

An industry-leading company seeks a qualified candidate for a management position.
A management consultancy carries out an assessment center which concludes in making
a positive or negative recommendation for each candidate: From previous assessments they know that
of those candidates that are actually eligible for the position (event $E$) $74\%$
get a positive recommendation (event $R$). However, out of those candidates that are not eligible
$73\%$ get a negative recommendation. Overall, they know that only
$13\%$ of all job applicants are actually eligible.

What is the corresponding fourfold table of the joint probabilities? (Specify all entries in percent.)

Answerlist
----------
* $P(E \cap R)$
* $P(\overline{E} \cap R)$
* $P(E \cap \overline{R})$
* $P(\overline{E} \cap \overline{R})$


Solution
========

Using the information from the text, we can directly calculate the following joint probabilities:
$$
\begin{aligned}
  P(E \cap R) & =
    P(R | E) \cdot P(E) = 0.74 \cdot 0.13 = 0.0962 = 9.62\%\\
  P(\overline{E} \cap \overline{R}) & =
    P(\overline{R} | \overline{E}) \cdot P(\overline{E}) = 0.73 \cdot 0.87 = 0.6351 = 63.51\%.
\end{aligned}
$$
The remaining probabilities can then be found by calculating sums and differences in the fourfold table:

|               | $R$                | $\overline{R}$     | sum                |
|:-------------:|:------------------:|:------------------:|:------------------:|
|$E$            | **9.62** |  _3.38_  | **13.00** |
|$\overline{E}$ |  _23.49_  | **63.51** |  _87.00_  |
|sum            |  _33.11_  |  _66.89_  | **100.00** |

Answerlist
----------
* $P(E \cap R) =  9.62\%$
* $P(\overline{E} \cap R) = 23.49\%$
* $P(E \cap \overline{R}) =  3.38\%$
* $P(\overline{E} \cap \overline{R}) = 63.51\%$


Meta-information
================
extype: cloze
exsolution: 9.62|23.49|3.38|63.51
exclozetype: num|num|num|num
exname: fourfold
extol: 0.05
