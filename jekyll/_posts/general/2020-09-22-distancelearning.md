---
layout: page
#
# Content
#
title: "R/exams for Distance Learning: Resources and Experiences"
teaser: "Resources and experiences shared by the R/exams community for supporting distance learning in different learning management systems."
categories:
  - general
tags:
  - R
  - exams
  - exams2moodle
  - exams2canvas
  - exams2openolat
  - exams2blackboard
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: distancelearning.title.png
  # preview in list of posts
  thumb: distancelearning.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC-BY)."
---


## Motivation

The COVID-19 pandemic forced many of us to switch abruptly from our usual teaching schedules to distance learning formats. Within days or a couple of weeks, it was necessary to deliver courses in live streams or screen casts, to develop new materials for giving students feedback online, and to move assessments to online formats. This led to a sudden increase in the interest in video conference software (like [Zoom](https://zoom.us/), [BigBlueButton](https://www.bigbluebutton.org/), ...), learning management systems (like [Moodle](https://www.moodle.org/), [Canvas](https://www.instructure.com/canvas/), [OpenOLAT](https://www.openolat.com/), [Blackboard](https://www.blackboard.com/), [ILIAS](https://www.ilias.de/), ...), and - last not least - our [R/exams]({{ site.url }}) package. Due to the flexible "one-for-all" approach, it was relatively easy for R/exams users who had been using the system for in-class materials to transition to e-learning materials. But also many new R/exams users emerged that were interested in leveraging their university's learning management system (often Moodle) for their classes (often related to statistics, data analysis, etc.).

As distance learning will continue to play an important role in most universities in the upcoming semester, I called for sharing experiences and resources related to R/exams. Here, I collect and summarize some of the feedback from the R/exams community. The full original threads can be found on Twitter and in the R-Forge forum, respectively.

* [Twitter (@AchimZeileis): After a semester of #distancelearning is before the next semester of #distancelearning...](https://twitter.com/AchimZeileis/status/1292774253516001280)
* [R-Forge forum: Experiences with R/exams for distance learning](https://R-Forge.R-project.org/forum/forum.php?thread_id=34019&forum_id=4377&group_id=1337).


## Resources

Due to the increased interest in R/exams, I contributed various YouTube videos to help getting an overview of the system and to tackle specific tasks (creating exercises or online tests, summative exams, etc.). Also, the many questions asked on StackOverflow and the R-Forge forum led to numerous improvements in the software and support for various typical challenges.

* R/exams webinar @ WhyR?: [YouTube video](https://www.youtube.com/watch?v=PnyCR7q4P4Q), [blog post]({{ site.url }}/general/whyr2020/).
* Video tutorials: [YouTube channel Achim Zeileis](https://www.youtube.com/channel/UCWDENSBdBxq-Z-hKIcLg1bA/videos).
* Questions & answers: [StackOverflow/r-exams](https://stackoverflow.com/questions/tagged/r-exams), [R-Forge forum](https://R-Forge.R-project.org/forum/forum.php?forum_id=4377).

But in addition to these materials that we developed, many R/exams users stepped up and also created really cool and useful materials. Especially from users in Spain came a lot of interest along with great contributions:

* Jonathan Tuke (YouTube video, in English): [Online tests in Canvas.](https://www.youtube.com/watch?v=yQnIxwTx_PU).
* Julio Mulero (blog post, in Spanish): [Online tests in Moodle](https://elultimoversodefermat.wordpress.com/2020/03/29/uso-de-r-para-la-elaboracion-de-cuestionarios-aleatorios-en-moodle/).
* Estadística útil (YouTube videos, in Spanish): [Package](https://www.youtube.com/watch?v=nL7iZhFJY1Y), [Installation](https://www.youtube.com/watch?v=YXuFFZK1gwE), [First steps](https://www.youtube.com/watch?v=BccEnoS2T6c), [Single choice](https://www.youtube.com/watch?v=UmX-RItyyQs), [Written exams](https://www.youtube.com/watch?v=fBIdJGphxGE), [Moodle exams](https://www.youtube.com/watch?v=6sv71iyYV1U).
* Pedro Luis Luque Calvo (YouTube video and blog, in Spanish): [Online tests in Blackboard](https://www.youtube.com/watch?v=X6dBJmzCAzE), [blog post](http://destio.us.es/calvo/post/2020-05-01-como-crear-examenes-con-rexams-y-rmarkdown/como-crear-examenes-con-rexams-y-rmarkdown/).
* Kenji Sato (blog posts, in Japanese or English): [Part 1](https://www.kenjisato.jp/post/2020/08/rexams-online-1/), [Part 2](https://www.kenjisato.jp/post/2020/08/rexams-online-2/), [Part 3](https://www.kenjisato.jp/post/2020/09/rexams-online-3/), [bordered tables](https://kenjisato.jp/en/post/2020/07/moodle-bordered-table/).


## At Universität Innsbruck

Not surprisingly, we had been using R/exams extensively in our teaching for a [blended learning approach in a Mathematics 101 course (R/exams blog)]({{ site.url }}/general/uibk_math/). The asynchronous parts of the course (screencasts, forum, self tests, and formative online tests) were already delivered through the university's OpenOLAT learning management system. Thus, we "just" had to switch the synchronous parts of the course (lecture, tutorials, and summative written exams) to distance learning formats:

&nbsp;           | Learning                   | Feedback                                                              | Assessment                                            |
:----------------|:---------------------------|:----------------------------------------------------------------------|:------------------------------------------------------|
**Synchronous**  | Lecture <br/> Live stream  | _Previously: Live quiz_ <br/> **Now: Online test** <br/> (+ Tutorial) | _Previously: Written exam_ <br/> **Now: Online exam** |
**Asynchronous** | Textbook <br/> Screencast  | Self test <br/> (+ Forum)                                             | Online test                                           |

The most challenging part was the [summative online exam (R/exams blog)]({{ site.url }}/tutorials/openolat_exam/) but overall everything worked out reasonably ok. One nice aspect was that other colleagues profited immediately from using a similar approach for their online exams as well. Like my colleague [Lisa Lechner](http://www.lisalechner.com/) from the Department of Political Science:

> Lisa Lechner: R/exams was a life-saver during the difficult semester we faced. I used it for the statistics lecture with approx. 300 students (final online exam, but also ARSnova questions) and for a smaller course on empirical methods in political science. But even before the pandemic, R/exams increased the fairness of my final exams and reduced the time spent on evaluating results. #bestRpackage2020


## Replacing written exams

Finding a suitable replacement for the summative written exams was not only a challenge for us. One concern that came up several times was that learning management systems like Moodle might not be reliable enough for online exams, especially if students' internet connections were flaky. Hence, one idea that was discussed, especially with [Felix Schönbrodt](https://www.nicebread.de/) and [Arthur Charpentier](https://freakonometrics.github.io/), was to e-mail [fillable PDF forms (StackOverflow Q&A)](https://stackoverflow.com/questions/62392297/create-fillable-pdf-form-with-exams2nops) to students [instead of relying entirely on Moodle (Twitter)](https://twitter.com/freakonometrics/status/1293985139089911820). However, I could convince them that PDF forms would create more problems than they solve (see the linked threads above for more details):

> [Felix Schönbrodt @nicebread303](https://twitter.com/nicebread303/status/1294213560923455489): We thought about doing a (pseudo-written) PDF-exam, but we are very glad that we followed @AchimZeileis advice to go for Moodle. Grading is so much easier!

Another concern is, of course, cheating, no matter which format the exams use. Many R/exams users recommended to use open-ended questions and/or more complex cloze questions forcing participants to interact with a certain randomized problem, e.g., based on a randomized data set. As [Ulrike Grömping](https://prof.beuth-hochschule.de/groemping/) reports, this can also be combined with online proctoring for moderately-sized exams.

> [Ulrike Grömping (R-Forge)](https://R-Forge.R-project.org/forum/forum.php?thread_id=34019&forum_id=4377&group_id=1337): I have also run online exams via Moodle in real time, supervised in a video conference [...]. And I have not used auto correction, but have asked questions that also require free text answers from students (text fields with arbitrary correct answer of (e.g.) 72 characters in a cloze exercise). Of course, the solutions support my manual correction process.

Other approaches to tackling this problem can be found in the [R-Forge thread](https://R-Forge.R-project.org/forum/forum.php?thread_id=34019&forum_id=4377&group_id=1337), see e.g., the contribution by Niels Smits.


## Moodle vs. other learning management systems

While overall there is a lot of heterogeneity in the learning management systems that the R/exams community uses, Moodle is clearly the favorite. Moodle quizzes also have their quirks but they are surprisingly flexible and can be used at various levels.

> [Eric Lin @LinXEric](https://twitter.com/LinXEric/status/1300750949368164352): I use #rexams extensively, have been for years. I used to do paper exams. Now, with distance learning, I'm serving up exams, quizzes, entry ticket questions, exit ticket questions, all using a #rexams with #moodle.

Especially, the cloze question format is popular, allowing to combine multiple-choice, single-choice, numeric, and string items.

> [Rebecca Killick (R-Forge)](https://R-Forge.R-project.org/forum/forum.php?thread_id=34019&forum_id=4377&group_id=1337): We moved to using this exclusively for our undergraduate quizzes in the summer of 2019 and this served us well when COVID-19 hit. We are now expanding our online assessment using R/exams. We mainly use cloze questions with randomization.

See also the tweet by [Emilio L. Cano @emilopezcano](https://twitter.com/emilopezcano/status/1292955475579932672).

Of course, other learning management systems are also very powerful with Blackboard and Canvas probably being second and third in popularity. The OpenOLAT system, also used at our university, is less popular but in various respects even more powerful than Moodle. The support of the QTI 2.1 standard (question and test interoperability) allows to specify a complete exam, including random selection of exercises, randomized order of questions, and flexible cloze questions.


## Collaborating with colleagues

One design principle of R/exams is that each exercise is a separate file. The motivation behind this is to make it easy to distribute work on a question bank among a larger group before someone eventually compiles a final exam from this question bank. Hence it's great to see that various R/exams users report that they work on the exercises together with their colleagues, e.g., [Fernando Mayer @fernando_mayer on Twitter](https://twitter.com/fernando_mayer/status/1293483065243832322) or:

> [Ilaria Prosdocimi @ilapros](https://twitter.com/ilapros/status/1292825732897476611): used by me and colleagues in Venice for about 500 exams via Moodle (in different basic stats courses). Mostly single choice and numeric questions. After some initial learning it worked perfectly and made the whole exam writing much easier.

For facilitating their collaboration, the group around Fernando Mayer has even created a [ShinyExams interface (in Portuguese)](http://shiny.leg.ufpr.br/fernandomayer/rexams/).


## Statistics & data science vs. other fields

It is not unexpected that the majority of the R/exams community employs the system for creating resources for teaching statistics, data science, or related topics. See the tweets and posts by [Filip Děchtěrenko @FDechterenko](https://twitter.com/FDechterenko/status/1293500357046403072), [@BrettPresnell](https://twitter.com/BrettPresnell/status/1308209477687152641), [Emi Tanaka @statsgen](https://twitter.com/statsgen/status/1292952412206972928), [Dianne Cook @visnut](https://twitter.com/visnut/status/1273445677482119168), and [Stuart Lee](https://stuartlee.org/2020/06/17/teaching-during-a-pandemic/). In many cases such courses are for students from other fields, such as pharmacy as reported by [Francisco A. Ocaña @faolmath](https://twitter.com/faolmath/status/1292879192854601728) or biology as reported by:

> [@OwenPetchey](https://twitter.com/OwenPetchey/status/1284062358709641217): The Data Analysis in Biology course at University of Zurich, with 300 students this spring, used this fantastic resource to author its final exams, with upload to OLAT.

However, there is also a broad diversity of other fields/topics, e.g., international finance and macroeconomics ([Kamal Romero @kamromero](https://twitter.com/kamromero/status/1292782321075130368)), applied economics and accounting ([Eric Lin @LinXEric](https://twitter.com/LinXEric/status/1300750949368164352)), econometrics (Francisco Goerlich), linguistics (Maria Paola Bissiri), [soil mechanics]({{ site.url }}/general/uibk_soilmechanics/) (Wolfgang Fellin), or programming (John Tipton).


## Going forward

All the additions, improvements, and bug fixes in R/exams that were added over the last month are currently only available in the [development version of R/exams 2.4-0 on R-Forge](https://R-Forge.R-project.org/R/?group_id=1337). The plan is to also release this version to CRAN in the next weeks.

Another topic, that will likely become more relevant in the next months as well, is the creation of interactive self-study materials outside of learning-management systems, e.g., as part of an online tutorial. [Debbie Yuster](http://www.sunymaritime.edu/faculty/science/debbie-yuster) nicely describes such a scenario:

> [Debbie Yuster (R-Forge)](https://R-Forge.R-project.org/forum/forum.php?thread_id=34019&forum_id=4377&group_id=1337): I plan to use R/exams to maintain source files for "video quizzes" students will take after they watch lecture videos asynchronously in my Introduction to Data Science course. Instructors at different universities will be using these videos (created by the curriculum author), and I will distribute the quizzes to interested faculty, each of whom may have a different preferred delivery mode. I'll be giving the quizzes through my LMS (Canvas), while others may administer the quizzes in learnr, or use a different LMS. With R/exams, I can maintain a single source, and instructors can convert the quizzes into their preferred format.

Two approaches that are particularly interesting are [learnr (RStudio)](https://github.com/rstudio/learnr), that uses R/Markdown with shiny, and [webex (psyTeachR project)](https://github.com/psyteachr/webex), that uses more lightweight R/Markdown with some custom Javascript and CSS. Some first proof-of-concept code is avaiable for a [learnr interface (R-Forge)](https://R-Forge.R-project.org/forum/forum.php?thread_id=34001&forum_id=4377&group_id=1337) and [integrating webex exercises in Markdown documents (StackOverflow Q&A)](https://stackoverflow.com/questions/62315622/using-r-exams-in-bookdown-document-especially-for-html-output) but more work is needed to turn this into full R/exams interfaces.
