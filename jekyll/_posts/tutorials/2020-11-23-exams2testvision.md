---
layout: page
#
# Content
#
title: "Online Tests for TestVision with R/exams"
teaser: "Generating, importing, and customizing online tests for TestVision with R/exams."
categories:
  - tutorials
tags:
  - e-learning
  - quiz
  - num
  - mchoice
  - schoice
  - string
  - cloze
  - R
author: smits

#
# Style
#
image:
  # shown on top of blog post
  title: exams2testvision.title.png
  # preview in list of posts
  thumb: exams2testvision.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams + TestVision (CC-BY-SA)."
---




## Motivation

This tutorial illustrates how to use [R/exams]({{ site.url }}) for creating online exams for [TestVision](https://www.testvision.nl/en/). Testvision is a Dutch commercial online testing company which administers online exams for many universities in the Netherlands. Until now the import of external material from R/exams into TestVision was rather limited, and therefore a new function was necessary.

Here, two things are illustrated:

1. Steps required using R/exams to create tests in TestVision format.
2. Steps required in TestVision online to import these tests in TestVision system.

An accompanying video guide is available on YouTube at <https://www.youtube.com/watch?v=rrpudw2aKVc>.

[![exams2testvision]({{ site.url }}/assets/posts/2020-11-23-exams2testvision/exams2testvision.png)](https://www.youtube.com/watch?v=rrpudw2aKVc)


## Steps in R

### Install the package

At the moment (November 2020) the `exams2testvision()` function is not yet part of the CRAN version of R/exams. For the time being one should use the development version from R-forge. To obtain it, use:


<pre><code class="prettyprint ">install.packages(&quot;exams&quot;, repos = &quot;http://R-Forge.R-project.org&quot;)</code></pre>

Note that this line of code only needs to be run once, and that after that R/exams is permanently installed on your machine.


### Run example

After loading the exams package, we create an exam called `myexam` which is a list of exercises. It consists of, respectively, a [num]({{ site.url }}/tag/num/), [schoice]({{ site.url }}/tag/schoice/), [mchoice]({{ site.url }}/tag/mchoice/), [string]({{ site.url }}/tag/string/), and [cloze]({{ site.url }}/tag/cloze/) item.


<pre><code class="prettyprint ">library(&quot;exams&quot;)
myexam &lt;- list(
  &quot;calcmean.Rmd&quot;,
  &quot;tstat2.Rmd&quot;,
  &quot;relfreq.Rmd&quot;,
  &quot;essayreg.Rmd&quot;,
  &quot;boxhist.Rmd&quot;
)</code></pre>

The first item in the list of exercises, [calcmean.Rmd]({{ site.url }}/assets/posts/2020-11-23-exams2testvision//calcmean.Rmd) (or alternatively [calcmean.Rnw]({{ site.url }}/assets/posts/2020-11-23-exams2testvision//calcmean.Rnw) in R/LaTeX format), is a question that is **not** part of the package. It was added to show (a) how a table may be generated, an (b) what this table looks like in TestVision. For things to work this exercise should be saved in the working directory. The remaining exercises do not need to be copied as they are shipped withing the package. For more information on these exercises, see: [tstat2]({{ site.url }}/templates/tstat2/), [relfreq]({{ site.url }}/templates/relfreq/), [essayreg]({{ site.url }}/templates/essayreg/), [boxhist]({{ site.url }}/templates/boxhist/).

As a first quick check that all exercises work correctly and can be rendered well in a browser, we use the following code (setting a seed for exact reproducibility):


<pre><code class="prettyprint ">set.seed(127)
exams2html(myexam, converter = &quot;pandoc-mathjax&quot;)</code></pre>



[![testvision.html]({{ site.url }}/assets/posts/2020-11-23-exams2testvision/testvision-html.png)]({{ site.url }}/assets/posts/2020-11-23-exams2testvision//testvision.html)

Subsequently, we create the import file for an exam in TestVision.


<pre><code class="prettyprint ">set.seed(127)
exams2testvision(myexam)</code></pre>

In the working directory a zip file called [testvision.zip]({{ site.url }}/assets/posts/2020-11-23-exams2testvision//testvision.zip) is created, which includes (a) a collection of XML files containing the exercises in TestVision format (based on QTI 2.1) and (b) a directory containing supplementary material, such as images and data files.


## Steps in TestVision

### Importing R/exams output

To import the exams created using R/exams into TestVision the following steps should be performed:

1. Log in into your institution's TestVision site.
2. Select 'Vragen' ('Questions').
3. Select 'Import' in the upper left corner.  
   A pop-up screen called 'Vragen importeren' ('Import questions') appears .
4. Select the zip-file 'testvision.zip' on your computer.
5. Check the option 'Minder strikte import controle' ('less strict import evaluation').
6. Click 'OK'. **Uploading may take a while!**
 
_Comment:_ Here 'Minder strikte import controle' was required because the first exercise contains a table. TestVision has very strict rules for the HTML structure of tables, and when this option is not chosen uploading fails.


### Inspecting the exam

Once imported you can take a closer look at the content using 'Preview'. To permanently import the questions they should be moved to a directory.

1. Under '&#8230;' select 'Geïmporteerde vragen verplaatsen' ('Move imported questions').
2. Select an appropriate directory and click 'OK'.  
   In this directory the questions can be edited and inspected more closely.
3. Select 'Bewerken' ('Edit') to learn more about the content and settings and/or edit the exercises.

Note that formula content is displayed using a relatively large font size. This is a TestVision issue. Hopefully it will disappear in future versions of the system. For now: The font size can be manually adjusted.

To employ the collection of items in a online exam, (a) their status should be changed (from 'Concept') into 'Approved (Aan)', (b) a new test should be created by selecting 'Toets' ('Test') in the main menu, and (c) the new items should be included in the new test. For more information see the help function in TestVision.

## Funding

The work on the `exams2testvision()` function, the video tutorial, and this blog are part of the [ShareStats](https://www.sharestats.nl/) project, and are financially supported by the Dutch Ministry of Education, Culture and Science (Project code OL20-06), and the University of Amsterdam.
