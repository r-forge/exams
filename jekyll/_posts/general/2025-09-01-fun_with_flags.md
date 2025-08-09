---
layout: page
#
# Content
#
title: "R/exams Presents: Fun with Flags"
teaser: "A knowledge quiz about the flags of countries and their neighbors illustrates how R/exams and Quarto can be leveraged for standalone self-learning materials (and pays tribute to Sheldon Cooper)."

categories:
  - general
tags:
  - R
  - exams
  - exams2forms
  - flags
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: fun_with_flags.title.png
  # preview in list of posts
  thumb: fun_with_flags.300.png
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams logo (CC-BY-SA | GPL-2) + Fun with Flags image by Michael Heap."
---

## Overview

The recently introduced [exams2forms]({{ site.url }}/tutorials/exams2forms/) package extends [R/exams]({{ site.url }}) so that its [dynamic exercises]({{ site.url }}/intro/dynamic/) can be embedded in R/Markdown or Quarto documents, web pages, online books, etc. One potential application scenario for this is the creation of standalone HTML documents including self-learning materials, e.g., for providing [open educational resources (OER)](https://en.wikipedia.org/wiki/Open_educational_resources).

Here, this is illustrated by a knowledge quiz that pays tribute to the web series [Sheldon Cooper presents: Fun with Flags](https://the-big-bang-theory.com/fun_with_flags/), a spin-off from the popular sitcom "The Big Bang Theory". 

## Knowledge quiz

The quiz is provided in the standalone file [flags.html]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/flags.html){:target="_blank"} and it contains two tasks:

- _Guess the flag:_ The correct flag for a country has to be selected from a list of flags. The underlying exercise is provided in the `exams` package as [flags]({{ site.url }}/templates/flags/).

- _Find the neighbors:_ The flags of neighboring countries (for a country only identified by its flag) have to be selected from a multiple-choice list. The underlying exercise is provided in the `exams2forms` package as `geography.Rmd`.

Click on the screenshot below to try the quiz yourself. _(Note that you can also download the HTML file and play the quiz offline.)_

[![Screenshot of the standalone Fun with Flags quiz page]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/flags.png)]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/flags.html){:target="_blank"}


## Resources

To recreate the quiz file, the following resources are necessary. First, the exercise files for the two tasks are needed but, as pointed out above, these are shipped with the `exams` and `exams2forms` package, respectively. Second, the following files are needed to create a standalone HTML file containing 100 random variations from each of the exercises.

- [flags.qmd]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/flags.qmd): Quarto source file embedding the `exams2forms()` calls, see below.
- [webex.js]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/webex.js): Copy of the current Javascript code from the `exams2forms` package (version 0.2-0).
- [webex.css]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/webex.css): Copy of the current style sheets from the `exams2forms` package (version 0.2-0) with the highlight color changed to the R/exams primary color.
- [cosmo.scss]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/cosmo.scss): Style sheets for customizing the cosmo theme to the R/exams primary color and button-style tabsets.
- [fun_with_flags.png]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/fun_with_flags.png): Title image taken from [Michael Heap's Fun with Flags presentation](https://speakerdeck.com/mheap/dr-sheldon-cooper-presents-fun-with-flags-1).

If these files are placed in the same folder, the Quarto source file `flags.qmd` can be rendered and then produces [flags.html]({{ site.url }}/assets/posts/2025-09-01-fun_with_flags/flags.html){:target="_blank"}. When doing so in RStudio you can simply open the `flags.qmd` file and click on the rendering button. Alternatively, on the command line you can use `quarto render flags.qmd`.


## Quarto source file

The complete Quarto source file `flags.qmd` is also shown below. It contains the following parts:

- The YAML header (separated by `---`) sets the title using the logo image, loads all style files and scripts, and specifies that all resources should be embedded in order to make the resulting HTML file self-contained.
- The first R code chunk loads the `exams2forms` package (which also loads the `exams` package) and sets a random seed for reproducibility.
- Subsequently, a panel tabset with two sections is defined, each containing an R code calling `exams2forms()`.
- For the first task 100 random variations can be set up easily because `flags.Rmd` is found in the `exams` package.
- For the second task we need to set up the path to the `geography.Rmd` file in the `exams2forms` package, then its the `display` variable is fixed to `"flag"`, and finally 100 random variations are created.


````{r}
---
title: "![Fun with Flags](fun_with_flags.png){width=330px}"
format:
  html:
    theme:
      - cosmo
      - cosmo.scss
    toc: false
    css: webex.css
    include-after-body: webex.js
    embed-resources: true
---

```{r setup, include = FALSE}
library("exams2forms")
set.seed(0)
```

::: {.panel-tabset}
## Guess the flag

```{r flags, echo = FALSE, message = FALSE, results = "asis"}
exams2forms("flags.Rmd", n = 100)
```

## Find the neighbors

```{r geography, echo = FALSE, message = FALSE, results = "asis"}
geography <- system.file("exercises", "geography.Rmd", package = "exams2forms") |>
  expar(display = "flag")
exams2forms(geography, n = 100)
```

:::
````
