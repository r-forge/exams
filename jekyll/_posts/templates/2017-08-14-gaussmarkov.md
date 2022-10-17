---
layout: page
#
# Content
#
title: "gaussmarkov: Knowledge Quiz Question about Gauss-Markov Assumptions"
teaser: "Exercise template for a multiple-choice knowledge quiz question about the assumptions in the Gauss-Markov theorem."
categories:
  - templates
tags:
  - mchoice
  - multiple-choice
  - knowledge
  - quiz
  - Gauss-Markov
  - statistics
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: gaussmarkov.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">gaussmarkov</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/mchoice/"><code class="highlighter-rouge">mchoice</code></a></div>
</div>


<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Knowledge quiz question (about the assumptions in the Gauss-Markov theorem) with 2 correct and 4 false alternatives. The alternatives are drawn randomly, preserving at least one of the correct and at least one of the false alternatives.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Shuffling (5 out of 6 alternatives)</div>
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
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov.Rmd">gaussmarkov.Rmd</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov.Rnw">gaussmarkov.Rnw</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov.md" >gaussmarkov.md</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov.tex">gaussmarkov.tex</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rmd-pdf.png" alt="gaussmarkov-Rmd-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rnw-pdf.png" alt="gaussmarkov-Rnw-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rmd-html.png" alt="gaussmarkov-Rmd-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-gaussmarkov//gaussmarkov-Rnw-html.png" alt="gaussmarkov-Rnw-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(403)
exams2html(&quot;gaussmarkov.Rmd&quot;)
set.seed(403)
exams2pdf(&quot;gaussmarkov.Rmd&quot;)

set.seed(403)
exams2html(&quot;gaussmarkov.Rnw&quot;)
set.seed(403)
exams2pdf(&quot;gaussmarkov.Rnw&quot;)</code></pre>
