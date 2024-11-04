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

The new package [exams2forms](https://CRAN.R-project.org/package=exams2forms), co-authored with [Reto Stauffer](https://retostauffer.org/), provides several building blocks for embedding exercises written with the R package [exams]({{ site.url }}) (also known as R/exams) in interactive documents or quizzes written with [rmarkdown](https://rmarkdown.rstudio.com/) or [quarto](https://quarto.org/).

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

To set up a similar standalone file with these two exercises, the `exams2webquiz()` interface from the `exams2forms` package can be used:


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
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(508\)</span></td>
</tr>
<tr class="even">
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(735\)</span></td>
</tr>
<tr class="odd">
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(203\)</span></td>
</tr>
</tbody>
</table>
<p>Compute:</p>
<table>
<tbody>
<tr class="odd">
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
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
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="right"><span class="math inline">\(x_2 =\)</span></td>
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="right"><span class="math inline">\(x_3 =\)</span></td>
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
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
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
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
<p><strong>Application:</strong> Using the data provided in <a href="https://www.R-exams.org/assets/posts/2024-11-04-exams2forms/linreg.csv">linreg.csv</a> estimate a linear regression of <code>y</code> on <code>x</code>. What are the estimated parameters?</p>
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

- [quiz.Rmd]({{ site.url }}/assets/posts/2024-11-04-exams2forms//quiz.Rmd).
- [questions.Rmd]({{ site.url }}/assets/posts/2024-11-04-exams2forms//questions.Rmd).

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

- [webex.css]({{ site.url }}/assets/posts/2024-11-04-exams2forms//webex.css).
- [webex.js]({{ site.url }}/assets/posts/2024-11-04-exams2forms//webex.js).

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
