---
layout: page
#
# Content
#
title: "regression: Simple Linear Regression (by Hand)"
teaser: "Exercise template for computing the prediction from a simple linear prediction by hand, based on randomly-generated marginal means/variances and correlation."
categories:
  - templates
tags:
  - num
  - numeric
  - prediction
  - regression
  - statistics
author: zeileis

mathjax: true
webex: true

#
# Style
#
image:
  # preview in list of posts
  thumb: regression.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">regression</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/num/"><code class="highlighter-rouge">num</code></a></div>
</div>


<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Preview:</b></div>
  <div class='medium-8 columns'><div class="webex-group">
<div class="webex-question">
<div class="webex-check webex-box">
<p>For 56 firms the number of employees <span class="math inline">\(X\)</span> and the amount of expenses for continuing education <span class="math inline">\(Y\)</span> (in EUR) were recorded. The statistical summary of the data set is given by:</p>
<table>
<thead>
<tr class="header">
<th align="center"></th>
<th align="center">Variable <span class="math inline">\(X\)</span></th>
<th align="center">Variable <span class="math inline">\(Y\)</span></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Mean</td>
<td align="center">46</td>
<td align="center">220</td>
</tr>
<tr class="even">
<td align="center">Variance</td>
<td align="center">140</td>
<td align="center">1827</td>
</tr>
</tbody>
</table>
<p>The correlation between <span class="math inline">\(X\)</span> and <span class="math inline">\(Y\)</span> is equal to 0.61.</p>
<p>Estimate the expected amount of money spent for continuing education by a firm with 44 employees using least squares regression.</p>
<p><input class='webex-solveme nospaces' id='webex-d4af9dcdd1ce9c5fae4969006a427a25' data-tol='0.01' size='20' data-answer='PxZTVwxKVl1XEz4='/></p>
</div>
<div class="webex-solution">
<p>First, the regression line <span class="math inline">\(y_i = \beta_0 + \beta_1 x_i +
\varepsilon_i\)</span> is determined. The regression coefficients are given by: <span class="math display">\[\begin{eqnarray*}
&amp;&amp; \hat \beta_1 = r \cdot \frac{s_y}{s_x} = 
0.61 \cdot \sqrt{\frac{1827}{140}} = 2.20361, \\
&amp;&amp; \hat \beta_0 = \bar y - \hat \beta_1 \cdot \bar x = 
220 - 2.20361 \cdot 46 = 118.63386.
\end{eqnarray*}\]</span></p>
<p>The estimated amount of money spent by a firm with 44 employees is then given by: <span class="math display">\[\begin{eqnarray*}
\hat y = 118.63386 + 2.20361 \cdot 44 = 215.593.
\end{eqnarray*}\]</span></p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>For 46 firms the number of employees <span class="math inline">\(X\)</span> and the amount of expenses for continuing education <span class="math inline">\(Y\)</span> (in EUR) were recorded. The statistical summary of the data set is given by:</p>
<table>
<thead>
<tr class="header">
<th align="center"></th>
<th align="center">Variable <span class="math inline">\(X\)</span></th>
<th align="center">Variable <span class="math inline">\(Y\)</span></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Mean</td>
<td align="center">44</td>
<td align="center">236</td>
</tr>
<tr class="even">
<td align="center">Variance</td>
<td align="center">78</td>
<td align="center">1644</td>
</tr>
</tbody>
</table>
<p>The correlation between <span class="math inline">\(X\)</span> and <span class="math inline">\(Y\)</span> is equal to 0.76.</p>
<p>Estimate the expected amount of money spent for continuing education by a firm with 40 employees using least squares regression.</p>
<p><input class='webex-solveme nospaces' id='webex-edee61a94e5a0120d28a149e4357d777' data-tol='0.01' size='20' data-answer='PkZXVwQfUQ0HR2g='/></p>
</div>
<div class="webex-solution">
<p>First, the regression line <span class="math inline">\(y_i = \beta_0 + \beta_1 x_i +
\varepsilon_i\)</span> is determined. The regression coefficients are given by: <span class="math display">\[\begin{eqnarray*}
&amp;&amp; \hat \beta_1 = r \cdot \frac{s_y}{s_x} = 
0.76 \cdot \sqrt{\frac{1644}{78}} = 3.48913, \\
&amp;&amp; \hat \beta_0 = \bar y - \hat \beta_1 \cdot \bar x = 
236 - 3.48913 \cdot 44 = 82.47826.
\end{eqnarray*}\]</span></p>
<p>The estimated amount of money spent by a firm with 40 employees is then given by: <span class="math display">\[\begin{eqnarray*}
\hat y = 82.47826 + 3.48913 \cdot 40 = 222.043.
\end{eqnarray*}\]</span></p>
</div>
</div>
<div class="webex-question">
<div class="webex-check webex-box">
<p>For 65 firms the number of employees <span class="math inline">\(X\)</span> and the amount of expenses for continuing education <span class="math inline">\(Y\)</span> (in EUR) were recorded. The statistical summary of the data set is given by:</p>
<table>
<thead>
<tr class="header">
<th align="center"></th>
<th align="center">Variable <span class="math inline">\(X\)</span></th>
<th align="center">Variable <span class="math inline">\(Y\)</span></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Mean</td>
<td align="center">44</td>
<td align="center">259</td>
</tr>
<tr class="even">
<td align="center">Variance</td>
<td align="center">93</td>
<td align="center">2529</td>
</tr>
</tbody>
</table>
<p>The correlation between <span class="math inline">\(X\)</span> and <span class="math inline">\(Y\)</span> is equal to 0.83.</p>
<p>Estimate the expected amount of money spent for continuing education by a firm with 38 employees using least squares regression.</p>
<p><input class='webex-solveme nospaces' id='webex-e125a64d3002cf61a90b91df73b2a544' data-tol='0.01' size='20' data-answer='PhMABlIYBFcCEm0='/></p>
</div>
<div class="webex-solution">
<p>First, the regression line <span class="math inline">\(y_i = \beta_0 + \beta_1 x_i +
\varepsilon_i\)</span> is determined. The regression coefficients are given by: <span class="math display">\[\begin{eqnarray*}
&amp;&amp; \hat \beta_1 = r \cdot \frac{s_y}{s_x} = 
0.83 \cdot \sqrt{\frac{2529}{93}} = 4.32824, \\
&amp;&amp; \hat \beta_0 = \bar y - \hat \beta_1 \cdot \bar x = 
259 - 4.32824 \cdot 44 = 68.55757.
\end{eqnarray*}\]</span></p>
<p>The estimated amount of money spent by a firm with 38 employees is then given by: <span class="math display">\[\begin{eqnarray*}
\hat y = 68.55757 + 4.32824 \cdot 38 = 233.031.
\end{eqnarray*}\]</span></p>
</div>
</div>
</div></div>
</div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Computing coefficients and a point prediction from a simple linear prediction (by hand). Internally, a full bivariate data set is simulated but only the marginal means and variances and the correlation coefficient are presented in the exercise.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Random numbers</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Mathematical notation:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Verbatim R input/output:</b></div>
  <div class='medium-8 columns'>No</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Images:</b></div>
  <div class='medium-8 columns'>No</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Other supplements:</b></div>
  <div class='medium-8 columns'>No</div>
</div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Template:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression.Rmd">regression.Rmd</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression.Rnw">regression.Rnw</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression.md" >regression.md</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression.tex">regression.tex</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rmd-pdf.png" alt="regression-Rmd-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rnw-pdf.png" alt="regression-Rnw-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rmd-html.png" alt="regression-Rmd-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-regression//regression-Rnw-html.png" alt="regression-Rnw-html"/></a></div>
</div>

_(Note that the HTML output contains mathematical equations in MathML, rendered by MathJax using 'mathjax = TRUE'. Instead it is also possible to use 'converter = "pandoc-mathjax"' so that LaTeX equations are rendered by MathJax directly.)_

**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(403)
exams2html(&quot;regression.Rmd&quot;, mathjax = TRUE)
set.seed(403)
exams2pdf(&quot;regression.Rmd&quot;)

set.seed(403)
exams2html(&quot;regression.Rnw&quot;, mathjax = TRUE)
set.seed(403)
exams2pdf(&quot;regression.Rnw&quot;)</code></pre>
