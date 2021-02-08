---
layout: page
#
# Content
#
title: "Introductory R/exams Course by Andrew Zammit-Mangion"
teaser: "To help new users to adopt R/exams for generating remote assessments this new free online course covers steps from installation to automatic exam generation in Moodle and PDF format."
categories:
  - general
tags:
  - R
  - exams
  - exams2moodle
  - exams2pdf
  - e-learning
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: andrewzm_course.title.png
  # preview in list of posts
  thumb: andrewzm_course.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "Course screenshot (CC-BY)."
---

Due to the requirement to move to remote assessment during the global Covid-19 pandemic, [Andrew Zammit-Mangion](https://andrewzm.wordpress.com/) (University of Wollongong, School of Mathematics and Applied Statistics) created introductory materials to help his colleagues to get started with [R/exams]({{ site.url }}) and turned these into a full online course. The video tutorials in the course show in simple steps how to:

* Install the software required to start generating random questions.
* Code up a simple question and answer.
* Formulate more complicated Q&As.
* Export these questions to individual assessment sheets (PDF).
* Export these questions to Moodle.

The course is hosted on Thinkific and is completely free, just requires registration or a login via a Google account or similar:

<div class="thinkific-product-card" data-btn-txt="Enrol here" data-btn-txt-color="#ffffff" data-btn-bg-color="#1b9eea" data-card-type="card" data-link-type="checkout" data-product="961945" data-embed-version="0.0.2" data-card-txt-color="#7d7d7d" data-card-bg-color="#ffffff" data-store-url="https://andrewzm.thinkific.com/embeds/products/show">
<div class="iframe-container"></div>
<script type="text/javascript">document.getElementById("thinkific-product-embed") || document.write('<script id="thinkific-product-embed" type="text/javascript"src="https://assets.thinkific.com/js/embeds/product-cards-client.min.js"><\/script>');</script>
<noscript><a href="https://andrewzm.thinkific.com/enroll/961945?et=free" target="_blank">Enrol here</a></noscript>
</div>

The materials are geared somewhat towards assessments containing mathematical exercises but are also easily accessible for users with other backgrounds. Due to the emphasis on mathematical content, the examples in the course are based on Rnw (Sweave) exercises allowing for seamless [LaTeX]({{ site.url }}/tutorials/latex) integration. Converting the exercises to Rmd (R/Markdown) format is also possible as shown in the [First steps]({{ site.url }}/tutorials/first_steps/ ) tutorial but this is not covered in the online course.
