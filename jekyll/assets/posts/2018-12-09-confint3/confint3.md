

Question
========
It is suspected that a supplier systematically underfills 5 l canisters of detergent.
The filled volumes are assumed to be normally distributed. A small sample of $13$
canisters is measured exactly. This shows that the canisters contain on average
$4948.1$ ml. The sample variance $s^2_{n-1}$ is equal to $352.1$.

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
&= \left[ 4948.1 \, - \, 2.1788\sqrt{\frac{352.1}{13}}, \;
          4948.1 \, + \, 2.1788\sqrt{\frac{352.1}{13}}\right] \\
&= \left[4936.761, \, 4959.439\right].
\end{aligned}
$$

Answerlist
----------
* The lower confidence bound is $4936.761$.
* The upper confidence bound is $4959.439$.


Meta-information
============
extype: cloze
exclozetype: verbatim|verbatim
exsolution: :NUMERICAL:=4936.761:0.1~%50%4937.9:0.1#Normal-based instead of t-based interval; for small samples, intervals based on the normal approximation are too narrow.|:NUMERICAL:=4959.439:0.1~%50%4958.3:0.1#Normal-based instead of t-based interval; for small samples, intervals based on the normal approximation are too narrow.
exname: Confidence interval
extol: 0.01
