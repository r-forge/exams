---
layout: page
#
# Content
#
title: "countrycodes: String Question about ISO Country Codes"
teaser: "Exercise template for a knowledge quiz question (about three-letter ISO country codes) where the correct answer has to match exactly a given string."
categories:
  - templates
tags:
  - string
  - knowledge
  - quiz
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: countrycodes.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">countrycodes</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/string/"><code class="highlighter-rouge">string</code></a></div>
</div>


<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>Knowledge quiz question about three-letter country codes (ISO 3166-1 alpha-3). A country is drawn randomly from a list of 167 countries and the correct string answer is the corresponding three-letter country code.</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Solution feedback:</b></div>
  <div class='medium-8 columns'>Yes</div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Randomization:</b></div>
  <div class='medium-8 columns'>Shuffling (1 out of 167 question/answer pairs)</div>
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
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes.Rnw">countrycodes.Rnw</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes.Rmd">countrycodes.Rmd</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes.tex">countrycodes.tex</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes.md" >countrycodes.md</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rnw-pdf.png" alt="countrycodes-Rnw-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rmd-pdf.png" alt="countrycodes-Rmd-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rnw.html"><img src="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rnw-html.png" alt="countrycodes-Rnw-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rmd.html"><img src="{{ site.url }}/assets/posts/2017-08-14-countrycodes//countrycodes-Rmd-html.png" alt="countrycodes-Rmd-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(1090)
exams2html(&quot;countrycodes.Rnw&quot;)
set.seed(1090)
exams2pdf(&quot;countrycodes.Rnw&quot;)

set.seed(1090)
exams2html(&quot;countrycodes.Rmd&quot;)
set.seed(1090)
exams2pdf(&quot;countrycodes.Rmd&quot;)</code></pre>
