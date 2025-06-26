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

The idea is that the [dynamic exercises]({{ site.url }}/intro/dynamic/) in R/exams' Rmd (R/Markdown) or Rnw (R/LaTeX) format can also be reused in HTML documents, web pages, or online books. This facilitates their use for self-paced learning and self-assessment without the need for a learning management system etc. (By default the correct answers are obfuscated in the documents so that they are not obvious when inspecting the HTML source code.) And for (summative) assessments the same dynamic exercises could then be exported to different [learning management systems]({{ site.url }}/intro/elearning/) or employed in [written exams]({{ site.url }}/intro/written/).

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
<div id="webex-775fd529fd210f4fe006804ccefe117a" class="webex-radiogroup" data-answer="bAcZVkgFHghKVG8=">
<label><input type='radio' autocomplete='off' name='775fd529fd210f4fe006804ccefe117a'/><span>Geneva</span></label><label><input type='radio' autocomplete='off' name='775fd529fd210f4fe006804ccefe117a'/><span>Lausanne</span></label><label><input type='radio' autocomplete='off' name='775fd529fd210f4fe006804ccefe117a'/><span>St. Gallen</span></label><label><input type='radio' autocomplete='off' name='775fd529fd210f4fe006804ccefe117a'/><span>Bern</span></label><label><input type='radio' autocomplete='off' name='775fd529fd210f4fe006804ccefe117a'/><span>Vaduz</span></label>
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
<div id="webex-035498182b29dd6d42a64083d1ae284a" class="webex-radiogroup" data-answer="awMZBBUIHQgeU28=">
<label><input type='radio' autocomplete='off' name='035498182b29dd6d42a64083d1ae284a'/><span>Lausanne</span></label><label><input type='radio' autocomplete='off' name='035498182b29dd6d42a64083d1ae284a'/><span>Basel</span></label><label><input type='radio' autocomplete='off' name='035498182b29dd6d42a64083d1ae284a'/><span>Geneva</span></label><label><input type='radio' autocomplete='off' name='035498182b29dd6d42a64083d1ae284a'/><span>St. Gallen</span></label><label><input type='radio' autocomplete='off' name='035498182b29dd6d42a64083d1ae284a'/><span>Bern</span></label>
</div>
</div>
<div class="webex-solution">
<p>There is no de jure capital but the de facto capital and seat of the federal authorities is Bern.</p>
<ul>
<li>False</li>
<li>False</li>
<li>False</li>
<li>False</li>
<li>True</li>
</ul>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the seat of the federal authorities in Switzerland (i.e., the de facto capital)?</p>
<div id="webex-f923ebd56cf2d41b7d47c4541a43212c" class="webex-radiogroup" data-answer="PQgeA0lSSAUaUzs=">
<label><input type='radio' autocomplete='off' name='f923ebd56cf2d41b7d47c4541a43212c'/><span>Bern</span></label><label><input type='radio' autocomplete='off' name='f923ebd56cf2d41b7d47c4541a43212c'/><span>Geneva</span></label><label><input type='radio' autocomplete='off' name='f923ebd56cf2d41b7d47c4541a43212c'/><span>St. Gallen</span></label><label><input type='radio' autocomplete='off' name='f923ebd56cf2d41b7d47c4541a43212c'/><span>Basel</span></label><label><input type='radio' autocomplete='off' name='f923ebd56cf2d41b7d47c4541a43212c'/><span>Vaduz</span></label>
</div>
</div>
<div class="webex-solution">
<p>There is no de jure capital but the de facto capital and seat of the federal authorities is Bern.</p>
<ul>
<li>True</li>
<li>False</li>
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
<p>What is the derivative of <span class="math inline">\(f(x) = x^{2} e^{3.2 x}\)</span>, evaluated at <span class="math inline">\(x = 0.59\)</span>?</p>
<p><input class='webex-solveme nospaces' id='webex-e13e2e39011b0214bd80e937bd1cf564' data-tol='0.01' size='20' data-answer='PhMCUBxUBhtt'/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{2}\)</span> and <span class="math inline">\(h(x) := e^{3.2 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 2 x^{2 - 1} \cdot e^{3.2 x} + x^{2} \cdot e^{3.2 x} \cdot 3.2 \\
      &amp;= e^{3.2 x} \cdot(2 x^1 + 3.2 x^{2}) \\
      &amp;= e^{3.2 x} \cdot x^1 \cdot (2 + 3.2 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.59\)</span>, the answer is <span class="math display">\[ e^{3.2 \cdot 0.59} \cdot 0.59^1 \cdot (2 + 3.2 \cdot 0.59) = 15.153964. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.59) = 15.15\)</span>.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the derivative of <span class="math inline">\(f(x) = x^{4} e^{3.5 x}\)</span>, evaluated at <span class="math inline">\(x = 0.65\)</span>?</p>
<p><input class='webex-solveme nospaces' id='webex-1a40d1cfe7fef8cba3bf072454cf89a9' data-tol='0.01' size='20' data-answer='akMFBkoGVUQ4'/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{4}\)</span> and <span class="math inline">\(h(x) := e^{3.5 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 4 x^{4 - 1} \cdot e^{3.5 x} + x^{4} \cdot e^{3.5 x} \cdot 3.5 \\
      &amp;= e^{3.5 x} \cdot(4 x^3 + 3.5 x^{4}) \\
      &amp;= e^{3.5 x} \cdot x^3 \cdot (4 + 3.5 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.65\)</span>, the answer is <span class="math display">\[ e^{3.5 \cdot 0.65} \cdot 0.65^3 \cdot (4 + 3.5 \cdot 0.65) = 16.763849. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.65) = 16.76\)</span>.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the derivative of <span class="math inline">\(f(x) = x^{7} e^{2.8 x}\)</span>, evaluated at <span class="math inline">\(x = 0.72\)</span>?</p>
<p><input class='webex-solveme nospaces' id='webex-ed526c052e45fc503236adfda2f5c2a3' data-tol='0.01' size='20' data-answer='PkYMHAJQEmg='/></p>
</div>
<div class="webex-solution">
<p>Using the product rule for <span class="math inline">\(f(x) = g(x) \cdot h(x)\)</span>, where <span class="math inline">\(g(x) := x^{7}\)</span> and <span class="math inline">\(h(x) := e^{2.8 x}\)</span>, we obtain <span class="math display">\[
\begin{aligned}
f&#39;(x) &amp;= [g(x) \cdot h(x)]&#39; = g&#39;(x) \cdot h(x) + g(x) \cdot h&#39;(x) \\
      &amp;= 7 x^{7 - 1} \cdot e^{2.8 x} + x^{7} \cdot e^{2.8 x} \cdot 2.8 \\
      &amp;= e^{2.8 x} \cdot(7 x^6 + 2.8 x^{7}) \\
      &amp;= e^{2.8 x} \cdot x^6 \cdot (7 + 2.8 x).
\end{aligned}
\]</span> Evaluated at <span class="math inline">\(x = 0.72\)</span>, the answer is <span class="math display">\[ e^{2.8 \cdot 0.72} \cdot 0.72^6 \cdot (7 + 2.8 \cdot 0.72) = 9.430757. \]</span> Thus, rounded to two digits we have <span class="math inline">\(f&#39;(0.72) = 9.43\)</span>.</p>
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


<pre><code class="prettyprint ">library("exams2forms")
exams2webquiz(c("swisscapital.Rmd", "deriv.Rmd"), n = 3)</code></pre>


## More elaborate examples

To showcase some more exercise types, the following examples from the R/exams package are used: [capitals]({{ site.url }}/templates/capitals/) (multiple-choice), [function]({{ site.url }}/templates/function/) (string/text), [fruit]({{ site.url }}/templates/fruit/) (numeric with table and images), [lm2]({{ site.url }}/templates/lm2/) (cloze containing string, multiple-choice, numeric, and single-choice elements as well as an embedded data file).

<div class="webex-question">
<div class="webex-check webex-box">
<p>Which of the following cities are the capital of the corresponding country?</p>
<div id="webex-276af0ed73799cc27bf1a3e7c76cb217" class="webex-checkboxgroup" data-answer="aQYaUEoASVUbA2o=">
<label><input type='checkbox' autocomplete='off' name='276af0ed73799cc27bf1a3e7c76cb217'/><span>Tokyo (Japan)</span></label><label><input type='checkbox' autocomplete='off' name='276af0ed73799cc27bf1a3e7c76cb217'/><span>Warsaw (Poland)</span></label><label><input type='checkbox' autocomplete='off' name='276af0ed73799cc27bf1a3e7c76cb217'/><span>Auckland (New Zealand)</span></label><label><input type='checkbox' autocomplete='off' name='276af0ed73799cc27bf1a3e7c76cb217'/><span>Astana (Kazakhstan)</span></label><label><input type='checkbox' autocomplete='off' name='276af0ed73799cc27bf1a3e7c76cb217'/><span>Zürich (Switzerland)</span></label>
</div>
</div>
<div class="webex-solution">
<ul>
<li>True. Tokyo is the capital of Japan.</li>
<li>True. Warsaw is the capital of Poland.</li>
<li>False. The capital of New Zealand is Wellington.</li>
<li>True. Astana is the capital of Kazakhstan.</li>
<li>False. The de facto capital of Switzerland is Bern.</li>
</ul>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>What is the name of the R function for negative binomial regression?</p>
<p><input class='webex-solveme' id='webex-4017154663a3874f9409bd270f900f66' size='20' data-answer='bxJWW1wbWlQUbg=='/></p>
</div>
<div class="webex-solution">
<p><code>glm.nb</code> is the R function for negative binomial regression. See <code>?glm.nb</code> for the corresponding manual page.</p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>Given the following information:</p>
<table>
<tbody>
<tr>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(143\)</span></td>
</tr>
<tr>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(437\)</span></td>
</tr>
<tr>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(433\)</span></td>
</tr>
</tbody>
</table>
<p>Compute:</p>
<table>
<tbody>
<tr>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(\text{?}\)</span></td>
</tr>
</tbody>
</table>
<p><input class='webex-solveme nospaces' id='webex-a7f4f6969561502620fa6cdfdd3bbac0' data-tol='0' size='20' data-answer='OhVSB1MUZA=='/></p>
</div>
<div class="webex-solution">
<p>The information provided can be interpreted as the price for three fruit baskets with different combinations of the three fruits. This corresponds to a system of linear equations where the price of the three fruits is the vector of unknowns <span class="math inline">\(x\)</span>:</p>
<table>
<tbody>
<tr>
<td align="right"><span class="math inline">\(x_1 =\)</span></td>
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="right"><span class="math inline">\(x_2 =\)</span></td>
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="right"><span class="math inline">\(x_3 =\)</span></td>
<td align="left"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
</tr>
</tbody>
</table>
<p>The system of linear equations is then: <span class="math display">\[
\begin{aligned}
\left( \begin{array}{rrr} 1 &amp; 2 &amp; 0 \\ 2 &amp; 0 &amp; 1 \\ 0 &amp; 2 &amp; 1 \end{array} \right) \cdot \left( \begin{array}{r} x_1 \\ x_2 \\ x_3 \end{array} \right) &amp; = &amp; \left( \begin{array}{r} 143 \\ 437 \\ 433 \end{array} \right)
\end{aligned}
\]</span> This can be solved using any solution algorithm, e.g., elimination: <span class="math display">\[
x_1 = 49, \, x_2 = 47, \, x_3 = 339.
\]</span> Based on the three prices for the different fruits it is straightforward to compute the total price of the fourth fruit basket via:</p>
<table>
<tbody>
<tr>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/banana.png" style="width:0.85cm" alt="banana" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/orange.png" style="width:0.85cm" alt="orange" /></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><img src="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/pineapple.png" style="width:0.85cm" alt="pineapple" /></td>
<td align="center">=</td>
<td align="right"></td>
</tr>
<tr>
<td align="center"><span class="math inline">\(x_1\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(x_2\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(x_3\)</span></td>
<td align="center">=</td>
<td align="right"></td>
</tr>
<tr>
<td align="center"><span class="math inline">\(49\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(47\)</span></td>
<td align="center"><span class="math inline">\(+\)</span></td>
<td align="center"><span class="math inline">\(339\)</span></td>
<td align="center">=</td>
<td align="right"><span class="math inline">\(435\)</span></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p><strong>Theory:</strong> Consider a linear regression of <code>y</code> on <code>x</code>. It is usually estimated with which estimation technique (three-letter abbreviation)?</p>
<p><input class='webex-solveme' id='webex-06e7a7b0b29a0cad7f5cbe781af531db' size='20' data-answer='axQqezIVPw=='/></p>
<p>This estimator yields the best linear unbiased estimator (BLUE) under the assumptions of the Gauss-Markov theorem. Which of the following properties are required for the errors of the linear regression model under these assumptions?</p>
<div id="webex-6d7d0d00ecb5475439b49b88aa384596" class="webex-checkboxgroup" data-answer="bVQbVRxUHABJUj8=">
<label><input type='checkbox' autocomplete='off' name='6d7d0d00ecb5475439b49b88aa384596'/><span>independent</span></label><label><input type='checkbox' autocomplete='off' name='6d7d0d00ecb5475439b49b88aa384596'/><span>zero expectation</span></label><label><input type='checkbox' autocomplete='off' name='6d7d0d00ecb5475439b49b88aa384596'/><span>normally distributed</span></label><label><input type='checkbox' autocomplete='off' name='6d7d0d00ecb5475439b49b88aa384596'/><span>identically distributed</span></label><label><input type='checkbox' autocomplete='off' name='6d7d0d00ecb5475439b49b88aa384596'/><span>homoscedastic</span></label>
</div>
<p><strong>Application:</strong> Using the data provided in <a href="https://www.R-exams.org/assets/posts/2024-11-07-exams2forms/linreg.csv">linreg.csv</a> estimate a linear regression of <code>y</code> on <code>x</code>. What are the estimated parameters?</p>
<p>Intercept: <input class='webex-solveme nospaces' id='webex-096e7ffadba21efa0d8db22285a5b144' data-tol='0.01' size='20' data-answer='axsGSwdVV0M5'/></p>
<p>Slope: <input class='webex-solveme nospaces' id='webex-44260a8f5bdcbe01a30bcdce26ec144c' data-tol='0.01' size='20' data-answer='bxYfBh5RC1cXPw=='/></p>
<p>In terms of significance at 5% level:</p>
<p><select class='webex-select' id='webex-6dad47bafe2af1efebc9d30e443ec44d' data-answer='bVVNVBgHPw=='><option value='blank'></option><option><code>x</code> and <code>y</code> are not significantly correlated</option><option><code>y</code> increases significantly with <code>x</code></option><option><code>y</code> decreases significantly with <code>x</code></option></select></p>
</div>
<div class="webex-solution">
<p><strong>Theory:</strong> Linear regression models are typically estimated by ordinary least squares (OLS). The Gauss-Markov theorem establishes certain optimality properties: Namely, if the errors have expectation zero, constant variance (homoscedastic), no autocorrelation and the regressors are exogenous and not linearly dependent, the OLS estimator is the best linear unbiased estimator (BLUE).</p>
<p><strong>Application:</strong> The estimated coefficients along with their significances are reported in the summary of the fitted regression model, showing that <code>x</code> and <code>y</code> are not significantly correlated (at 5% level).</p>
<pre><code>
Call:
lm(formula = y ~ x, data = d)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.59846 -0.17142 -0.01458  0.13740  0.68566 

Coefficients:
            Estimate Std. Error t value Pr(&gt;|t|)
(Intercept)  0.03055    0.02507   1.219    0.226
x           -0.03080    0.04702  -0.655    0.514

Residual standard error: 0.2504 on 98 degrees of freedom
Multiple R-squared:  0.00436,   Adjusted R-squared:  -0.005799 
F-statistic: 0.4292 on 1 and 98 DF,  p-value: 0.5139
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


<pre><code class="prettyprint ">exams2webquiz(c("capitals.Rmd", "function.Rmd", "fruit.Rmd", "lm2.Rmd"))</code></pre>


## Building blocks

To accomplish the functionality demonstrated above, the package provides the following contents:

- `exams2forms()`: Main workhorse function from the package. Like other `exams2xyz()` interfaces this takes a vector or list of exercise files and returns Markdown text, including HTML snippets, than can be included in `rmarkdown` or `quarto` documents. This includes questions, suitable interactions for the different types of answers (with correct solutions also embedded in the HTML), and optionally full solution explanations.
- `webex.css`, `webex.js`: CSS (Cascading Style Sheets) and Javascript files shipped within the package and providing the code necessary for the exercise and quiz display and processing the different types of interactions.
- `webquiz()`: Small wrapper function that creates a `knitr::html_document()` but includes the CSS and Javascript files above.
- `exams2webquiz()`: Convenience interface that combines all of the above elements. It sets up a `webquiz()` document in which `exams2forms()` is used to embed the specified exercises, calls `rmarkdown::render()` to process it, and by default displays it in the browser. This is most useful for quickly trying out how R/exams exercises can work in HTML documents.
- `forms_num()`, `forms_string()`, `forms_schoice()`, `forms_mchoice()`: Helper functions for just embedding the user interactions for the different types of exercises. Typically not called directly by the user.


## Demo files

While `exams2webquiz()` is convenient for quickly setting up an HTML document containing certain exercises, further customizations are typicallly needed for more elaborate documents. To demonstrate how this works the `exams2forms` package provides two demo `rmarkdown` files which can also be downloaded here:

- [quiz.Rmd]({{ site.url }}/assets/posts/2024-11-07-exams2forms//quiz.Rmd).
- [questions.Rmd]({{ site.url }}/assets/posts/2024-11-07-exams2forms//questions.Rmd).

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

- [webex.css]({{ site.url }}/assets/posts/2024-11-07-exams2forms//webex.css).
- [webex.js]({{ site.url }}/assets/posts/2024-11-07-exams2forms//webex.js).

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

What is the answer to the ultimate question of life, the universe, and everything? <input class='webex-solveme nospaces' id='webex-7a351c8742063dd330872151bfd2cd55' data-tol='0' size='10' data-answer='bEMHBxM+'/>

Which superhero is the secret identity of Bruce Wayne? <input class='webex-solveme ignorecase nospaces' id='webex-bd9ee34babe4af3e6dbae240b7992efd' size='20' data-answer='OUZbBBFeVQxDPw=='/>

Which of the following villains is **not** an adversary of Batman? <select class='webex-select' id='webex-973ae8a6f3ed0d4dde83cfaf1479fce9' data-answer='YgcfUUkJTQY7'><option value='blank'></option><option>Bane</option><option>Riddler</option><option>Thanos</option><option>Poison Ivy</option></select>

Which of the following characters are romantic interests of Spider-Man?

* <select class='webex-select' id='webex-2e3afe7a47832cc8ddba6e1b92fb2152' data-answer='aVQfUTs='><option value='blank'></option><option>TRUE</option><option>FALSE</option></select> Mary Jane Watson
* <select class='webex-select' id='webex-63b332c566d6e8d260777b380e99bdb6' data-answer='bQNOAm4='><option value='blank'></option><option>TRUE</option><option>FALSE</option></select> Pepper Potts
* <select class='webex-select' id='webex-6bc59bccb58caf39dc0706fb405297ab' data-answer='bVJPBGQ='><option value='blank'></option><option>TRUE</option><option>FALSE</option></select> Selina Kyle
* <select class='webex-select' id='webex-193e38302bc71f239ce9414d9d1c80f9' data-answer='aggfVW4='><option value='blank'></option><option>TRUE</option><option>FALSE</option></select> Gwen Stacy

The corresponding code snippets included in the inline code chunks are:

- `forms_num(42, width = 10)`
- `forms_string("Batman", width = 20, usecase = FALSE)`
- `forms_schoice(c("Bane", "Riddler", "Thanos", "Poison Ivy"), c(FALSE, FALSE, TRUE, FALSE), display = "dropdown")`
- `forms_mchoice(c("Mary Jane Watson", "Pepper Potts", "Selina Kyle", "Gwen Stacy"), c(TRUE, FALSE, FALSE, TRUE), display = "dropdown")`
