


Question
========

An industry-leading company seeks a qualified candidate for a management position.
A management consultancy carries out an assessment center which concludes in making
a positive or negative recommendation for each candidate: From previous assessments they know that
of those candidates that are actually eligible for the position (event $E$) $66\%$
get a positive recommendation (event $R$). However, out of those candidates that are not eligible
$65\%$ get a negative recommendation. Overall, they know that only
$9\%$ of all job applicants are actually eligible.

What is the corresponding fourfold table of the joint probabilities? (Specify all entries in percent.)

|               | $R$           | $\overline{R}$ | sum           |
|:-------------:|:-------------:|:--------------:|:-------------:|
|$E$            | ##ANSWER1##\% | ##ANSWER3##\%  | ##ANSWER7##\% |
|$\overline{E}$ | ##ANSWER2##\% | ##ANSWER4##\%  | ##ANSWER8##\% |
|sum            | ##ANSWER5##\% | ##ANSWER6##\%  | ##ANSWER9##\% |

Answerlist
----------
* 
* 
* 
* 
* 
* 
* 
* 
* 


Solution
========

Using the information from the text, we can directly calculate the following joint probabilities:
$$
\begin{aligned}
  P(E \cap R) & =
    P(R | E) \cdot P(E) = 0.66 \cdot 0.09 = 0.0594 = 5.94\%\\
  P(\overline{E} \cap \overline{R}) & =
    P(\overline{R} | \overline{E}) \cdot P(\overline{E}) = 0.65 \cdot 0.91 = 0.5915 = 59.15\%.
\end{aligned}
$$
The remaining probabilities can then be found by calculating sums and differences in the fourfold table:

|               | $R$                | $\overline{R}$     | sum                |
|:-------------:|:------------------:|:------------------:|:------------------:|
|$E$            | **5.94** |  _3.06_  | **9.00** |
|$\overline{E}$ |  _31.85_  | **59.15** |  _91.00_  |
|sum            |  _37.79_  |  _62.21_  | **100.00** |


Answerlist
----------
* $P(E \cap R) =   5.94\%$
* $P(\overline{E} \cap R) =  31.85\%$
* $P(E \cap \overline{R}) =   3.06\%$
* $P(\overline{E} \cap \overline{R}) =  59.15\%$
* $P(R) =  37.79\%$
* $P(\overline{R}) =  62.21\%$
* $P(E) =   9.00\%$
* $P(\overline{E}) =  91.00\%$
* $P(\Omega) = 100.00\%$


Meta-information
================
extype: cloze
exsolution: 5.94|31.85|3.06|59.15|37.79|62.21|9|91|100
exclozetype: num|num|num|num|num|num|num|num|num
exname: fourfold
extol: 0.05
exextra[numwidth,logical]: TRUE
