---
layout: page
#
# Content
#
title: "swisscapital: Knowledge Quiz Question about the Swiss Capital"
teaser: "Exercise template for a single-choice knowledge quiz question with basic shuffling of correct and false alternatives."
categories:
  - templates
tags:
  - schoice
  - single-choice
  - knowledge
  - quiz
  - switzerland
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: swisscapital.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">swisscapital</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/schoice/"><code class="highlighter-rouge">schoice</code></a></div>
</div>
<div class='row t1 b1'>   <div class='medium-4 columns'><b>Related:</b></div>   <div class='medium-8 columns'><a href="{{ site.url }}/templates/switzerland/"><code class="highlighter-rouge">switzerland</code></a></div> </div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Knowledge quiz question (about the Swiss capital) with 1 correct and 6 false alternative. 4 out of the 6 false alternatives are sampled randomly and shuffled.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Shuffling (4 out of 6 false alternatives)</div>
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
  <div class='medium-8 columns'>No</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Other supplements:</b></div>
  <div class='medium-8 columns'>No</div>
</div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Template:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital.Rnw">swisscapital.Rnw</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital.Rmd">swisscapital.Rmd</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital.tex">swisscapital.tex</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital.md" >swisscapital.md</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rnw-pdf.png" alt="swisscapital-Rnw-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rmd-pdf.png" alt="swisscapital-Rmd-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rnw-html.png" alt="swisscapital-Rnw-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-swisscapital//swisscapital-Rmd-html.png" alt="swisscapital-Rmd-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(1090)
exams2html(&quot;swisscapital.Rnw&quot;)
set.seed(1090)
exams2pdf(&quot;swisscapital.Rnw&quot;)

set.seed(1090)
exams2html(&quot;swisscapital.Rmd&quot;)
set.seed(1090)
exams2pdf(&quot;swisscapital.Rmd&quot;)</code></pre>
