

Question
========
It is suspected that a supplier systematically underfills 5 l canisters of detergent.
The filled volumes are assumed to be normally distributed. A small sample of $14$
canisters is measured exactly. This shows that the canisters contain on average
$4957.4$ ml. The sample variance $s^2_{n-1}$ is equal to $1176.3$.

Determine a $95\%$ confidence interval for the average content of
a canister (in ml).

Answerlist
----------
* What is the lower confidence bound?
* What is the upper confidence bound?

Solution
========
The $95\%$ confidence interval for the average content $\mu$ in ml is
given by:
$$
\begin{aligned}
& \left[\bar{y} \, - \, t_{n-1;0.975}\sqrt{\frac{s_{n-1}^2}{n}}, \;
  \bar{y} \, + \, t_{n-1;0.975}\sqrt{\frac{s_{n-1}^2}{n}}\right] \\
&= \left[ 4957.4 \, - \, 2.1604\sqrt{\frac{1176.3}{14}}, \;
          4957.4 \, + \, 2.1604\sqrt{\frac{1176.3}{14}}\right] \\
&= \left[4937.597, \, 4977.203\right].
\end{aligned}
$$

Answerlist
----------
* The lower confidence bound is $4937.597$.
* The upper confidence bound is $4977.203$.


Meta-information
============
extype: cloze
exclozetype: verbatim|verbatim
exsolution: :NUMERICAL:=4937.597:0.1~%50%4939.434:0.1#Normal-based instead of t-based interval; for small samples, intervals based on the normal approximation are too narrow.|:NUMERICAL:=4977.203:0.1~%50%4975.366:0.1#Normal-based instead of t-based interval; for small samples, intervals based on the normal approximation are too narrow.
exname: Confidence interval
extol: 0.01
