---
layout: page
#
# Content
#
title: "Transitioning a Soil Mechanics Course to R/exams"
teaser: "Experiences with transitioning to R/exams for multiple automated and randomized online exams in a soil mechanics course at Universität Innsbruck (UIBK)."
categories:
  - general
tags:
  - R
  - exams
  - exams2openolat
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: uibk_soilmechanics.title.svg
  # preview in list of posts
  thumb: uibk_soilmechanics.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "Typical issue in soil mechanics: Slope stabilty (CC-BY)."
---

Guest post by [Wolfgang Fellin](https://www.uibk.ac.at/geotechnik/staff/wolfgang_fellin.html) (Universität Innsbruck, Division of Geotechnical and Tunnel Engineering).



## Background

Our exercises in soil mechanics are attended by about 120 students every year. Students receive
their grades based on a final exam, with a multiple-choice part and additional small exercises with
calculations. Due to the COVID-19 restrictions we were forced to switch from the written exams to
online exams at rather short notice, for which we decided to use [R/exams]({{ site.url }}) to randomize the exercises.
The possibility that the exercises produced can be used in the following (hopefully COVID-free years) as part of a blended
learning course made the decision for the (not so small) effort to switch to R/exams easy.


## Transition of multiple-choice exercises

To leverage the about 100 multiple-choice exercises from our old question pool, we had to convert them to
the [R/exams format]({{ site.url }}/intro/dynamic/). The pool was stored in a MySQL data base
including LaTeX text for the questions, answer alternatives, images for some exercises (in EPS format)
and some additional meta-information regarding the topic category and the difficulty. Due to
the standardized format of the question pool - and the kind support by Achim Zeileis and Christiane Ernst -
it was possible to extract all questions, embed them into the same template for R/LaTeX questions (.Rnw),
and convert all EPS figures to both SVG and PDF format.
A typical example is shown below (in a screen shot from [OpenOLAT](https://www.openolat.com/),
the learning management system at UIBK).

[![grundwasser-1-068.png]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//grundwasser-1-068.png)]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//grundwasser-1-068.png)

The corresponding R/LaTeX exercise file is [grundwasser-1-068.Rnw]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//grundwasser-1-068.Rnw) which we also converted to
R/Markdown for this blog post: [grundwasser-1-068.Rmd]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//grundwasser-1-068.Rmd). Both rely on the corresponding
image file being available in the same directory or a sub-directory. Different graphics formats are used for
different exam output formats: [image68_1.svg]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//image68_1.svg), [image68_1.pdf]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//image68_1.pdf),
[image68_1.eps]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//image68_1.eps).

Essentially, the exercises consist of:
* some R code for including the right graphics file (SVG vs. PDF) depending on the type of output format (HTML vs. PDF),
* the (static) question text and answer alternatives in LaTeX format,
* meta-information including `exextra` tags for our custom topic category and difficulty level,
* the `exshuffle` tag is used for randomly subsampling the available answer alternatives.


## New numeric exercises

While the subsampling approach in the multiple-choice exercises provides a certain level of
randomization, I wanted to set up new numeric exercises in which all students have to calculate
the correct solution(s) based on their personalized parameters. Therefore, I set up new numeric
exercises in `cloze` format where several quantities have to be computed based on the same
question text. A typical example is shown below.

[![num-setzung-1-steinbrenner.png]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//num-setzung-1-steinbrenner.png)]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//num-setzung-1-steinbrenner.png)

Again, the corresponding exercise files are available as:
[num-setzung-1-steinbrenner.Rnw]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//num-setzung-1-steinbrenner.Rnw),
[num-setzung-1-steinbrenner.Rmd]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//num-setzung-1-steinbrenner.Rmd).  
And the graphics files are:
[steinbrenner_fdmt.svg]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//steinbrenner_fdmt.svg),
[steinbrenner_fdmt.pdf]({{ site.url }}/assets/posts/2020-08-31-uibk_soilmechanics//steinbrenner_fdmt.pdf).

Despite being a newcomer to both R and R/exams, setting up these exercises was quite easy
because I have been using MATLAB for a long time and could quickly grasp basic R code.
Also the [exercise templates]({{ site.url }}/templates/) available online helped as did the
friendly e-mail support by Achim for resolving many of the small "details" along the way.


## Exam implementation

Following the R/exams tutorial on [summative online exams in OpenOLAT]({{ site.url }}/tutorials/openolat_exam/)
I prepared the online exam using the `exams2openolat()` function. The R code I used along with a couple
of comments is provided below.


<pre><code class="prettyprint ">## load package
library(&quot;exams&quot;)

## exercises for the exam
## (the actual exam had 16 exercises overall, not just 2)
exm &lt;- c(&quot;grundwasser-1-068.Rnw&quot;, &quot;num-setzung-1-steinbrenner.Rnw&quot;)

## date used as seed and file name
dat &lt;- 20200528
set.seed(dat)

rxm &lt;- exams2openolat(exm,
  edir = &quot;/path/to/exercise/folder/&quot;,
  n = 200,                ## number of random versions for each exercise
  name = paste(&quot;BmGb1-Onlinetest&quot;, dat, sep = &quot;_&quot;),
  points = 1,             ## all exercises yield 1 point
  cutvalue = 8,           ## threshold for passing the exam
  
  ## evaluation rule for multiple-choice exercises (standalone and within cloze):
  ## every wrong answer cancels a correct answer
  mchoice = list(eval = exams_eval(partial = TRUE, negative = FALSE, rule = &quot;true&quot;)),
  cloze   = list(eval = exams_eval(partial = TRUE, negative = FALSE, rule = &quot;true&quot;)),

  solutionswitch = FALSE, ## do not show full solution explanation
  maxattempts = 1,
  shufflesections = TRUE, ## sequence of exercises is shuffled randomly
  navigation = &quot;linear&quot;,  ## disable switching back and forth between exercises
  duration = 120,         ## 2 hours
  stitle = &quot;Exercise&quot;,    ## section title (for group of exercises)
  ititle = &quot;Question&quot;     ## item title (for individual exercises)
)</code></pre>


## Challenges and outlook

The main problem by producing randomized numeric examples was to find limits for the input so that
the output is physically reasonable. Especially for newly created exercises, it is absolutely necessary
that other colleagues act as test calculators, such that errors can be detected before students find
them in their exams. The [stress testing]({{ site.url }}/tutorials/stresstest/) facilities in
R/exams can also help.

Since the course will continue being online in 2020/21 due to ongoing COVID-19 restrictions,
I use R/exams now also for the practice exercises which students have to calculate during the semester.
Thus, I produced about 70 new exercises, which are offered in OpenOLAT in 12 weekly online tests.
After COVID-19 I will use these examples as addition to written ones, where longer and more complex
task could be trained.
