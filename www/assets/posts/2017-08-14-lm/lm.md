

Question
========
Using the data provided in [regression.csv](regression.csv) estimate a linear regression of
`y` on `x` and answer the following questions.

Answerlist
----------
  \item `x` and `y` are not significantly correlated
  \item `y` increases significantly with `x`
  \item `y` decreases significantly with `x`
  \item Estimated slope with respect to `x`:

Solution
========
\
![](scatterplot-1.svg)

To replicate the analysis in R:

<pre><code class="prettyprint ">## data
d &lt;- read.csv(&quot;regression.csv&quot;)
## regression
m &lt;- lm(y ~ x, data = d)
summary(m)
## visualization
plot(y ~ x, data = d)
abline(m)</code></pre>

Meta-information
================
exname: Linear regression
extype: cloze
exsolution: 001|-0.674
exclozetype: schoice|num
extol: 0.01
