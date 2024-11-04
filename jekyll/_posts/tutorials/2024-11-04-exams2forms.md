---
layout: page
#
# Content
#
title: "Embedding R/exams Exercises as Forms in R/Markdown or Quarto Documents"
teaser: "Introduction to the new exams2forms package for including quizzes or individual questions from dynamic exercise templates into rmarkdown or quarto documents, e.g., for self-paced learning and self-assessment."
categories:
  - tutorials
tags:
  - webexercises
  - tutorial
  - e-learning
  - R
author: zeileis

mathjax: true
webex: true

#
# Style
#
image:
  # shown on top of blog post
  title: exams2forms.title.png
  # preview in list of posts
  thumb: exams2forms.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams + rmarkdown + quarto logos (CC-BY-SA)."
---



## Overview

The package [exams2forms](https://CRAN.R-project.org/package=exams2forms) provides several building blocks for embedding exercises written with the R package [exams]({{ site.url }}) (also known as R/exams) in interactive documents or quizzes written with [rmarkdown](https://rmarkdown.rstudio.com/) or [quarto](https://quarto.org/).

The idea is that the [dynamic exercises]({{ site.url }}/intro/dynamic/) in R/exams' Rmd (R/Markdown) or Rnw (R/LaTeX) format can also be reused in HTML documents, web pages, or online books. This facilitates their use for self-paced learning and self-assessment without the need for a learning management system etc. And for (summative) assessments the same dynamic exercises could then be exported to different [learning management systems]({{ site.url }}/intro/elearning/) or employed in [written exams]({{ site.url }}/intro/written/).

All R/exams exercise types are supported:

- Single-choice (schoice).
- Multiple-choice (mchoice).
- Numeric (num).
- Text (string).
- Cloze combining all of the previous elements (cloze).

Many of the ideas as well as the code in the package have been adapted from the [webexercises](https://psyteachr.github.io/webexercises/) package, authored by Dale Barr and Lisa DeBruine.


## First examples

As quick demonstration for R/exams exercises embedded into an HTML document, the two examples from the [First Steps]({{ site.url }}/tutorials/first_steps/) tutorial are included below: The single-choice exercise [swisscapital]({{ site.url }}/templates/swisscapital/) and the numeric exercise [deriv]({{ site.url }}/templates/deriv/), both in three random variations.

<div class="webex-group">
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the seat of the federal authorities in Switzerland (i.e., the de facto capital)?</p>
<div id="radio_group_iwmjkidtua" class="webex-radiogroup">
<label><input type='radio' autocomplete='off' name='radio_group_iwmjkidtua' value=''/><span>Geneva</span></label><label><input type='radio' autocomplete='off' name='radio_group_iwmjkidtua' value=''/><span>Lausanne</span></label><label><input type='radio' autocomplete='off' name='radio_group_iwmjkidtua' value=''/><span>St. Gallen</span></label><label><input type='radio' autocomplete='off' name='radio_group_iwmjkidtua' value='answer'/><span>Bern</span></label><label><input type='radio' autocomplete='off' name='radio_group_iwmjkidtua' value=''/><span>Vaduz</span></label>
</div>
</div>
<div class="webex-solution">
<p>There is no de jure capital but the de facto capital and seat of the federal authorities is Bern.</p>
<ul>
<li>False</li>
<li>False</li>
<li>False</li>
<li>True</li>
<li>False</li>
</ul>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the seat of the federal authorities in Switzerland (i.e., the de facto capital)?</p>
<div id="radio_group_diwjoyldgf" class="webex-radiogroup">
<label><input type='radio' autocomplete='off' name='radio_group_diwjoyldgf' value=''/><span>St. Gallen</span></label><label><input type='radio' autocomplete='off' name='radio_group_diwjoyldgf' value=''/><span>Zurich</span></label><label><input type='radio' autocomplete='off' name='radio_group_diwjoyldgf' value='answer'/><span>Bern</span></label><label><input type='radio' autocomplete='off' name='radio_group_diwjoyldgf' value=''/><span>Geneva</span></label><label><input type='radio' autocomplete='off' name='radio_group_diwjoyldgf' value=''/><span>Vaduz</span></label>
</div>
</div>
<div class="webex-solution">
<p>There is no de jure capital but the de facto capital and seat of the federal authorities is Bern.</p>
<ul>
<li>False</li>
<li>False</li>
<li>True</li>
<li>False</li>
<li>False</li>
</ul>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the seat of the federal authorities in Switzerland (i.e., the de facto capital)?</p>
<div id="radio_group_dqmcrzswwb" class="webex-radiogroup">
<label><input type='radio' autocomplete='off' name='radio_group_dqmcrzswwb' value=''/><span>Lausanne</span></label><label><input type='radio' autocomplete='off' name='radio_group_dqmcrzswwb' value='answer'/><span>Bern</span></label><label><input type='radio' autocomplete='off' name='radio_group_dqmcrzswwb' value=''/><span>Vaduz</span></label><label><input type='radio' autocomplete='off' name='radio_group_dqmcrzswwb' value=''/><span>Zurich</span></label><label><input type='radio' autocomplete='off' name='radio_group_dqmcrzswwb' value=''/><span>Basel</span></label>
</div>
</div>
<div class="webex-solution">
<p>There is no de jure capital but the de facto capital and seat of the federal authorities is Bern.</p>
<ul>
<li>False</li>
<li>True</li>
<li>False</li>
<li>False</li>
<li>False</li>
</ul>
</div>
</div>
</div>
<div class="webex-group">
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the derivative of <span class="math inline">\(f(x) = x^{7} e^{3.9 x}\)</span>, evaluated at <span class="math inline">\(x = 0.67\)</span>?</p>
<p><input class='webex-solveme nospaces' data-tol='0.01' size='20' data-answer='["11.86"]'/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{7}\)</span> and <span class="math inline">\(h(x) := e^{3.9 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 7 x^{7 - 1} \cdot e^{3.9 x} + x^{7} \cdot e^{3.9 x} \cdot 3.9 \\
      &amp;= e^{3.9 x} \cdot(7 x^6 + 3.9 x^{7}) \\
      &amp;= e^{3.9 x} \cdot x^6 \cdot (7 + 3.9 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.67\)</span>, the answer is <span class="math display">\[ e^{3.9 \cdot 0.67} \cdot 0.67^6 \cdot (7 + 3.9 \cdot 0.67) = 11.860944. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.67) = 11.86\)</span>.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the derivative of <span class="math inline">\(f(x) = x^{4} e^{3.1 x}\)</span>, evaluated at <span class="math inline">\(x = 0.53\)</span>?</p>
<p><input class='webex-solveme nospaces' data-tol='0.01' size='20' data-answer='["4.34"]'/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{4}\)</span> and <span class="math inline">\(h(x) := e^{3.1 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 4 x^{4 - 1} \cdot e^{3.1 x} + x^{4} \cdot e^{3.1 x} \cdot 3.1 \\
      &amp;= e^{3.1 x} \cdot(4 x^3 + 3.1 x^{4}) \\
      &amp;= e^{3.1 x} \cdot x^3 \cdot (4 + 3.1 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.53\)</span>, the answer is <span class="math display">\[ e^{3.1 \cdot 0.53} \cdot 0.53^3 \cdot (4 + 3.1 \cdot 0.53) = 4.343937. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.53) = 4.34\)</span>.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the derivative of <span class="math inline">\(f(x) = x^{5} e^{3.6 x}\)</span>, evaluated at <span class="math inline">\(x = 0.7\)</span>?</p>
<p><input class='webex-solveme nospaces' data-tol='0.01' size='20' data-answer='["22.44"]'/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{5}\)</span> and <span class="math inline">\(h(x) := e^{3.6 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 5 x^{5 - 1} \cdot e^{3.6 x} + x^{5} \cdot e^{3.6 x} \cdot 3.6 \\
      &amp;= e^{3.6 x} \cdot(5 x^4 + 3.6 x^{5}) \\
      &amp;= e^{3.6 x} \cdot x^4 \cdot (5 + 3.6 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.7\)</span>, the answer is <span class="math display">\[ e^{3.6 \cdot 0.7} \cdot 0.7^4 \cdot (5 + 3.6 \cdot 0.7) = 22.440478. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.7) = 22.44\)</span>.</p>
</div>
</div>
</div>

In addition to the question and the interaction element, there are three buttons providing the following functionality.

| Button          | Function                                                                                                                                                                       |
|:---------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <b>&#10003;</b> | Check the answer and display whether it is correct or not. When clicked, the symbol is toggled and <b>&#8624;</b> is displayed, which can be clicked to hide the solution again. |
| <b>&#63;</b>    | Display the full correct solution explanation.                                                                                                                                 |
| <b>&#8634;</b>  | Switch to the next question.                                                                                                                                                   |

Inclusion of the solution explanation is optional and the next question button is only displayed if there is more than one random variation of a question. The icons and mouseover text can also be adapted (see below).

To set up a similar standalone file with these two exercises, the `exams2qebquiz()` interface from the `exams2forms` package can be used:


<pre><code class="prettyprint ">library(&quot;exams2forms&quot;)
exams2webquiz(c(&quot;swisscapital.Rmd&quot;, &quot;deriv.Rmd&quot;), n = 3)</code></pre>


## More elaborate examples

To showcase some more exercise types, the following examples from the R/exams package are used: [capitals]({{ site.url }}/templates/capitals/) (multiple-choice), [function]({{ site.url }}/templates/function/) (string/text), [fruit]({{ site.url }}/templates/fruit/) (numeric with table and images), [lm2]({{ site.url }}/templates/lm2/) (cloze containing string, multiple-choice, numeric, and single-choice elements as well as an embedded data file).

<div class="webex-question">
<div class="webex-check webex-box">
<p>Which of the following cities are the capital of the corresponding country?</p>
<div id="checkbox_group_zqvwgpaxbs" class="webex-checkboxgroup">
<label><input type='checkbox' autocomplete='off' name='checkbox_group_zqvwgpaxbs' value='answer'/><span>New Delhi (India)</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_zqvwgpaxbs' value='answer'/><span>Warsaw (Poland)</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_zqvwgpaxbs' value=''/><span>Auckland (New Zealand)</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_zqvwgpaxbs' value='answer'/><span>Tokyo (Japan)</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_zqvwgpaxbs' value='answer'/><span>Riyadh (Saudi Arabia)</span></label>
</div>
</div>
<div class="webex-solution">
<ul>
<li>True. New Delhi is the capital of India.</li>
<li>True. Warsaw is the capital of Poland.</li>
<li>False. The capital of New Zealand is Wellington.</li>
<li>True. Tokyo is the capital of Japan.</li>
<li>True. Riyadh is the capital of Saudi Arabia.</li>
</ul>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the name of the R function for logistic regression?</p>
<p><input class='webex-solveme' size='20' data-answer='["glm"]'/></p>
</div>
<div class="webex-solution">
<p><code>glm</code> is the R function for logistic regression. See <code>?glm</code> for the corresponding manual page.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>Given the following information:</p>
<table>
<tbody>
<tr class="odd">
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(508\)</span></td>
</tr>
<tr class="even">
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(735\)</span></td>
</tr>
<tr class="odd">
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(203\)</span></td>
</tr>
</tbody>
</table>
<p>Compute:</p>
<table>
<tbody>
<tr class="odd">
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(\text{?}\)</span></td>
</tr>
</tbody>
</table>
<p><input class='webex-solveme nospaces' data-tol='0' size='20' data-answer='["482"]'/></p>
</div>
<div class="webex-solution">
<p>The information provided can be interpreted as the price for three fruit baskets with different combinations of the three fruits. This corresponds to a system of linear equations where the price of the three fruits is the vector of unknowns <span class="math inline">\(x\)</span>:</p>
<table>
<tbody>
<tr class="odd">
<td align="right"><span class="math inline">\(x_1 =\)</span></td>
<td align="left"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="right"><span class="math inline">\(x_2 =\)</span></td>
<td align="left"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="right"><span class="math inline">\(x_3 =\)</span></td>
<td align="left"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
</tr>
</tbody>
</table>
<p>The system of linear equations is then: <span class="math display">\[
\begin{aligned}
\left( \begin{array}{rrr} 0 &amp; 2 &amp; 1 \\ 1 &amp; 0 &amp; 2 \\ 2 &amp; 1 &amp; 0 \end{array} \right) \cdot \left( \begin{array}{r} x_1 \\ x_2 \\ x_3 \end{array} \right) &amp; = &amp; \left( \begin{array}{r} 508 \\ 735 \\ 203 \end{array} \right)
\end{aligned}
\]</span> This can be solved using any solution algorithm, e.g., elimination: <span class="math display">\[
x_1 = 59, \, x_2 = 85, \, x_3 = 338.
\]</span> Based on the three prices for the different fruits it is straightforward to compute the total price of the fourth fruit basket via:</p>
<table>
<tbody>
<tr class="odd">
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="http://localhost:4000/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"></td>
</tr>
<tr class="even">
<td align="center"><span class="math inline">\(x_1\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(x_2\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(x_3\)</span></td>
<td align="center">=</td>
<td align="right"></td>
</tr>
<tr class="odd">
<td align="center"><span class="math inline">\(59\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(85\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(338\)</span></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(482\)</span></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p><strong>Theory:</strong> Consider a linear regression of <code>y</code> on <code>x</code>. It is usually estimated with which estimation technique (three-letter abbreviation)?</p>
<p><input class='webex-solveme' size='20' data-answer='["OLS"]'/></p>
<p>This estimator yields the best linear unbiased estimator (BLUE) under the assumptions of the Gauss-Markov theorem. Which of the following properties are required for the errors of the linear regression model under these assumptions?</p>
<div id="checkbox_group_jlbeatyoer" class="webex-checkboxgroup">
<label><input type='checkbox' autocomplete='off' name='checkbox_group_jlbeatyoer' value=''/><span>independent</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_jlbeatyoer' value='answer'/><span>zero expectation</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_jlbeatyoer' value=''/><span>normally distributed</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_jlbeatyoer' value=''/><span>identically distributed</span></label><label><input type='checkbox' autocomplete='off' name='checkbox_group_jlbeatyoer' value='answer'/><span>homoscedastic</span></label>
</div>
<p><strong>Application:</strong> Using the data provided in <a href="http://localhost:4000/assets/posts/2024-11-04-exams2forms/linreg.csv">linreg.csv</a> estimate a linear regression of <code>y</code> on <code>x</code>. What are the estimated parameters?</p>
<p>Intercept: <input class='webex-solveme nospaces' data-tol='0.01' size='20' data-answer='["0.008"]'/></p>
<p>Slope: <input class='webex-solveme nospaces' data-tol='0.01' size='20' data-answer='["0.637"]'/></p>
<p>In terms of significance at 5% level:</p>
<p><select class='webex-select'><option value='blank'></option><option value=''><code>x</code> and <code>y</code> are not significantly correlated</option><option value='answer'><code>y</code> increases significantly with <code>x</code></option><option value=''><code>y</code> decreases significantly with <code>x</code></option></select></p>
</div>
<div class="webex-solution">
<p><strong>Theory:</strong> Linear regression models are typically estimated by ordinary least squares (OLS). The Gauss-Markov theorem establishes certain optimality properties: Namely, if the errors have expectation zero, constant variance (homoscedastic), no autocorrelation and the regressors are exogenous and not linearly dependent, the OLS estimator is the best linear unbiased estimator (BLUE).</p>
<p><strong>Application:</strong> The estimated coefficients along with their significances are reported in the summary of the fitted regression model, showing that <code>y</code> increases significantly with <code>x</code> (at 5% level).</p>
<pre><code>
Call:
lm(formula = y ~ x, data = d)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.66428 -0.16666 -0.00005  0.16780  0.53977 

Coefficients:
            Estimate Std. Error t value Pr(&gt;|t|)    
(Intercept) 0.008474   0.026627   0.318    0.751    
x           0.637386   0.046427  13.729   &lt;2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.266 on 98 degrees of freedom
Multiple R-squared:  0.6579,    Adjusted R-squared:  0.6544 
F-statistic: 188.5 on 1 and 98 DF,  p-value: &lt; 2.2e-16
</code></pre>
<p><strong>Code:</strong> The analysis can be replicated in R using the following code.</p>
<pre><code>## data
d &lt;- read.csv(&quot;linreg.csv&quot;)
## regression
m &lt;- lm(y ~ x, data = d)
summary(m)
## visualization
plot(y ~ x, data = d)
abline(m)</code></pre>
</div>
</div>

Again, the `exams2webquiz()` function can be used to set up a standalone file based on the same exercises:


<pre><code class="prettyprint ">exams2webquiz(c(&quot;capitals.Rmd&quot;, &quot;function.Rmd&quot;, &quot;fruit.Rmd&quot;, &quot;lm2.Rmd&quot;))</code></pre>


## Building blocks

To accomplish the functionality demonstrated above, the package provides the following contents:

- `exams2forms()`: Main workhorse function from the package. Like other `exams2xyz()` interfaces this takes a vector or list of exercise files and returns Markdown text, including HTML snippets, than can be included in `rmarkdown` or `quarto` documents. This includes questions, suitable interactions for the different types of answers (with correct solutions also embedded in the HTML), and optionally full solution explanations.
- `webex.css`, `webex.js`: CSS (Cascading Style Sheets) and Javascript files shipped within the package and providing the code necessary for the exercise and quiz display and processing the different types of interactions.
- `webquiz()`: Small wrapper function that creates a `knitr::html_document()` but includes the CSS and Javascript files above.
- `exams2webquiz()`: Convenience interface that combines all of the above elements. It sets up a `webquiz()` document in which `exams2forms()` is used to embed the specified exercises, calls `rmarkdown::render()` to process it, and by default displays it in the browser. This is most useful for quickly trying out how R/exams exercises can work in HTML documents.
- `forms_num()`, `forms_string()`, `forms_schoice()`, `forms_mchoice()`: Helper functions for just embedding the user interactions for the different types of exercises. Typically not called directly by the user.


## Demo files

While `exams2webquiz()` is convenient for quickly setting up an HTML document containing certain exercises, further customizations are typicallly needed for more elaborate documents. To demonstrate how this works the `exams2forms` package provides two demo `rmarkdown` files which can also be downloaded here:

- <!--html_preserve--><a href="data:text/x-markdown;base64,LS0tCnRpdGxlOiAiUi9leGFtcyBxdWl6IgpvdXRwdXQ6IGV4YW1zMmZvcm1zOjp3ZWJxdWl6Ci0tLQoKYGBge3Igc2V0dXAsIGluY2x1ZGUgPSBGQUxTRX0KIyMgcGFja2FnZSBhbmQgbGlzdCBvZiB2YXJpb3VzIGV4ZXJjaXNlcwpsaWJyYXJ5KCJleGFtczJmb3JtcyIpCmV4bSA8LSBsaXN0KAogIGMoInN3aXNzY2FwaXRhbC5SbWQiLCAiY2FwaXRhbHMuUm1kIiksCiAgImRlcml2LlJudyIsCiAgImRlcml2Mi5SbnciLAogICJmcnVpdC5SbWQiLAogICJib3hwbG90cy5SbWQiLAogICJ0dGVzdC5SbWQiLAogICJmdW5jdGlvbi5SbWQiLAogICJsbTIuUm53IiwKICAiZm91cmZvbGQyLlJtZCIKKQpgYGAKCmBgYHtyIHF1aXosIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3JtcyhleG0sIG4gPSAzKQpgYGAK" download="quiz.Rmd">Download quiz.Rmd</a><!--/html_preserve-->.
- <!--html_preserve--><a href="data:text/x-markdown;base64,LS0tCnRpdGxlOiAiUi9leGFtcyBxdWVzdGlvbnMiCm91dHB1dDoKICBleGFtczJmb3Jtczo6d2VicXVpejoKICAgIHRvYzogdHJ1ZQogICAgdG9jX2Zsb2F0OiB0cnVlCi0tLQoKYGBge3Igc2V0dXAsIGluY2x1ZGUgPSBGQUxTRX0KbGlicmFyeSgiZXhhbXMyZm9ybXMiKQpgYGAKCiMjIEtub3dsZWRnZSBxdWl6IChzaW5nbGUtY2hvaWNlKQoKYGBge3Igc2Nob2ljZTEsIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3Jtcygic3dpc3NjYXBpdGFsLlJtZCIpCmBgYAoKIyMgS25vd2xlZGdlIHF1aXogKG11bHRpcGxlLWNob2ljZSkKCmBgYHtyIG1jaG9pY2UyLCBlY2hvID0gRkFMU0UsIG1lc3NhZ2UgPSBGQUxTRSwgcmVzdWx0cyA9ICJhc2lzIn0KZXhhbXMyZm9ybXMoImNhcGl0YWxzLlJtZCIpCmBgYAoKIyMgQXJpdGhtZXRpYyAobnVtZXJpYykKCmBgYHtyIG51bTMsIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3JtcygiZGVyaXYuUm53IikKYGBgCgojIyBBcml0aG1ldGljIChzaW5nbGUtY2hvaWNlKQoKYGBge3Igc2Nob2ljZTQsIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3JtcygiZGVyaXYyLlJudyIpCmBgYAoKIyMgTXVsdGlwbGUtY2hvaWNlIHdpdGggZ3JhcGhpYwoKYGBge3IgbWNob2ljZTUsIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3JtcygiYm94cGxvdHMuUm1kIikKYGBgCgojIyBNdWx0aXBsZS1jaG9pY2Ugd2l0aCBSIG91dHB1dAoKYGBge3IgbWNob2ljZTYsIGVjaG8gPSBGQUxTRSwgbWVzc2FnZSA9IEZBTFNFLCByZXN1bHRzID0gImFzaXMifQpleGFtczJmb3JtcygidHRlc3QuUm1kIikKYGBgCgojIyBTdHJpbmcgcXVlc3Rpb24KCmBgYHtyIHN0cmluZywgZWNobyA9IEZBTFNFLCBtZXNzYWdlID0gRkFMU0UsIHJlc3VsdHMgPSAiYXNpcyJ9CmV4YW1zMmZvcm1zKCJmdW5jdGlvbi5SbWQiKQpgYGAKCiMjIENsb3plIHF1ZXN0aW9uIGNvbWJpbmluZyBhbGwgdHlwZXMKCmBgYHtyIGNsb3plMSwgZWNobyA9IEZBTFNFLCBtZXNzYWdlID0gRkFMU0UsIHJlc3VsdHMgPSAiYXNpcyJ9CmV4YW1zMmZvcm1zKCJsbTIuUm53IikKYGBgCgojIyBDbG96ZSBxdWVzdGlvbiB3aXRoIHRhYmxlIGxheW91dAoKYGBge3IgY2xvemUyLCBlY2hvID0gRkFMU0UsIG1lc3NhZ2UgPSBGQUxTRSwgcmVzdWx0cyA9ICJhc2lzIn0KZXhhbXMyZm9ybXMoImZvdXJmb2xkMi5SbWQiKQpgYGAK" download="questions.Rmd">Download questions.Rmd</a><!--/html_preserve-->.

The first file `quiz.Rmd` renders a number of different exercises into a quiz using a single `exams2forms()` call, indicating that the `results` should be included `"asis"`:

<pre><code>
---
title: "R/exams quiz"
output: exams2forms::webquiz
---

```{r setup, include = FALSE}
## package and list of various exercises
library("exams2forms")
exm <- list(
  c("swisscapital.Rmd", "capitals.Rmd"),
  "deriv.Rnw",
  "deriv2.Rnw",
  "fruit.Rmd",
  "boxplots.Rmd",
  "ttest.Rmd",
  "function.Rmd",
  "lm2.Rnw",
  "fourfold2.Rmd"
)
```

```{r quiz, echo = FALSE, message = FALSE, results = "asis"}
exams2forms(exm, n = 3)
```
</code></pre>

The `questions.Rmd` file looks similar but contains different sections, each with a single question set up via `exams2forms()`.

Both files can be rendered to HTML via `rmarkdown::render()` or by clicking the knit button after opening the files in RStudio etc.


## Setup and customization

When setting up a more elaborate document or even a full webpage or online book with `rmarkdown` or `quarto`, then the simple `webquiz()` HTML document provided by `exams2forms` is probably not sufficient. In this case, it is best to take the CSS and Javascript files from the package or download them here:

- <!--html_preserve--><a href="data:text/css;base64,OnJvb3QgewogIC0taW5jb3JyZWN0OiAjOTgzRTgyOwogIC0taW5jb3JyZWN0X2FscGhhOiAjZWRhZGRkOwogIC0tY29ycmVjdDogIzU5OTM1QjsKICAtLWNvcnJlY3RfYWxwaGE6ICNjMGVkYzI7CiAgLS1oaWdobGlnaHQ6ICM0NjdBQUM7CiAgLS1oaWdobGlnaHRfYWxwaGE6ICNEMUU0RkY7CiAgLS1oaWdobGlnaHRfZ3JheTogI0MzQzNDMzsKICAtLWJhY2tncm91bmRfcXVlc3Rpb246ICM3ZjdmN2YwZDsKICAtLWJhY2tncm91bmRfaW5wdXQ6IHdoaXRlOwogIC0tdGV4dF9pbnB1dDogYmxhY2s7Cn0KCi8qIGZvciBxdWFydG8gd2Vic2l0ZXMgd2hlbiB1c2luZyBkYXJrIHRoZW1lIGFuZAogKiBmb3IgYm9va2Rvd246OmdpdGJvb2s6IGRhcmsgdGhlbWUgKC5jb2xvci10aGVtZS0yKSAqLwo6cm9vdCAucXVhcnRvLWRhcmssIDpyb290IC5jb2xvci10aGVtZS0yIHsKICAtLWhpZ2hsaWdodDogIzU2ODdCOTsKICAtLWJhY2tncm91bmRfaW5wdXQ6IGJsYWNrOwogIC0tdGV4dF9pbnB1dDogd2hpdGU7Cn0KLyogV2lzaGxpc3Q6IEFkZGluZyBzdHlsaW5nIGZvciAuY29sb3ItdGhlbWUtMSAoc2VwaWE7IGdpdGJvb2spICovCgovKi0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEREVELS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qLwoKLyogYSB3ZWJleC1ncm91cCBpcyBhIGRpdiBjb250YWluZXIgY29udGFpbmluZyBtdWx0aXBsZQogKiB3ZWJleC1xdWVzdGlvbnMuIFdlIGZpcnN0IGhpZGUgYWxsIGFuZCByYW5kb21seSBzaG93CiAqIG9uZSBvZiB0aGUgcmFuZG9taXphdGlvbnMgKHdlYmV4LmpzKSAqLwoud2ViZXgtZ3JvdXAgLndlYmV4LXF1ZXN0aW9uIHsKICBkaXNwbGF5OiBub25lOwp9Ci53ZWJleC1ncm91cCAud2ViZXgtcXVlc3Rpb24uYWN0aXZlIHsKICBkaXNwbGF5OiBibG9jazsKfQoKLyotLS0tLS0tLS0tLS0tLS0tLS0tLS1BRERFRCBFTkQtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovCgoud2ViZXgtY2hlY2sge30KCi53ZWJleC1ib3ggewogIGJvcmRlcjogMnB4IHNvbGlkIHZhcigtLWhpZ2hsaWdodCk7CiAgcGFkZGluZzogMC41ZW07CiAgbWFyZ2luOiAxZW0gMDsKICBib3JkZXItcmFkaXVzOiAuMjVlbTsKICBiYWNrZ3JvdW5kLWNvbG9yOiB2YXIoLS1iYWNrZ3JvdW5kX3F1ZXN0aW9uKTsKfQoKLndlYmV4LXRvdGFsX2NvcnJlY3QgewogIG1hcmdpbi1sZWZ0OiAxZW07Cn0KCi51bmNoZWNrZWQgLndlYmV4LXRvdGFsX2NvcnJlY3QgewogIGRpc3BsYXk6IG5vbmU7Cn0KCi51bmNoZWNrZWQgLndlYmV4LWluY29ycmVjdCwKLnVuY2hlY2tlZCAud2ViZXgtY29ycmVjdCB7CiAgYm9yZGVyOiAycHggc29saWQgdHJhbnNwYXJlbnQgIWltcG9ydGFudDsKICBiYWNrZ3JvdW5kLWNvbG9yOiB0cmFuc3BhcmVudCAhaW1wb3J0YW50Owp9CgovKiBpbnB1dCBlbGVtZW50cyByZXF1aXJlIGEgdmlzaWJsZSBib3JkZXIgKi8KLnVuY2hlY2tlZCBzZWxlY3Qud2ViZXgtaW5jb3JyZWN0LAoudW5jaGVja2VkIHNlbGVjdC53ZWJleC1jb3JyZWN0LAoudW5jaGVja2VkIGlucHV0LndlYmV4LWluY29ycmVjdCwKLnVuY2hlY2tlZCBpbnB1dC53ZWJleC1jb3JyZWN0IHsKICBib3JkZXI6IDJweCBzb2xpZCB2YXIoLS1oaWdobGlnaHQpICFpbXBvcnRhbnQ7CiAgYmFja2dyb3VuZC1jb2xvcjogdmFyKC0tYmFja2dyb3VuZF9pbnB1dCkgIWltcG9ydGFudDsKICBjb2xvcjogdmFyKC0tdGV4dF9pbnB1dCkgIWltcG9ydGFudDsKfQoKLyogc3R5bGVzIGZvciB3ZWJleC1zb2x2ZW1lICovCi53ZWJleC1zZWxlY3QsIC53ZWJleC1zb2x2ZW1lLAoudW5jaGVja2VkIC53ZWJleC1yYWRpb2dyb3VwID4gLndlYmV4LWluY29ycmVjdCwKLnVuY2hlY2tlZCAud2ViZXgtcmFkaW9ncm91cCA+IC53ZWJleC1jb3JyZWN0ewogIGJvcmRlcjogMnB4IHNvbGlkIHZhcigtLWhpZ2hsaWdodCk7CiAgYmFja2dyb3VuZC1jb2xvcjogdmFyKC0tYmFja2dyb3VuZF9pbnB1dCk7CiAgY29sb3I6IHZhcigtLXRleHRfaW5wdXQpICFpbXBvcnRhbnQ7CiAgYm9yZGVyLXJhZGl1czogMC4yNWVtOwogIG1heC13aWR0aDogOTAlOwp9Cgoud2ViZXgtaW5jb3JyZWN0LCAud2ViZXgtY2hlY2tib3hncm91cCwgLndlYmV4LXNvbHZlbWUuIC53ZWJleC1yYWRpb2dyb3VwIHsKICAgIC8qIERFUFJJQ0FURUQgY29sb3I6IGJsYWNrOyAqLwogICAgYm9yZGVyLXJhZGl1czogMC4yNWVtOwp9Ci53ZWJleC1jaGVja2JveGdyb3VwIHsgICAgCiAgICBtYXJnaW4tYm90dG9tOiAxZW07Cn0gICAKICAKLndlYmV4LWluY29ycmVjdCwKLndlYmV4LWNoZWNrYm94Z3JvdXAgPiAud2ViZXgtaW5jb3JyZWN0LAoud2ViZXgtc29sdmVtZS53ZWJleC1pbmNvcnJlY3QsCi53ZWJleC1yYWRpb2dyb3VwID4gLndlYmV4LWluY29ycmVjdCB7CiAgICBib3JkZXI6IDJweCBzb2xpZCB2YXIoLS1pbmNvcnJlY3QpOwogICAgYmFja2dyb3VuZC1jb2xvcjogdmFyKC0taW5jb3JyZWN0X2FscGhhKTsKfQoud2ViZXgtY29ycmVjdCwgIAoud2ViZXgtY2hlY2tib3hncm91cCA+IC53ZWJleC1jb3JyZWN0LAoud2ViZXgtc29sdmVtZS53ZWJleC1jb3JyZWN0LAoud2ViZXgtcmFkaW9ncm91cCA+LndlYmV4LWNvcnJlY3QgewogICAgYm9yZGVyOiAycHggc29saWQgdmFyKC0tY29ycmVjdCk7CiAgICBiYWNrZ3JvdW5kLWNvbG9yOiB2YXIoLS1jb3JyZWN0X2FscGhhKTsKfQoKLnVuY2hlY2tlZCAud2ViZXgtaW5jb3JyZWN0ID4gc3Bhbjo6YWZ0ZXIsCi51bmNoZWNrZWQgLndlYmV4LWluY29ycmVjdCArIC53ZWJleC1pY29uOjphZnRlciwKLnVuY2hlY2tlZCAud2ViZXgtY29ycmVjdCA+IHNwYW46OmFmdGVyLAoudW5jaGVja2VkIC53ZWJleC1jb3JyZWN0ICsgLndlYmV4LWljb246OmFmdGVyIHsKICBjb250ZW50OiAiIjsKfQoKLyogaWNvbnMgc3BlY2lmaWVkIGFzIENTUyBkZWNpbWFsIDk5ODQtMTAxNzUgdW5pY29kZSBjaGFycywKICogc2VlIGUuZy46IGh0dHBzOi8vd3d3Lnczc2Nob29scy5jb20vY2hhcnNldHMvcmVmX3V0Zl9kaW5nYmF0cy5hc3AgKi8KLndlYmV4LWluY29ycmVjdCA+IHNwYW46OmFmdGVyLAoud2ViZXgtaW5jb3JyZWN0ICsgLndlYmV4LWljb246OmFmdGVyIHsKICBjb250ZW50OiAiXDAwYTBcMDBhMFwyNzE1IjsKfQoKLndlYmV4LWNvcnJlY3QgPiBzcGFuOjphZnRlciwKLndlYmV4LWNvcnJlY3QgKyAud2ViZXgtaWNvbjo6YWZ0ZXIgewogIGNvbnRlbnQ6ICJcMDBhMFwwMGEwXDI3MTMiOwp9CgovKiAqKioqKioqKioqKioqKioqKioqKioqKioqKioqICovCi8qICoqKioqKioqKioqKioqKioqKioqKioqKioqKiogKi8KCi8qIHN0eWxlcyBmb3IgaGlkZGVuIHNvbHV0aW9ucyAqLwoud2ViZXgtc29sdXRpb24gewogICAgZGlzcGxheTogbm9uZTsKICAgIHBhZGRpbmc6IDAuNWVtOwogICAgbWFyZ2luLWJvdHRvbTogMTBweDsKICAgIGJvcmRlcjogMnB4IHNvbGlkIHZhcigtLWhpZ2hsaWdodF9ncmF5KTsKICAgIGJvcmRlci1yYWRpdXM6IDVweDsKfQoud2ViZXgtc29sdXRpb24udmlzaWJsZSB7CiAgICBkaXNwbGF5OiBibG9jazsKfQoud2ViZXgtc29sdXRpb24gPiB1bCB7CiAgICBwYWRkaW5nLWxlZnQ6IDJlbTsKfQoKLyogd2ViZXggYnV0dG9uIGxpc3Qgc3R5bGluZyAqLwp1bC53ZWJleC1idXR0b24tbGlzdCB7CiAgICBkaXNwbGF5OiBmbGV4OwogICAgZmxleC13cmFwOiB3cmFwOwogICAgd2lkdGg6IDEwMCU7CiAgICBsaXN0LXN0eWxlOiBub25lOwogICAgcGFkZGluZzogMCAhaW1wb3J0YW50OyAvKiAhaW1wb3J0YW50IGZvciBib29rZG93bjo6Z2l0Ym9vazogKi8KICAgIG1hcmdpbjogMCAhaW1wb3J0YW50OyAvKiAhaW1wb3J0YW50IGZvciBib29rZG93bjo6Z2l0Ym9vazogKi8KfQp1bC53ZWJleC1idXR0b24tbGlzdCA+IGxpIHsKICAgIHBhZGRpbmc6IDA7Cn0KdWwud2ViZXgtYnV0dG9uLWxpc3QgPiBsaSB7CiAgICBtYXJnaW4tYm90dG9tOiAwICFpbXBvcnRhbnQ7IC8qICFpbXBvcnRhbnQgZm9yIGJvb2tkb3duICovCn0KdWwud2ViZXgtYnV0dG9uLWxpc3QgPiBsaTpmaXJzdC1jaGlsZCB7CiAgICBtYXJnaW4tcmlnaHQ6IGF1dG87CiAgICBtYXJnaW4tdG9wOiAwOyAvKiBmb3IgYm9va2Rvd24gYnM0X2Jvb2sgKi8KfQoKLndlYmV4LXNvbHV0aW9uIGJ1dHRvbiwKLndlYmV4LWJveCAud2ViZXgtYnV0dG9uIHsKICAgIGhlaWdodDogMmVtOwogICAgbWluLXdpZHRoOiAyZW07CiAgICBtYXJnaW4tYm90dG9tOiAwOwogICAgbWFyZ2luLXJpZ2h0OiAwLjI1ZW07CiAgICBib3JkZXItcmFkaXVzOiAwLjVlbTsKICAgIGJhY2tncm91bmQtY29sb3I6IHRyYW5zcGFyZW50OwogICAgYm9yZGVyLWNvbG9yOiB2YXIoLS1oaWdobGlnaHQpOwogICAgY29sb3I6IHZhcigtLWhpZ2hsaWdodCk7CiAgICBwYWRkaW5nOiAwIDAuNWVtOwogICAgZm9udC1zaXplOiAxLjJlbTsKICAgIHdoaXRlLXNwYWNlOiBub3dyYXA7Cn0KLndlYmV4LWJ1dHRvbjpob3ZlciB7CiAgICBiYWNrZ3JvdW5kLWNvbG9yOiB2YXIoLS1oaWdobGlnaHRfYWxwaGEpOwp9Ci53ZWJleC1zb2x1dGlvbiBwcmUuc291cmNlQ29kZSB7CiAgICBib3JkZXItY29sb3I6IHZhcigtLWNvcnJlY3QpOwp9CnVsLndlYmV4LWJ1dHRvbi1saXN0ID4gbGk6bGFzdC1jaGlsZCA+IC53ZWJleC1idXR0b24geyAKICAgIG1hcmdpbi1yaWdodDogMDsKfQoKLyogaW52aXNpYmxlIGJvcmRlciB0byBrZWVwIGRpbWVuc2lvbnMgd2hlbiBub3QgaGlnaGxpZ2h0ZWQgKi8KLndlYmV4LWNoZWNrYm94Z3JvdXAgPiBsYWJlbCwKLnVuY2hlY2tlZCAud2ViZXgtY2hlY2tib3hncm91cCA+IGxhYmVsLAoud2ViZXgtcmFkaW9ncm91cCBsYWJlbCB7CiAgZm9udC13ZWlnaHQ6IDQwMDsKICBkaXNwbGF5OiBibG9jazsKICBib3JkZXI6IDJweCBzb2xpZCB0cmFuc3BhcmVudDsKICBiYWNrZ3JvdW5kLWNvbG9yOiBpbmhlcml0OwogIGJvcmRlci1yYWRpdXM6IDAuMjVlbTsKfQoKLndlYmV4LWNoZWNrYm94Z3JvdXAgbGFiZWwgPiBpbnB1dFt0eXBlPWNoZWNrYm94XSwKLndlYmV4LXJhZGlvZ3JvdXAgbGFiZWwgPiBpbnB1dFt0eXBlPXJhZGlvXSB7CiAgbWFyZ2luOiAwLjFlbSAwLjVlbSAwIDAuMjVlbTsKICBwb3NpdGlvbjogcmVsYXRpdmU7CiAgdG9wOiAwLjEyNWVtOwp9Cgoud2ViZXgtcmFkaW9ncm91cCB7CiAgbWFyZ2luOiAxZW0gMDsKfQoKCi8qIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICogQ1NTIHN0eWxpbmcgZm9yIGxpc3RzICg8dWw+KSB1c2VkIGZvciBtdWx0aXBsZSBjaG9pY2UgZXhlcmNpc2VzCiAqIHdpdGggZGlzcGxheSA9ICJkcm9wZG93biIuIFRoZSA8dWw+IGNvbWVzIGZyb20gbWFya2Rvd24gYW5kCiAqIGhhcyBubyBzcGVjaWZpYyBjbGFzcywgdGh1cyB3ZSBtdXN0IHJlbHkgb24gdGhlIG5lc3RpbmcKICogLndlYmV4LWJveCA+IHVsLgogKi8KLndlYmV4LWJveCA+IHVsOm5vdCgud2ViZXgtYnV0dG9uLWxpc3QpIHsKICAgIGxpc3Qtc3R5bGU6IG5vbmU7CiAgICBtYXJnaW46IDA7CiAgICBwYWRkaW5nOiAwIDAgMWVtIDAuMjVlbTsKfQoud2ViZXgtYm94ID4gdWw6bm90KC53ZWJleC1idXR0b24tbGlzdCkgPiBsaSB7CiAgICBtYXJnaW46IDAgMCAwLjI1ZW0gMDsKfQoud2ViZXgtYm94ID4gdWw6bm90KC53ZWJleC1idXR0b24tbGlzdCkgPiBsaSA+IHNlbGVjdCB7CiAgICBtYXJnaW46IDAgMC41ZW0gMCAwOwp9CgoKLyogLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogKiBDU1Mgc3R5bGUgZm9yIHdlYmV4LWNoZWNrYm94Z3JvdXAgdXNlZCBmb3IgbXVsdGlwbGUgY2hvaWNlCiAqIHdoZW4gdXNpbmcgJ2Rpc3BsYXkgPSAiYnV0dG9ucyInLgogKgogKiBGb3IgJ2NoZWNrYm94Z3JvdXBzJyAobXVsdGlwbGUgY2hvaWNlIHdpdGggZGlzcGxheSA9ICJidXR0b25zIgogKiB0aGluZ3MgbmVlZCB0byBiZSBkaWZmZXJlbnQgZnJvbSBlLmcuLCBzaW5nbGUgY2hvaWNlIHJhZGlvZ3JvdXBzLgogKiBGaXJzdCwgd2UgZG8gbm90IHdhbnQgdGhlIGljb24gKGNvcnJlY3QsIGluY29ycmVjdCkgaW4gZnJvbnQgb2YgdGhlIGFuc3dlcnMsCiAqIHNldHRpbmcgc3Bhbjo6YmVmb3JlIHRvIG5vIGNvbnRlbnQuIFNlY29uZCwgd2UgcmVtb3ZlIHRoZSBib3JkZXIgYW5kCiAqIGJhY2tncm91bmQgaGlnaGxpZ2h0IHVzZWQgdG8gc2hvdyAnc2VsZWN0ZWQgaXRlbXMnIG9uIHJhZGlvZ3JvdXBzLgogKiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gKi8KLndlYmV4LWNoZWNrYm94Z3JvdXAgPiBsYWJlbCB7CiAgZGlzcGxheTogYmxvY2s7Cn0KLndlYmV4LWNoZWNrYm94Z3JvdXAgPiBsYWJlbCA+IHNwYW4gewogIGZvbnQtd2VpZ2h0OiBub3JtYWw7Cn0KLnVuY2hlY2tlZCAud2ViZXgtY2hlY2tib3hncm91cCAud2ViZXgtaW5jb3JyZWN0LAoudW5jaGVja2VkIC53ZWJleC1jaGVja2JveGdyb3VwIC53ZWJleC1jb3JyZWN0IHsKICBib3JkZXI6IDJweCBzb2xpZCB0cmFuc3BhcmVudCAhaW1wb3J0YW50OwogIGJhY2tncm91bmQtY29sb3I6IHRyYW5zcGFyZW50ICFpbXBvcnRhbnQ7Cn0KLnVuY2hlY2tlZCAud2ViZXgtY2hlY2tib3hncm91cCA+IGxhYmVsLndlYmV4LWNvcnJlY3QsCi51bmNoZWNrZWQgLndlYmV4LWNoZWNrYm94Z3JvdXAgPiBsYWJlbC53ZWJleC1pbmNvcnJlY3QgewogIGJhY2tncm91bmQtY29sb3I6IHRyYW5zcGFyZW50Owp9CgoKCg==" download="webex.css">Download webex.css</a><!--/html_preserve-->.
- <!--html_preserve--><a href="data:application/javascript;base64,PHNjcmlwdD4KCi8qIGRlZmluaXRpb24gb2YgY29udGVudCBmb3IgdGhlIGJ1dHRvbnMgKi8KY29uc3Qgd2ViZXhfYnV0dG9ucyA9IHtjaGVja19oaWRkZW46ICAgICAgICAgICI8Yj4mY2hlY2s7PC9iPiIsCiAgICAgICAgICAgICAgICAgICAgICAgY2hlY2tfaGlkZGVuX2FsdDogICAgICAiQ2hlY2sgYW5zd2VyIiwKICAgICAgICAgICAgICAgICAgICAgICBjaGVja19zaG93bjogICAgICAgICAgICI8Yj4mbHNoOzwvYj4iLAogICAgICAgICAgICAgICAgICAgICAgIGNoZWNrX3Nob3duX2FsdDogICAgICAgIkhpZGUgY2hlY2siLAogICAgICAgICAgICAgICAgICAgICAgIGNoZWNrX29mX3RvdGFsOiAgICAgICAgIi8iLAogICAgICAgICAgICAgICAgICAgICAgIHNvbHV0aW9uOiAgICAgICAgICAgICAgIjxiPiZxdWVzdDs8L2I+IiwKICAgICAgICAgICAgICAgICAgICAgICBzb2x1dGlvbl9hbHQ6ICAgICAgICAgICJDb3JyZWN0IHNvbHV0aW9uIiwKICAgICAgICAgICAgICAgICAgICAgICBxdWVzdGlvbl9uZXh0OiAgICAgICAgICI8Yj4mIzg2MzQ7PC9iPiIsCiAgICAgICAgICAgICAgICAgICAgICAgcXVlc3Rpb25fbmV4dF9hbHQ6ICAgICAiTmV4dCBxdWVzdGlvbiIsCiAgICAgICAgICAgICAgICAgICAgICAgcXVlc3Rpb25fcHJldmlvdXM6ICAgICAiIiwKICAgICAgICAgICAgICAgICAgICAgICBxdWVzdGlvbl9wcmV2aW91c19hbHQ6ICIifQoKLyogdXBkYXRlIHRvdGFsIGNvcnJlY3QgaWYgI3dlYmV4LXRvdGFsX2NvcnJlY3QgZXhpc3RzICovCnVwZGF0ZV90b3RhbF9jb3JyZWN0ID0gZnVuY3Rpb24oKSB7CiAgY29uc29sZS5sb2coIndlYmV4OiB1cGRhdGUgdG90YWxfY29ycmVjdCIpOwoKICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCIud2ViZXgtdG90YWxfY29ycmVjdCIpLmZvckVhY2godG90YWwgPT4gewogICAgcCA9IHRvdGFsLmNsb3Nlc3QoIi53ZWJleC1ib3giKTsKICAgIHZhciBjb3JyZWN0ID0gcC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lKCJ3ZWJleC1jb3JyZWN0IikubGVuZ3RoOwogICAgdmFyIHNvbHZlbWVzID0gcC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lKCJ3ZWJleC1zb2x2ZW1lIikubGVuZ3RoOwogICAgdmFyIHJhZGlvZ3JvdXBzID0gcC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lKCJ3ZWJleC1yYWRpb2dyb3VwIikubGVuZ3RoOwogICAgdmFyIHNlbGVjdHMgPSBwLmdldEVsZW1lbnRzQnlDbGFzc05hbWUoIndlYmV4LXNlbGVjdCIpLmxlbmd0aDsKICAgIC8qIG5vIHNwZWNpZmljIGNsYXNzIG9uIGlucHV0IG5vZGUsIHRodXMgc2VhcmNoaW5nIHZpYSBxdWVyeSBzZWxlY3RvciAqLwogICAgdmFyIGNoZWNrYm94Z3JvdXBzID0gcC5xdWVyeVNlbGVjdG9yQWxsKCJkaXZbY2xhc3M9d2ViZXgtY2hlY2tib3hncm91cF0gaW5wdXRbdHlwZT1jaGVja2JveF0iKS5sZW5ndGgKCiAgICAvKiBzaG93IG51bWJlciBvZiBjb3JyZWN0IC8gdG90YWwgbnVtYmVyIG9mIGFuc3dlcnMgKi8KICAgIHRvdGFsLmlubmVySFRNTCA9IGNvcnJlY3QgKyAiJm5ic3A7IiArIHdlYmV4X2J1dHRvbnMuY2hlY2tfb2ZfdG90YWwgKyAiJm5ic3A7IiArIChzb2x2ZW1lcyArIHJhZGlvZ3JvdXBzICsgY2hlY2tib3hncm91cHMgKyBzZWxlY3RzKTsKICB9KTsKfQoKLyogY2hlY2sgYW5zd2VycyAqLwpjaGVja19mdW5jID0gZnVuY3Rpb24oKSB7CiAgY29uc29sZS5sb2coIndlYmV4OiBjaGVjayBhbnN3ZXIiKTsKCiAgLy92YXIgY2wgPSB0aGlzLnBhcmVudEVsZW1lbnQuY2xhc3NMaXN0OwogIHZhciBjbCA9IHRoaXMuY2xvc2VzdCgiLndlYmV4LWJveCIpLmNsYXNzTGlzdDsKICBpZiAoY2wuY29udGFpbnMoInVuY2hlY2tlZCIpKSB7CiAgICBjbC5yZW1vdmUoInVuY2hlY2tlZCIpOwogICAgdGhpcy5pbm5lckhUTUwgPSB3ZWJleF9idXR0b25zLmNoZWNrX3Nob3duOyAvLyJIaWRlIGNoZWNrIjsKICAgIGlmICh3ZWJleF9idXR0b25zLmNoZWNrX3Nob3duX2FsdC5sZW5ndGggPiAwKSB0aGlzLnNldEF0dHJpYnV0ZSgidGl0bGUiLCB3ZWJleF9idXR0b25zLmNoZWNrX3Nob3duX2FsdCk7CiAgfSBlbHNlIHsKICAgIGNsLmFkZCgidW5jaGVja2VkIik7CiAgICB0aGlzLmlubmVySFRNTCA9IHdlYmV4X2J1dHRvbnMuY2hlY2tfaGlkZGVuOyAvLyJDaGVjayBhbnN3ZXIiOwogICAgaWYgKHdlYmV4X2J1dHRvbnMuY2hlY2tfaGlkZGVuX2FsdC5sZW5ndGggPiAwKSB0aGlzLnNldEF0dHJpYnV0ZSgidGl0bGUiLCB3ZWJleF9idXR0b25zLmNoZWNrX2hpZGRlbl9hbHQpOwogIH0KfQoKLyogU2hvdy9oaWRlIGNvcnJlY3Qgc29sdXRpb24gKi8Kc29sdXRpb25fZnVuYyA9IGZ1bmN0aW9uKCkgewogIGNvbnNvbGUubG9nKCJ3ZWJleDogc2hvdy9oaWRlIHNvbHV0aW9uIik7CgogIHZhciBkaXYgPSB0aGlzLmNsb3Nlc3QoIi53ZWJleC1xdWVzdGlvbiIpLnF1ZXJ5U2VsZWN0b3IoIi53ZWJleC1zb2x1dGlvbiIpOwogIHZhciBjbCA9IGRpdi5jbGFzc0xpc3Q7CgogIGlmIChjbC5jb250YWlucygidmlzaWJsZSIpKSB7CiAgICBjbC5yZW1vdmUoInZpc2libGUiKTsKICB9IGVsc2UgewogICAgY2wuYWRkKCJ2aXNpYmxlIik7CiAgfQp9CgovKiBmdW5jdGlvbiB0byBjaGVjayBpZiB0aGUgcmVhbCBhbnN3ZXIgaXMgbnVtZXJpYyAqLwpjb252ZXJ0X3RvX251bWVyaWMgPSBmdW5jdGlvbih4KSB7CiAgICBpZiAodHlwZW9mIHggPT0gInN0cmluZyIpIHsKICAgICAgICAvKiBkbyBub3RoaW5nICovCiAgICB9IGVsc2UgaWYgKHgubGVuZ3RoID09IDEpIHsKICAgICAgICAvKiB0YWtlIGZpcnN0IGVsZW1lbnQgKi8KICAgICAgICB4ID0geFswXQogICAgfSBlbHNlIHsKICAgICAgICByZXR1cm4gTmFOOwogICAgfQoKICAgIC8qIHJlbW92ZSBzcGFjZXMgZm9yIGVhc2llciBwYXJzaW5nICovCiAgICB4ID0geC5yZXBsYWNlKC9ccy9nLCAiIik7CgogICAgLyogRGVmaW5lIHBhdHRlcm5zIGZvciBkaWZmZXJlbnQgZm9ybWF0cywgbm90ZSB0aGF0IHNwYWNlcyBoYXZlIGJlZW4gcmVtb3ZlZCBhYm92ZSAqLwogICAgY29uc3QgcGF0dGVybnMgPSBbCiAgICAgICAge3JlZ2V4OiAvXlsrLV0/XGQrKFwuXGR7M30pKixcZCskLywgZGVjaW1hbDogIiwiLCB0aG91c2FuZDogIi4iIH0sICAvLyBGb3JtYXQ6ICIxLjEwMC4xMDAuMTAwLDMiCiAgICAgICAge3JlZ2V4OiAvXlsrLV0/XGQrKCxcZHszfSkqXC5cZCskLywgZGVjaW1hbDogIi4iLCB0aG91c2FuZDogIiwiIH0sICAvLyBGb3JtYXQ6ICIxLDEwMCwxMDAsMTAwLjMiCiAgICAgICAge3JlZ2V4OiAvXlsrLV0/XGQrKFwuXGQrKT8kLywgZGVjaW1hbDogIi4iIH0sICAgICAgICAgICAgICAgICAgICAgICAvLyBGb3JtYXQ6ICIxMTAwMTAwMTAwLjUiCiAgICAgICAge3JlZ2V4OiAvXlsrLV0/XGQrLFxkKyQvLCBkZWNpbWFsOiAiLCIgfSAgICAgICAgICAgICAgICAgICAgICAgICAgICAvLyBGb3JtYXQ6ICIxMTAwMTAwMTAwLDUiCiAgICBdOwoKICAgIC8qIHRlc3RpbmcgYWxsIHJlZ3VsYXIgZXhwcmVzc2lvbnMsIGNvbnZlcnQgdG8gZmxvYXQgaWYgcG9zc2libGUgKi8KICAgIGZvciAoY29uc3QgeyByZWdleCwgZGVjaW1hbCwgdGhvdXNhbmQgfSBvZiBwYXR0ZXJucykgewogICAgICAgIGlmIChyZWdleC50ZXN0KHgpKSB7CiAgICAgICAgICAgIGxldCBudW1lcmljID0geDsKICAgICAgICAgICAgaWYgKHRob3VzYW5kKSBudW1lcmljID0gbnVtZXJpYy5yZXBsYWNlKG5ldyBSZWdFeHAoYFxcJHt0aG91c2FuZH1gLCAiZyIpLCAiIik7CiAgICAgICAgICAgIG51bWVyaWMgPSBudW1lcmljLnJlcGxhY2UoZGVjaW1hbCwgIi4iKTsKICAgICAgICAgICAgcmV0dXJuIHBhcnNlRmxvYXQobnVtZXJpYyk7CiAgICAgICAgfQogICAgfQogICAgCiAgICAvKiBpbnB1dCBvZiBsZW5ndGggMSBidXQgbm9uZSBvZiB0aGUga25vd24gZm9ybWF0cywgcmV0dXJuIE5hTiAqLwogICAgcmV0dXJuIE5hTjsKfQoKLyogZnVuY3Rpb24gZm9yIGNoZWNraW5nIHNvbHZlbWUgYW5zd2VycyAqLwpzb2x2ZW1lX2Z1bmMgPSBmdW5jdGlvbihlKSB7CiAgLyogYXZvaWQgdGhhdCBrZXl1cCBhbmQga2V5Y2hhbmdlIHR3aWNlIGV4ZWN1dGUgdGhpcyBmdW5jdGlvbiB3aXRoaW4gbm1zID0gMTAKICAgKiBtcywgY2xlYXJpbmcgaW5wdXRUaW1lciBhbmQgYWRkIHRpbWVvdXQgKi8KICBjb25zb2xlLmxvZygid2ViZXg6IGNoZWNrIHNvbHZlbWUiKTsKCiAgLyogZmxvYXQsIHByZWNpc2lvbiBmb3IgY2hlY2tpbmcgbnVtZXJpYyBhbnN3ZXJzICovCiAgY29uc3QgZXBzID0gMC4wMDAwMDAwMDAwMDAwMTsKCiAgLyogZ2V0IGxhc3QgY2hlY2tlZCB1c2VyIGFuc3dlciAqLwogIGNvbnN0IHF1ZXN0aW9uID0gdGhpcy5jbG9zZXN0KCIud2ViZXgtcXVlc3Rpb24iKQoKICAvKiBleHRyYWN0aW5nIGNsYXNzZXMgKi8KICB2YXIgY2wgPSB0aGlzLmNsYXNzTGlzdDsKICB2YXIgbXlfYW5zd2VyID0gdGhpcy52YWx1ZTsKCiAgLyogZW1wdHkgYW5zd2VyPyBKb2IgZG9uZSAqLwogIGlmIChteV9hbnN3ZXIgPT0gIiIpIHsKICAgIGNsLnJlbW92ZSgid2ViZXgtY29ycmVjdCIpOwogICAgY2wucmVtb3ZlKCJ3ZWJleC1pbmNvcnJlY3QiKTsKICAgIHJldHVybiBmYWxzZTsKICB9CgogIC8qICJFbHNlIiB3ZSBjb250aW51ZSBldmFsdWF0aW5nIHRoZSBhbnN3ZXIgKi8KICB2YXIgcmVhbF9hbnN3ZXJzID0gSlNPTi5wYXJzZSh0aGlzLmRhdGFzZXQuYW5zd2VyKTsKCiAgLyogYnkgZGVmYXVsdCB3ZSBhc3N1bWUgdGhlIHVzZXJzJyBhbnN3ZXIgaXMgaW5jb3JyZWN0ICovCiAgdmFyIHVzZXJfYW5zd2VyX2NvcnJlY3QgPSBmYWxzZTsKCiAgLyogY2hlY2sgaWYgdGhlIGNvcnJlY3QgYW5zd2VyIGlzIG51bWVyaWMsIGkuZS4gaWYgCiAgICogcmVhbF9hbnN3ZXJzIGlzIG9mIGxlbmd0aCAxIGNvbnRhaW5pbmcgb25lIHNpbmdsZSBudW1lcmljCiAgICogdmFsdWUgaW4gYSBrbm93biBmb3JtYXQsIGVsc2UsIE5hTiBpcyByZXR1cm5lZCAqLwogIGNvbnN0IG51bV9yZWFsX2Fuc3dlciA9IGNvbnZlcnRfdG9fbnVtZXJpYyhyZWFsX2Fuc3dlcnMpOwogIGNvbnN0IG51bV9teV9hbnN3ZXIgICA9IGNvbnZlcnRfdG9fbnVtZXJpYyhteV9hbnN3ZXIpOwoKICAvKiBpZiB0aGUgY29ycmVjdCBhbnN3ZXIgaXMgbnVtZXJpYyAoZmxvYXQpLCB0aGUgdXNlcidzIGFuc3dlcgogICAqIG11c3QgYWxzbyBiZSBudW1lcmljLiBJZiBub3QsIGl0IGlzIHdyb25nLiBFbHNlIHdlIGNhbgogICAqIGNvbXBhcmUgZmxvYXRpbmcgcG9pbnQgbnVtYmVycyAqLwogIGlmICghaXNOYU4obnVtX3JlYWxfYW5zd2VyKSAmJiAhaXNOYU4obnVtX215X2Fuc3dlcikpIHsKICAgIC8vREVWLy8gY29uc29sZS5sb2coIndlYmV4OiBldmFsdWF0aW5nIG51bWVyaWMgYW5zd2VyIikKICAgIC8qIGNoZWNrIGlmIHRoZSByZWFsIGFuc3dlciBhbmQgdGhlIHVzZXIgaW5wdXQgYXJlIG51bWVyaWNhbGx5IHRoZSBzYW1lOwogICAgICogYWRkaW5nICdkZWx0YScgdG8gYXZvaWQgcHJlY2lzaW9uIGlzc3VlcyAqLwogICAgdmFyIGRpZmYgPSBNYXRoLmFicyhudW1fcmVhbF9hbnN3ZXIgLSBudW1fbXlfYW5zd2VyKTsKICAgIGlmIChkaWZmIDwgcGFyc2VGbG9hdCh0aGlzLmRhdGFzZXQudG9sKSArIGVwcykgeyB1c2VyX2Fuc3dlcl9jb3JyZWN0ID0gdHJ1ZTsgfQoKICAvKiBpZiB0aGUgcXVlc3Rpb24gY29udGFpbnMgcmVnZXgsIGEgcmVndWxhciBleHByZXNzaW9uIGlzIHVzZWQKICAgKiB0byBldmFsdWF0ZSB0aGUgdXNlcnMgYW5zd2VyIChvbmx5IHBvc3NpYmxlIGlmIGxlbmd0aCBvZiBhbnN3ZXJzIGlzIDEpICovCiAgfSBlbHNlIGlmIChjbC5jb250YWlucygicmVnZXgiKSAmJiByZWFsX2Fuc3dlcnMubGVuZ3RoID09IDEpIHsKICAgIC8vY29uc29sZS5sb2coIndlYmV4OiBldmFsdWF0aW5nIGFuc3dlciB1c2luZyByZWd1bGFyIGV4cHJlc3Npb24iKQogICAgbGV0IHJlZ2V4ID0gbmV3IFJlZ0V4cChyZWFsX2Fuc3dlcnNbMF0sIGNsLmNvbnRhaW5zKCJpZ25vcmVjYXNlIikgPyAiaSIgOiAiIik7CiAgICBpZiAocmVnZXgudGVzdChteV9hbnN3ZXIpKSB7IHVzZXJfYW5zd2VyX2NvcnJlY3QgPSB0cnVlOyB9CgogIC8qIGVsc2Ugd2UgZXZhbHVhdGUgb24gJ3N0cmluZyBsZXZlbCcsIGNvbnNpZGVyaW5nIHRoZSBjcmVhdG9ycyBwcmVmZXJlbmNlcwogICAqIHJlZ2FyZGluZyBzZXQgb3B0aW9ucyAqLwogIH0gZWxzZSB7CiAgICAvL2NvbnNvbGUubG9nKCJ3ZWJleDogZXZhbHVhdGluZyBzdHJpbmcgYW5zd2VyIikKICAgIC8qIG1vZGlmeS9wcmVwYXJlIGFuc3dlciAqLwogICAgaWYgKGNsLmNvbnRhaW5zKCJpZ25vcmVjYXNlIikpIHsgbXlfYW5zd2VyID0gbXlfYW5zd2VyLnRvTG93ZXJDYXNlKCk7IH0KICAgIGlmIChjbC5jb250YWlucygibm9zcGFjZXMiKSkgICB7IG15X2Fuc3dlciA9IG15X2Fuc3dlci5yZXBsYWNlKC8gL2csICIiKTsgfQoKICAgIC8qIGlmIHRoZSByZWFsIGFuc3dlciBpbmNsdWRlcyB1c2VyIGlucHV0IC0gY29ycmVjdCAqLwogICAgaWYgKHJlYWxfYW5zd2Vycy5pbmNsdWRlcyhteV9hbnN3ZXIpKSB7CiAgICAgIHVzZXJfYW5zd2VyX2NvcnJlY3QgPSB0cnVlOwogIAogICAgICAvLyBhZGRlZCByZWdleCBiaXQKICAgICAgaWYgKGNsLmNvbnRhaW5zKCJyZWdleCIpKSB7CiAgICAgICAgYW5zd2VyX3JlZ2V4ID0gUmVnRXhwKHJlYWxfYW5zd2Vycy5qb2luKCJ8IikpCiAgICAgICAgaWYgKGFuc3dlcl9yZWdleC50ZXN0KG15X2Fuc3dlcikpIHsKICAgICAgICAgIGNsLmFkZCgid2ViZXgtY29ycmVjdCIpOwogICAgICAgIH0KICAgICAgfQogICAgfQogIH0KCiAgaWYgKHVzZXJfYW5zd2VyX2NvcnJlY3QpIHsKICAgICAgY2wuYWRkKCJ3ZWJleC1jb3JyZWN0Iik7CiAgICAgIGNsLnJlbW92ZSgid2ViZXgtaW5jb3JyZWN0Iik7CiAgfSBlbHNlIHsKICAgICAgY2wuYWRkKCJ3ZWJleC1pbmNvcnJlY3QiKTsKICAgICAgY2wucmVtb3ZlKCJ3ZWJleC1jb3JyZWN0Iik7CiAgfQoKICB1cGRhdGVfdG90YWxfY29ycmVjdCgpOwoKfQoKLyogZnVuY3Rpb24gZm9yIGNoZWNraW5nIHNlbGVjdCBhbnN3ZXJzICovCnNlbGVjdF9mdW5jID0gZnVuY3Rpb24oZSkgewogIGNvbnNvbGUubG9nKCJ3ZWJleDogY2hlY2sgc2VsZWN0Iik7CgogIHZhciBjbCA9IHRoaXMuY2xhc3NMaXN0CgogIC8qIGFkZCBzdHlsZSAqLwogIGNsLnJlbW92ZSgid2ViZXgtaW5jb3JyZWN0Iik7CiAgY2wucmVtb3ZlKCJ3ZWJleC1jb3JyZWN0Iik7CiAgaWYgKHRoaXMudmFsdWUgPT0gImFuc3dlciIpIHsKICAgIGNsLmFkZCgid2ViZXgtY29ycmVjdCIpOwogIH0gZWxzZSBpZiAodGhpcy52YWx1ZSAhPSAiYmxhbmsiKSB7CiAgICBjbC5hZGQoIndlYmV4LWluY29ycmVjdCIpOwogIH0KCiAgdXBkYXRlX3RvdGFsX2NvcnJlY3QoKTsKfQoKLyogZnVuY3Rpb24gZm9yIGNoZWNraW5nIHJhZGlvZ3JvdXBzIGFuc3dlcnMgKi8KcmFkaW9ncm91cHNfZnVuYyA9IGZ1bmN0aW9uKGUpIHsKICBjb25zb2xlLmxvZygid2ViZXg6IGNoZWNrIHJhZGlvZ3JvdXBzIik7CgogIHZhciBjaGVja2VkX2J1dHRvbiA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoImlucHV0W25hbWU9IiArIHRoaXMuaWQgKyAiXTpjaGVja2VkIik7CiAgdmFyIGNsID0gY2hlY2tlZF9idXR0b24ucGFyZW50RWxlbWVudC5jbGFzc0xpc3Q7CiAgdmFyIGxhYmVscyA9IGNoZWNrZWRfYnV0dG9uLnBhcmVudEVsZW1lbnQucGFyZW50RWxlbWVudC5jaGlsZHJlbjsKCiAgLyogZ2V0IHJpZCBvZiBzdHlsZXMgKi8KICBmb3IgKGkgPSAwOyBpIDwgbGFiZWxzLmxlbmd0aDsgaSsrKSB7CiAgICBsYWJlbHNbaV0uY2xhc3NMaXN0LnJlbW92ZSgid2ViZXgtaW5jb3JyZWN0Iik7CiAgICBsYWJlbHNbaV0uY2xhc3NMaXN0LnJlbW92ZSgid2ViZXgtY29ycmVjdCIpOwogIH0KCiAgLyogYWRkIHN0eWxlICovCiAgaWYgKGNoZWNrZWRfYnV0dG9uLnZhbHVlID09ICJhbnN3ZXIiKSB7CiAgICBjbC5hZGQoIndlYmV4LWNvcnJlY3QiKTsKICB9IGVsc2UgewogICAgY2wuYWRkKCJ3ZWJleC1pbmNvcnJlY3QiKTsKICB9CgogIHVwZGF0ZV90b3RhbF9jb3JyZWN0KCk7Cn0KCgovKiBmdW5jdGlvbiBmb3IgY2hlY2tpbmcgY2hlY2tib3hncm91cHMgYW5zd2VycyAqLwpjaGVja2JveGdyb3Vwc19mdW5jID0gZnVuY3Rpb24oZSkgewogIGNvbnNvbGUubG9nKCJ3ZWJleDogY2hlY2sgY2hlY2tib3hncm91cHMiKTsKCiAgLyogbGlzdCBvZiBhbGwgYW5zd2VyIGVsZW1lbnRzIChjb3JyZWN0IGFuZCBpbmNvcnJlY3QpICovCiAgdmFyIGlucHV0cyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoImRpdltpZD0nIiArIHRoaXMuaWQgKyAiJ10gaW5wdXQiKQoKICAvKiBzZXR0aW5nIGNsYXNzIGZvciBjb3JyZWN0L2luY29ycmVjdCBhbnN3ZXJzICovCiAgaW5wdXRzLmZvckVhY2goZnVuY3Rpb24oaW5wdXQpIHsKICAgICAgdmFyIGxhYmVsID0gaW5wdXQucGFyZW50Tm9kZQogICAgICBpZiAoKGlucHV0LmNoZWNrZWQgJiYgaW5wdXQudmFsdWUgPT0gImFuc3dlciIpIHx8ICghaW5wdXQuY2hlY2tlZCAmJiBpbnB1dC52YWx1ZSA9PSAiIikpIHsKICAgICAgICAgIC8vaW5wdXQuc2V0QXR0cmlidXRlKCJjbGFzcyIsICJ3ZWJleC1jb3JyZWN0IikKICAgICAgICAgIGxhYmVsLnNldEF0dHJpYnV0ZSgiY2xhc3MiLCAid2ViZXgtY29ycmVjdCIpCiAgICAgIH0gZWxzZSB7CiAgICAgICAgICBsYWJlbC5zZXRBdHRyaWJ1dGUoImNsYXNzIiwgIndlYmV4LWluY29ycmVjdCIpCiAgICAgIH0KICB9KTsKCiAgdXBkYXRlX3RvdGFsX2NvcnJlY3QoKTsKfQoKLyogc2h1ZmZsaW5nIGFycmF5ICh0aGFua3MgdG8gc3RhY2sgb3ZlcmZsb3cpCiAqIElmIGFyZ3VtZW50IHggaXMgYW4gaW50ZWdlciB3ZSBjcmVhdGUgYW4gaW50ZWdlciBzZXF1ZW5jZQogKiBmcm9tIDAsIDEsIC4uLiwgKHggLSAxKSBhbmQgcmV0dXJuIGEgc2h1ZmZsZWQgdmVyc2lvbi4gSWYKICogdGhlIGlucHV0IGlzIGFuIGFycmF5LCB3ZSBzaW1wbHkgc2h1ZmZsZSBpdCAqLwpzaHVmZmxlX2FycmF5ID0gZnVuY3Rpb24oeCkgewogICBpZiAoTnVtYmVyLmlzSW50ZWdlcih4KSAmJiAhaXNOYU4oeCkpIHsKICAgICB4ID0gQXJyYXkuZnJvbSh7bGVuZ3RoOiB4fSwgKHYsIGkpID0+IGkpOwogICB9CiAgIGxldCBzaHVmZmxlZCA9IHgubWFwKHZhbHVlID0+ICh7IHZhbHVlLCBzb3J0OiBNYXRoLnJhbmRvbSgpIH0pKQogICAgICAgIC5zb3J0KChhLCBiKSA9PiBhLnNvcnQgLSBiLnNvcnQpLm1hcCgoeyB2YWx1ZSB9KSA9PiB2YWx1ZSkKICAgcmV0dXJuIHNodWZmbGVkOwp9CgovKiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICogLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCiAqIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSAqLwp3aW5kb3cub25sb2FkID0gZnVuY3Rpb24oKSB7CiAgY29uc29sZS5sb2coIndlYmV4IG9ubG9hZCIpOwoKICAvKiBzZXR0aW5nIHVwIGJ1dHRvbnMgYW5kIGFjdGlvbnMgdG8gc2hvdy9oaWRlIGFuc3dlcnMgKi8KICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCIud2ViZXgtY2hlY2siKS5mb3JFYWNoKHNlY3Rpb24gPT4gewogICAgc2VjdGlvbi5jbGFzc0xpc3QuYWRkKCJ1bmNoZWNrZWQiKTsKCiAgICAvKiB1bCB0byB0YWtlIHVwIHRoZSBsaXN0IGl0ZW1zIHdpdGggYnV0dG9ucyAqLwogICAgbGV0IGJ1dHRvbl91bCA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoInVsIik7CiAgICBidXR0b25fdWwuc2V0QXR0cmlidXRlKCJjbGFzcyIsICJ3ZWJleC1idXR0b24tbGlzdCIpOwogICAgc2VjdGlvbi5hcHBlbmRDaGlsZChidXR0b25fdWwpOwoKICAgIC8qIGJ1dHRvbiB0byBfY2hlY2tfIGlmIGFuc3dlcnMgZ2l2ZW4gYXJlIGNvcnJlY3QgKi8KICAgIGxldCBsaV9jaGVjayA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoImxpIik7CiAgICBidXR0b25fdWwuYXBwZW5kQ2hpbGQobGlfY2hlY2spOyAvKiBhZGQgbGlzdCBpdGVtIHRvIHVsICovCiAgICBsZXQgYnRuX2NoZWNrID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgiYnV0dG9uIik7CiAgICBidG5fY2hlY2suaW5uZXJIVE1MID0gd2ViZXhfYnV0dG9ucy5jaGVja19oaWRkZW47ICAvLyAiQ2hlY2sgYW5zd2VyIjsKICAgIGJ0bl9jaGVjay5zZXRBdHRyaWJ1dGUoImNsYXNzIiwgIndlYmV4LWJ1dHRvbiB3ZWJleC1idXR0b24tY2hlY2siKTsKICAgIGlmICh3ZWJleF9idXR0b25zLmNoZWNrX2hpZGRlbl9hbHQubGVuZ3RoID4gMCkgYnRuX2NoZWNrLnNldEF0dHJpYnV0ZSgidGl0bGUiLCB3ZWJleF9idXR0b25zLmNoZWNrX2hpZGRlbl9hbHQpOwogICAgYnRuX2NoZWNrLm9uY2xpY2sgPSBjaGVja19mdW5jOwogICAgbGlfY2hlY2suYXBwZW5kQ2hpbGQoYnRuX2NoZWNrKTsKCiAgICAvKiBzcGFuIHRvIHNob3cgY3VycmVudCBudW1iZXIgb2YgcG9pbnRzICh3aGVuIF9jaGVja18gYWN0aXZlKSAqLwogICAgbGV0IHNwbiA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoInNwYW4iKTsKICAgIHNwbi5jbGFzc0xpc3QuYWRkKCJ3ZWJleC10b3RhbF9jb3JyZWN0Iik7CiAgICBsaV9jaGVjay5hcHBlbmRDaGlsZChzcG4pOwoKICAgIC8qIGJ1dHRvbiB0byBzaG93IHRoZSBfc29sdXRpb25fIGlmIHRoZXJlIGlzIG9uZSAqLwogICAgdmFyIGhhc19zb2x1dGlvbiA9IHNlY3Rpb24ucGFyZW50Tm9kZS5xdWVyeVNlbGVjdG9yQWxsKCIud2ViZXgtc29sdXRpb24iKS5sZW5ndGggPiAwOwogICAgaWYgKGhhc19zb2x1dGlvbikgewogICAgICBsZXQgbGlfc29sdXRpb24gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCJsaSIpOwogICAgICBidXR0b25fdWwuYXBwZW5kQ2hpbGQobGlfc29sdXRpb24pOyAvKiBhZGQgbGlzdCBpdGVtIHRvIHVsICovCiAgICAgIGxldCBidG5fc29sdXRpb24gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCJidXR0b24iKTsKICAgICAgYnRuX3NvbHV0aW9uLmlubmVySFRNTCA9IHdlYmV4X2J1dHRvbnMuc29sdXRpb247IC8vICJDb3JyZWN0IGFuc3dlciI7CiAgICAgIGJ0bl9zb2x1dGlvbi5zZXRBdHRyaWJ1dGUoImNsYXNzIiwgIndlYmV4LWJ1dHRvbiB3ZWJleC1idXR0b24tc29sdXRpb24iKTsKICAgICAgaWYgKHdlYmV4X2J1dHRvbnMuc29sdXRpb25fYWx0Lmxlbmd0aCA+IDApIGJ0bl9zb2x1dGlvbi5zZXRBdHRyaWJ1dGUoInRpdGxlIiwgd2ViZXhfYnV0dG9ucy5zb2x1dGlvbl9hbHQpOwogICAgICBidG5fc29sdXRpb24ub25jbGljayA9IHNvbHV0aW9uX2Z1bmM7CiAgICAgIGxpX3NvbHV0aW9uLmFwcGVuZENoaWxkKGJ0bl9zb2x1dGlvbik7CiAgICB9CgogIH0pOwoKICAvKiBzZXQgdXAgd2ViZXgtc29sdmVtZSBpbnB1dHMgKi8KICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCIud2ViZXgtc29sdmVtZSIpLmZvckVhY2goc29sdmVtZSA9PiB7CiAgICBzb2x2ZW1lLnNldEF0dHJpYnV0ZSgiYXV0b2NvbXBsZXRlIiwib2ZmIik7CiAgICBzb2x2ZW1lLnNldEF0dHJpYnV0ZSgiYXV0b2NvcnJlY3QiLCAib2ZmIik7CiAgICBzb2x2ZW1lLnNldEF0dHJpYnV0ZSgiYXV0b2NhcGl0YWxpemUiLCAib2ZmIik7CiAgICBzb2x2ZW1lLnNldEF0dHJpYnV0ZSgic3BlbGxjaGVjayIsICJmYWxzZSIpOwogICAgc29sdmVtZS52YWx1ZSA9ICIiOwoKICAgIC8qIGFkanVzdCBhbnN3ZXIgZm9yIGlnbm9yZWNhc2Ugb3Igbm9zcGFjZXMgKi8KICAgIGlmIChzb2x2ZW1lLmNsYXNzTGlzdC5jb250YWlucygiaWdub3JlY2FzZSIpKSB7CiAgICAgIHNvbHZlbWUuZGF0YXNldC5hbnN3ZXIgPSBzb2x2ZW1lLmRhdGFzZXQuYW5zd2VyLnRvTG93ZXJDYXNlKCk7CiAgICB9CiAgICAvKiBhZGp1c3QgYW5zd2VyIGZvciAnbm8gc3BhY2VzJyAoaWdub3JlIHNwYWNlcykgKi8KICAgIGlmIChzb2x2ZW1lLmNsYXNzTGlzdC5jb250YWlucygibm9zcGFjZXMiKSkgewogICAgICBzb2x2ZW1lLmRhdGFzZXQuYW5zd2VyID0gc29sdmVtZS5kYXRhc2V0LmFuc3dlci5yZXBsYWNlKC8gL2csICIiKTsKICAgIH0KCiAgICAvKiBhdHRhY2ggY2hlY2tpbmcgZnVuY3Rpb24sIHRyaWdnZXJlZCBvbiBrZXkgdXAsIGNoYW5nZSwgYW5kIHdoZW4KICAgICAqIGVsZW1udCBpcyBvdXQgb2YgZm9jdXMuIE9ubHkgZXZhbHVhdGVkIG9uY2UgYnkgdHJhY2tpbmcgY2hhbmdlcwogICAgICogdmlhIHZhcmlhYmxlIHNvbHZlbWVfbGFzdF91c2VyX2Fuc3dlciAqLwogICAgc29sdmVtZS5hZGRFdmVudExpc3RlbmVyKCJrZXl1cCIsICBzb2x2ZW1lX2Z1bmMpOwogICAgc29sdmVtZS5hZGRFdmVudExpc3RlbmVyKCJjaGFuZ2UiLCBzb2x2ZW1lX2Z1bmMpOwogICAgc29sdmVtZS5hZGRFdmVudExpc3RlbmVyKCJibHVyIiwgICBzb2x2ZW1lX2Z1bmMpOwoKICAgIC8qIGFkZGluZyBzcGFuIHRvIHNob3cgY29ycmVjdC9pbmNvcnJlY3QgaWNvbiAqLwogICAgc29sdmVtZS5pbnNlcnRBZGphY2VudEhUTUwoImFmdGVyZW5kIiwgIiA8c3BhbiBjbGFzcz0nd2ViZXgtaWNvbic+PC9zcGFuPiIpCiAgfSk7CgogIC8qIHNldCB1cCByYWRpb2dyb3VwcyAoc2luZ2xlIGNob2ljZSBxdWVzdGlvbnMgd2l0aCBkaXNwbGF5ID0gImJ1dHRvbnMiKSAqLwogIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoIi53ZWJleC1yYWRpb2dyb3VwIikuZm9yRWFjaChyYWRpb2dyb3VwID0+IHsKICAgIHJhZGlvZ3JvdXAub25jaGFuZ2UgPSByYWRpb2dyb3Vwc19mdW5jOwogIH0pOwoKICAvKiBzZXQgdXAgY2hlY2tib3hncm91cHMgKG11bHRpcGxlIGNob2ljZSBxdWVzdGlvbnMgd2l0aCBkaXNwbGF5ID0gImJ1dHRvbnMiKSAqLwogIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoIi53ZWJleC1jaGVja2JveGdyb3VwIikuZm9yRWFjaChjaGVja2JveGdyb3VwID0+IHsKICAgIGNoZWNrYm94Z3JvdXAub25jaGFuZ2UgPSBjaGVja2JveGdyb3Vwc19mdW5jOwogIH0pOwoKICAvKiBzZXQgdXAgc2VsZWN0cyAoZHJvcGRvd24gbWVudXMpICovCiAgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgiLndlYmV4LXNlbGVjdCIpLmZvckVhY2goc2VsZWN0ID0+IHsKICAgIHNlbGVjdC5vbmNoYW5nZSA9IHNlbGVjdF9mdW5jOwogICAgLyogYXBwZW5kIHdlYmV4LWljb24gZm9yIGNvcnJlY3QvaW5jb3JyZWN0IGljb25zICovCiAgICB2YXIgZWxlbSA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoInNwYW4iKQogICAgZWxlbS5jbGFzc0xpc3QuYWRkKCJ3ZWJleC1pY29uIikKICAgIHNlbGVjdC5wYXJlbnROb2RlLmFwcGVuZENoaWxkKGVsZW0pCiAgfSk7CgogIC8qIGNoYW5nZSB0byBuZXh0L3ByZXZpb3VzIHF1ZXN0aW9uIGlmIG11bHRpcGxlIGFyZSBhdmFpbGFibGUgKi8KICBmdW5jdGlvbiBoYW5kbGVRdWVzdGlvbkNsaWNrKGdyb3VwLCBxdWVzdGlvbnMsIHN0ZXApIHsKICAgIHJldHVybiBhc3luYyBmdW5jdGlvbigpIHsKICAgICAgLyogZ2V0IHF1ZXN0aW9uIG9yZGVyIGFzIGludGVnZXIgdmVjdG9yICovCiAgICAgIGxldCBxdWVzdGlvbk9yZGVyID0gZ3JvdXAuZGF0YXNldC5xdWVzdGlvbk9yZGVyLnNwbGl0KCIsIikubWFwKHN0ciA9PiBwYXJzZUludChzdHIpKTsKCiAgICAgIC8qIGN1cnJlbnQgcXVlc3Rpb24vcG9zaXRpb24gKi8KICAgICAgbGV0IGN1cnJlbnRQb3NpdGlvbiA9IHBhcnNlSW50KGdyb3VwLmRhdGFzZXQuY3VycmVudFBvc2l0aW9uKTsKICAKICAgICAgLyogSGlkZSB0aGUgY3VycmVudCBxdWVzdGlvbiAqLwogICAgICBxdWVzdGlvbnMuZm9yRWFjaChxdWVzdGlvbiA9PiB7IHF1ZXN0aW9uLmNsYXNzTGlzdC5yZW1vdmUoImFjdGl2ZSIpOyB9KTsKCiAgICAgIC8qIE1vdmUgdG8gdGhlIG5leHQgcXVlc3Rpb24gaW5kZXggKi8KICAgICAgY3VycmVudFBvc2l0aW9uID0gKGN1cnJlbnRQb3NpdGlvbiArIHN0ZXApICUgcXVlc3Rpb25PcmRlci5sZW5ndGg7CiAgICAgIGlmIChjdXJyZW50UG9zaXRpb24gPCAwKSBjdXJyZW50UG9zaXRpb24gPSBjdXJyZW50UG9zaXRpb24gKyBxdWVzdGlvbk9yZGVyLmxlbmd0aAoKICAgICAgLyogRGlzcGxheSB0aGUgbmV3IHF1ZXN0aW9uICovCiAgICAgIC8vIGRldmVsIC8vIGNvbnNvbGUubG9nKCJzZXQgcXVlc3Rpb24gIiArIHF1ZXN0aW9uT3JkZXJbY3VycmVudFBvc2l0aW9uXSArCiAgICAgIC8vIGRldmVsIC8vICAgICAgICAgICAgICIgKCIgKyBjdXJyZW50UG9zaXRpb24gKyAiKSBhcyBhY3RpdmUiKTsKICAgICAgcXVlc3Rpb25zW3F1ZXN0aW9uT3JkZXJbY3VycmVudFBvc2l0aW9uXV0uY2xhc3NMaXN0LmFkZCgiYWN0aXZlIik7CiAgCiAgICAgIC8vIFVwZGF0ZSB0aGUgY3VycmVudFBvc2l0aW9uIGRhdGEgYXR0cmlidXRlIG9uIHRoZSBncm91cCBkaXYKICAgICAgZ3JvdXAuZGF0YXNldC5jdXJyZW50UG9zaXRpb24gPSBjdXJyZW50UG9zaXRpb247CiAgICB9OwogIH0KCiAgCiAgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgiLndlYmV4LWdyb3VwIikuZm9yRWFjaChncm91cCA9PiB7CiAgICBjb25zdCBxdWVzdGlvbnMgPSBBcnJheS5mcm9tKGdyb3VwLnF1ZXJ5U2VsZWN0b3JBbGwoIi53ZWJleC1xdWVzdGlvbiIpKTsKICAgIGNvbnN0IHF1ZXN0aW9uT3JkZXIgPSBzaHVmZmxlX2FycmF5KHF1ZXN0aW9ucy5sZW5ndGgpOwoKICAgIC8qIHRha2Ugc3RhcnQgcG9zaXRpb24gKGlmIHNldCkgb3Igc3RhcnQgYXQgMCAqLwogICAgY29uc3QgY3VycmVudFBvc2l0aW9uID0gcGFyc2VJbnQoZ3JvdXAuZ2V0QXR0cmlidXRlKCJkYXRhLXN0YXJ0LXBvc2l0aW9uIikpIHx8IDA7CgogICAgLyogc2hvdyB0aGUgZGVmYXVsdCBxdWVzdGlvbiBmb3IgZWFjaCBncm91cCAqLwogICAgcXVlc3Rpb25zW3F1ZXN0aW9uT3JkZXJbY3VycmVudFBvc2l0aW9uXV0uY2xhc3NMaXN0LmFkZCgiYWN0aXZlIik7CiAgICAvLyBkZXZlbCAvLyBjb25zb2xlLmxvZygic2V0IHF1ZXN0aW9uICIgKyBxdWVzdGlvbk9yZGVyW2N1cnJlbnRQb3NpdGlvbl0gKwogICAgLy8gZGV2ZWwgLy8gICAgICAgICAgICAgIiAoIiArIGN1cnJlbnRQb3NpdGlvbiArICIpIGFzIGFjdGl2ZTsgIiArIHF1ZXN0aW9uT3JkZXIpOwogIAogICAgLyogc3RvcmUgcmFuZG9tIG9yZGVyIG9mIHF1ZXN0aW9ucyBhcyB3ZWxsIGFzIGN1cnJlbnQgcG9zaXRpb24gKi8KICAgIGdyb3VwLmRhdGFzZXQucXVlc3Rpb25PcmRlciAgID0gcXVlc3Rpb25PcmRlcjsKICAgIGdyb3VwLmRhdGFzZXQuY3VycmVudFBvc2l0aW9uID0gY3VycmVudFBvc2l0aW9uOwoKICAgIC8qIGZpbmQgYWxsIHdlYmV4LXF1ZXN0aW9ucywgc2VhcmNoIGZvciAud2ViZXgtYnV0dG9uLWxpc3QgYW5kCiAgICAgKiBwb3B1bGF0ZSB0aGUgbGlzdCB3aXRoIG5lY2Vzc2FyeSA8bGk+PGJ1dHRvbj4uLi48L2J1dHRvbj48L2xpPiBlbGVtZW50cyAqLwogICAgcXVlc3Rpb25zLmZvckVhY2gocXVlc3Rpb24gPT4gewogICAgICAgIGxldCBidXR0b25fdWwgPSBxdWVzdGlvbi5xdWVyeVNlbGVjdG9yKCJ1bC53ZWJleC1idXR0b24tbGlzdCIpOwoKICAgICAgICBsZXQgbGlfbmV4dCA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoImxpIik7CiAgICAgICAgbGV0IG5leHRCdXR0b24gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCJidXR0b24iKTsKICAgICAgICBuZXh0QnV0dG9uLnNldEF0dHJpYnV0ZSgiY2xhc3MiLCAid2ViZXgtYnV0dG9uIHdlYmV4LWJ1dHRvbi1uZXh0Iik7CiAgICAgICAgaWYgKHdlYmV4X2J1dHRvbnMucXVlc3Rpb25fbmV4dF9hbHQubGVuZ3RoID4gMCkgbmV4dEJ1dHRvbi5zZXRBdHRyaWJ1dGUoInRpdGxlIiwgd2ViZXhfYnV0dG9ucy5xdWVzdGlvbl9uZXh0X2FsdCk7CiAgICAgICAgbmV4dEJ1dHRvbi5pbm5lckhUTUwgPSB3ZWJleF9idXR0b25zLnF1ZXN0aW9uX25leHQ7IC8vICJOZXh0IHF1ZXN0aW9uIjsKICAgICAgICBuZXh0QnV0dG9uLmFkZEV2ZW50TGlzdGVuZXIoImNsaWNrIiwgaGFuZGxlUXVlc3Rpb25DbGljayhncm91cCwgcXVlc3Rpb25zLCAxKSk7CiAgICAgICAgbGlfbmV4dC5hcHBlbmRDaGlsZChuZXh0QnV0dG9uKTsKCiAgICAgICAgbGV0IGxpX3ByZXZpb3VzID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgibGkiKTsKICAgICAgICBsZXQgcHJldmlvdXNCdXR0b24gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCJidXR0b24iKTsKICAgICAgICBwcmV2aW91c0J1dHRvbi5zZXRBdHRyaWJ1dGUoImNsYXNzIiwgIndlYmV4LWJ1dHRvbiB3ZWJleC1idXR0b24tcHJldmlvdXMiKTsKICAgICAgICBpZiAod2ViZXhfYnV0dG9ucy5xdWVzdGlvbl9wcmV2aW91c19hbHQubGVuZ3RoID4gMCkgcHJldmlvdXNCdXR0b24uc2V0QXR0cmlidXRlKCJ0aXRsZSIsIHdlYmV4X2J1dHRvbnMucXVlc3Rpb25fcHJldmlvdXNfYWx0KTsKICAgICAgICBwcmV2aW91c0J1dHRvbi5pbm5lckhUTUwgPSB3ZWJleF9idXR0b25zLnF1ZXN0aW9uX3ByZXZpb3VzOyAvLyAiUHJldmlvdXMgcXVlc3Rpb24iOwogICAgICAgIHByZXZpb3VzQnV0dG9uLmFkZEV2ZW50TGlzdGVuZXIoImNsaWNrIiwgaGFuZGxlUXVlc3Rpb25DbGljayhncm91cCwgcXVlc3Rpb25zLCAtMSkpOwogICAgICAgIGxpX3ByZXZpb3VzLmFwcGVuZENoaWxkKHByZXZpb3VzQnV0dG9uKTsKCiAgICAgICAgY29uc29sZS5sb2coYnV0dG9uX3VsKTsKICAgICAgICBpZiAod2ViZXhfYnV0dG9ucy5xdWVzdGlvbl9wcmV2aW91cy5sZW5ndGggPiAwKSBidXR0b25fdWwuYXBwZW5kQ2hpbGQobGlfcHJldmlvdXMpOwogICAgICAgIGlmICh3ZWJleF9idXR0b25zLnF1ZXN0aW9uX25leHQubGVuZ3RoID4gMCkgYnV0dG9uX3VsLmFwcGVuZENoaWxkKGxpX25leHQpOwogICAgfSk7CiAgfSk7CgoKICB1cGRhdGVfdG90YWxfY29ycmVjdCgpOwp9Cgo8L3NjcmlwdD4K" download="webex.js">Download webex.js</a><!--/html_preserve-->.

The files can then be placed in the same folder as the `rmarkdown` or `quarto` project. They can also be adapted relatively easily by changing the definitions of colors, icons, text, etc. in the first few lines of each file.

To include the CSS and Javascript in an `rmarkown` project, the YAML header should include:


<pre><code class="prettyprint ">output:
  html_document:
    css: webex.css
    includes:
      after_body: webex.js</code></pre>

Similarly, in a `quarto` project the YAML header or the `_quarto.yml` file should include:


<pre><code class="prettyprint ">format:
  html:
    css: webex.css
    include-after-body: webex.js</code></pre>


## Standalone interaction forms

While it is not the primary focus of the `exams2forms` package, it is also possible to directly include interaction forms in documents like in the `webexercises` package, i.e., without setting up full R/exams exercises. A few simple examples are inlcuded below for numeric, text, single-choice, and multiple-choice interactions (both using drop-down interactions here), respectively.

What is the answer to the ultimate question of life, the universe, and everything? <input class='webex-solveme nospaces' data-tol='0' size='10' data-answer='["42"]'/>

Which superhero is the secret identity of Bruce Wayne? <input class='webex-solveme ignorecase nospaces' size='20' data-answer='["Batman"]'/>

Which of the following villains is **not** an adversary of Batman? <select class='webex-select'><option value='blank'></option><option value=''>Bane</option><option value=''>Riddler</option><option value='answer'>Thanos</option><option value=''>Poison Ivy</option></select>

Which of the following characters are romantic interests of Spider-Man?

* <select class='webex-select'><option value='blank'></option><option value='answer'>TRUE</option><option value=''>FALSE</option></select> Mary Jane Watson
* <select class='webex-select'><option value='blank'></option><option value=''>TRUE</option><option value='answer'>FALSE</option></select> Pepper Potts
* <select class='webex-select'><option value='blank'></option><option value=''>TRUE</option><option value='answer'>FALSE</option></select> Selina Kyle
* <select class='webex-select'><option value='blank'></option><option value='answer'>TRUE</option><option value=''>FALSE</option></select> Gwen Stacy

The corresponding code snippets included in the inline code chunks are:

- `forms_num(42, width = 10)`
- `forms_string("Batman", width = 20, usecase = FALSE)`
- `forms_schoice(c("Bane", "Riddler", "Thanos", "Poison Ivy"), c(FALSE, FALSE, TRUE, FALSE), display = "dropdown")`
- `forms_mchoice(c("Mary Jane Watson", "Pepper Potts", "Selina Kyle", "Gwen Stacy"), c(TRUE, FALSE, FALSE, TRUE), display = "dropdown")`
