---
layout: page
#
# Content
#
title: "switzerland: Knowledge Quiz Question about Switzerland"
teaser: "Exercise template for a multiple-choice knowledge quiz question with basic shuffling of the alternatives."
categories:
  - templates
tags:
  - mchoice
  - multiple-choice
  - knowledge
  - quiz
  - switzerland
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: switzerland.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">switzerland</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">mchoice</code></div> <!-- FIXME: href -->
</div>
<div class='row t1 b1'>   <div class='medium-4 columns'><b>Related:</b></div>   <div class='medium-8 columns'><a href="{{ site.url }}/templates/swisscapital/"><code class="highlighter-rouge">swisscapital</code></a></div> </div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Knowledge quiz question (about Switzerland) with 2 correct and 3 false alternative which are shuffled randomly in each version of the exercise.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Shuffling</div>
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
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland.Rnw">switzerland.Rnw</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland.Rmd">switzerland.Rmd</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland.tex">switzerland.tex</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland.md" >switzerland.md</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rnw-pdf.png" alt="switzerland-Rnw-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rmd-pdf.png" alt="switzerland-Rmd-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rnw-html.png" alt="switzerland-Rnw-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-switzerland//switzerland-Rmd-html.png" alt="switzerland-Rmd-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(1090)
exams2html(&quot;switzerland.Rnw&quot;)
set.seed(1090)
exams2pdf(&quot;switzerland.Rnw&quot;)

set.seed(1090)
exams2html(&quot;switzerland.Rmd&quot;)
set.seed(1090)
exams2pdf(&quot;switzerland.Rmd&quot;)</code></pre>
