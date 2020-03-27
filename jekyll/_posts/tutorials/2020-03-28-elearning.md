---
layout: page
#
# Content
#
title: "E-Learning Quizzes with R/exams for Moodle and OpenOLAT"
teaser: "Step-by-step tutorials for generating, importing, and customizing online tests and quizzes using exams2moodle() and exams2openolat() in R/exams."
categories:
  - tutorials
tags:
  - exams2moodle
  - exams2openolat
  - e-learning
  - quiz
  - num
  - mchoice
  - schoice
  - cloze
  - R
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: elearning.title.png
  # preview in list of posts
  thumb: elearning.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams + Moodle + OpenOLAT (CC-BY-SA)."
---


## Motivation

<div class='row t20 b20'>
  <div class='small-8 medium-9 columns'>

<p>E-learning resources such as online tests and quizzes or more formal e-exams are very useful in a variety of settings: formative vs. summative assessments; in-class vs. distance learning; synchronous vs. asynchronous; small vs. large groups of students. Some typical examples are outlined here.</p>

  </div>
  <div class='small-4 medium-3 columns'>
    <img src="{{ site.url }}/images/elearning-goal.svg" alt="Motivation"/>
  </div>
</div>


* Short tests/quizzes conducted in-class (synchronously) as a quick assessment of content the students had to prepare before class. In a flipped classroom approach the test/quiz might also be conducted after a collaboration phase in class.
* Asynchronous online tests that students can do in their own time (e.g., over several days) to obtain (incentivized) feedback regarding their learning progress. Such tests might follow any form of content delivery, be it classical lectures or video screencasts or some other approach.
* Synchronous e-exams conducted in-class or remotely (e.g., coupled with a safe exam browser) as a summative assessment at the end of a course.

[R/exams]({{ site.url }}) can support these scenarios by creating a sufficiently large number of randomized versions of [dynamic exercises]({{ site.url }}/intro/dynamic/) that can subsequently be imported into a learning management system (LMS). The actual quiz/test/exam is then conducted in the LMS only, i.e., without the need to have R running in the background, because all exercises and corresponding solutions have been pre-computed and stored in the LMS. Popular LMS include the open-source systems [Moodle](https://moodle.org/), [Canvas](https://www.instructure.com/canvas/), [OpenOLAT](https://www.openolat.com/?lang=en), or [Ilias](https://www.ilias.de/en/) or the commerical [Blackboard](https://www.blackboard.com/) system. R/exams provides suitable interfaces for all of these but the capabilities differ somewhat between the LMS. In the following we focus on Moodle and OpenOLAT, both of which provide very flexible and powerful assessment modules.


## Creation in R/exams

<div class='row t20 b20'>
  <div class='small-8 medium-9 columns'>

<p>Just like for other R/exams interfaces the starting point is putting together a vector or list of <a href="{{ site.url }}/intro/dynamic/">(potentially) dynamic exercises</a> in R. From these exercises - in either R/Markdown or R/LaTeX format - a number of random replications can be drawn using either <code class="highlighter-rouge">exams2moodle()</code> or <code class="highlighter-rouge">exams2openolat()</code>, respectively. Both interfaces support all R/exams exercise types: single-choice (<code class="highlighter-rouge">schoice</code>), multiple-choice (<code class="highlighter-rouge">mchoice</code>), numeric (<code class="highlighter-rouge">num</code>), string (<code class="highlighter-rouge">string</code>), or combinations of these (<code class="highlighter-rouge">cloze</code>). See the <a href="{{ site.url }}/tutorials/first_steps/">First Steps</a> tutorial for more details.</p>

  </div>
  <div class='small-4 medium-3 columns'>
    <img src="{{ site.url }}/images/elearning-create.svg" alt="Creation"/>
  </div>
</div>

Here, we use a collection of exercise templates that are all shipped within the R/exams package and that cover a broad range of different question types as well as different randomyly-generated content (shuffling, random parameters, R output, graphics, simulated data sets).


| Exercise template                                     | Type      | Task                                                                               |
|:------------------------------------------------------|:----------|:-----------------------------------------------------------------------------------|
| [swisscapital]({{ site.url}}/templates/swisscapital/) | `schoice` | Knowledge quiz question with basic shuffling                                       |
| [deriv]({{ site.url}}/templates/deriv/)               | `num`     | Computing the derivative of a function with randomized parameters                  |
| [ttest]({{ site.url}}/templates/ttest/)               | `mchoice` | Interpretation of R output from `t.test()`                                         |
| [boxplots]({{ site.url}}/templates/boxplots/)         | `mchoice` | Interpretation of parallel boxplots                                                |
| [function]({{ site.url}}/templates/function/)         | `string`  | Knowledge quiz question where the answer is the name of an R function              |
| [lm]({{ site.url}}/templates/lm/)                     | `cloze`   | Conducting a simple linear regression based on a randomly-generated CSV file       |
| [fourfold2]({{ site.url}}/templates/fourfold2/)       | `cloze`   | Completing a fourfold table based on verbal description with randomized parameters |

First, we load the `exams` package and define a vector with all exercise `.Rmd` file names.


<pre><code class="prettyprint ">library(&quot;exams&quot;)
elearn_exam &lt;- c(&quot;swisscapital.Rmd&quot;, &quot;deriv.Rmd&quot;, &quot;ttest.Rmd&quot;,
  &quot;boxplots.Rmd&quot;, &quot;function.Rmd&quot;, &quot;lm.Rmd&quot;, &quot;fourfold2.Rmd&quot;)</code></pre>

Alternatively, the corresponding `.Rnw` files could be used, yielding virtually identical output.



Second, we generate a Moodle XML file with 3 random replications of each of the exercises.


<pre><code class="prettyprint ">set.seed(2020-03-15)
exams2moodle(elearn_exam, n = 3, name = &quot;R-exams&quot;)</code></pre>

This yields the file [R-exams.xml]({{ site.url }}/assets/posts/2020-03-28-elearning//R-exams.xml) that can be imported into Moodle.

Analogously, a ZIP archive containing QTI 2.1 XML files (Question & Test Interoperability standard) for import into OpenOLAT.


<pre><code class="prettyprint ">set.seed(2020-03-15)
rxm &lt;- exams2openolat(elearn_exam, n = 3, name = &quot;R-exams&quot;)</code></pre>

The resulting output file is [R-exams.zip]({{ site.url }}/assets/posts/2020-03-28-elearning//R-exams.zip).

Moreover, to show that the object returned within R can also be useful we have assigned the output of `exams2openolat()` to an object `rxm`. This is not necessary but inspecting this object might be helpful when developing and testing new exercises. In particular, we can easily extract the meta-information regarding the correct answers in all randomly generated exercises.


<pre><code class="prettyprint ">exams_metainfo(rxm)</code></pre>



<pre><code>## 
## exam1
##     1. Swiss Capital: 4
##     2. derivative exp: 38.72 (38.71--38.73)
##     3. 2-sample t-test: 1, 2, 5
##     4. Parallel boxplots: 2, 4, 5
##     5. R functions: lm
##     6. Linear regression: FALSE, FALSE, TRUE | -0.861
##     7. fourfold: 4.44 | 19.74 | 1.56 | 74.26 | 24.18 | 75.82 | 6 | 94 | 100
## 
## exam2
##     1. Swiss Capital: 4
##     2. derivative exp: 2 (1.99--2.01)
##     3. 2-sample t-test: 3
##     4. Parallel boxplots: 2, 3, 4
##     5. R functions: vcov
##     6. Linear regression: FALSE, TRUE, FALSE | 0.531
##     7. fourfold: 5.76 | 23.92 | 2.24 | 68.08 | 29.68 | 70.32 | 8 | 92 | 100
## 
## exam3
##     1. Swiss Capital: 2
##     2. derivative exp: 2.05 (2.04--2.06)
##     3. 2-sample t-test: 2, 3
##     4. Parallel boxplots: 2, 4, 5
##     5. R functions: glm
##     6. Linear regression: TRUE, FALSE, FALSE | 0.024
##     7. fourfold: 6.5 | 22.5 | 3.5 | 67.5 | 29 | 71 | 10 | 90 | 100
</code></pre>

## Import into Moodle and OpenOLAT

<div class='row t20 b20'>
  <div class='small-8 medium-9 columns'>

<p>Finally, the output files generated above can be imported into the Moodle and OpenOLAT learning management system, respectively. In Moodle the random exercises are imported into a question bank based on which a quiz with randomly-selected questions can be constructed. In OpenOLAT the import directly yields a test learning resource that can then be embedded in a course.</p>

  </div>
  <div class='small-4 medium-3 columns'>
    <img src="{{ site.url }}/images/elearning-import.svg" alt="Import"/>
  </div>
</div>


### Moodle import

A step-by-step video guide to importing and customizing the quiz in Moodle is available on YouTube at <https://www.youtube.com/watch?v=5K9hrE3YkPs>.

[![Moodle import]({{ site.url }}/assets/posts/2020-03-28-elearning/moodle.png)](https://www.youtube.com/watch?v=5K9hrE3YkPs)

### OpenOLAT import

A step-by-step video guide to importing and customizing the test in OpenOLAT is available on YouTube at <https://www.youtube.com/watch?v=1ZhdmoDtUSA>.

[![OpenOLAT import]({{ site.url }}/assets/posts/2020-03-28-elearning/openolat.png)](https://www.youtube.com/watch?v=1ZhdmoDtUSA)

