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
