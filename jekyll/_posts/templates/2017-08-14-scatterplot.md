---
layout: page
#
# Content
#
title: "scatterplot: Interpretation of a Scatterplot"
teaser: "Exercise template for assessing the interpretation of a randomly-generated scatterplot regarding the joint and marginal distributions."
categories:
  - templates
tags:
  - mchoice
  - multiple-choice
  - scatterplot
  - regression
  - visualization
  - statistics
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: scatterplot.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">scatterplot</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/mchoice/"><code class="highlighter-rouge">mchoice</code></a></div>
</div>


<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Scatterplot in an (x, y) regression setup needs to be interpreted regarding location/spread of the marginal distributions, the correlation in the joint distribution, and the corresponding regression slope. Data are drawn randomly from a suitable data-generating process so that each multiple-choice item is either about correct or clearly wrong.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Random numbers, text blocks, and graphics</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Mathematical notation:</b></div>
  <div class='medium-8 columns'>No</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Verbatim R input/output:</b></div>
  <div class='medium-8 columns'>No</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Images:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Other supplements:</b></div>
  <div class='medium-8 columns'>No</div>
</div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Template:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot.Rmd">scatterplot.Rmd</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot.Rnw">scatterplot.Rnw</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot.md" >scatterplot.md</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot.tex">scatterplot.tex</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rmd-pdf.png" alt="scatterplot-Rmd-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rnw-pdf.png" alt="scatterplot-Rnw-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rmd-html.png" alt="scatterplot-Rmd-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-scatterplot//scatterplot-Rnw-html.png" alt="scatterplot-Rnw-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(403)
exams2html(&quot;scatterplot.Rmd&quot;)
set.seed(403)
exams2pdf(&quot;scatterplot.Rmd&quot;)

set.seed(403)
exams2html(&quot;scatterplot.Rnw&quot;)
set.seed(403)
exams2pdf(&quot;scatterplot.Rnw&quot;)</code></pre>
