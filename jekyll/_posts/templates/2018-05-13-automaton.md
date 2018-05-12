---
layout: page
#
# Content
#
title: "automaton: Interpretation of Automaton Diagrams (Using TikZ)"
teaser: "Exercise template for assessing the interpretation of an automaton diagram (drawn with TikZ) based on randomly generated input sequences."
categories:
  - templates
tags:
  - mchoice
  - multiple-choice
  - visualization
  - computer-science
author: zeileis

#
# Style
#
image:
  # preview in list of posts
  thumb: automaton.small.png
---

<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Name:</b></div>
  <div class='medium-8 columns'><code class="highlighter-rouge">automaton</code></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Type:</b></div>
  <div class='medium-8 columns'><a href="{{ site.url }}/tag/mchoice/"><code class="highlighter-rouge">mchoice</code></a></div>
</div>
<div class='row t1 b1'>   <div class='medium-4 columns'><b>Related:</b></div>   <div class='medium-8 columns'><a href="{{ site.url }}/templates/logic/"><code class="highlighter-rouge">logic</code></a></div> </div>

<div class='row t20 b1'>
  <div class='medium-4 columns'><b>Description:</b></div>
  <div class='medium-8 columns'>An automaton diagram with four states A-D is drawn with TikZ and is to be interpreted, where A is always the initial state and one state is randomly picked as the accepting state. Five binary 0/1 input sequences acceptance have to be assessed with approximately a quarter of all sequences being accepted. Depending on the exams2xyz() interface the TikZ graphic can be rendered in PNG, SVG, or directly by LaTeX.</div>
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
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton.Rnw">automaton.Rnw</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton.Rmd">automaton.Rmd</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>Raw:</b> (1 random version)</div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton.tex">automaton.tex</a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton.md" >automaton.md</a></div>
</div>
<div class='row t1 b1'>
  <div class='medium-4 columns'><b>PDF:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rnw.pdf"><img src="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rnw-pdf.png" alt="automaton-Rnw-pdf"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rmd.pdf"><img src="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rmd-pdf.png" alt="automaton-Rmd-pdf"/></a></div>
</div>
<div class='row t1 b20'>
  <div class='medium-4 columns'><b>HTML:</b></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rnw.html"><img src="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rnw-html.png" alt="automaton-Rnw-html"/></a></div>
  <div class='medium-4 columns'><a href="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rmd.html"><img src="{{ site.url }}/assets/posts/2018-05-13-automaton//automaton-Rmd-html.png" alt="automaton-Rmd-html"/></a></div>
</div>



**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(1090)
exams2html(&quot;automaton.Rnw&quot;)
set.seed(1090)
exams2pdf(&quot;automaton.Rnw&quot;)

set.seed(1090)
exams2html(&quot;automaton.Rmd&quot;)
set.seed(1090)
exams2pdf(&quot;automaton.Rmd&quot;)</code></pre>
