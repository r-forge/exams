---
layout: workflow
#
# Content
#
title: "<img height='100%' src='../../images/vector/dynamic.svg'> Dynamic Exercises"
meta_title: "R/exams: Dynamic Exercises"
subheadline: "Templates with Random Elements"
teaser: "Randomize exercises dynamically (e.g., using shuffled items, different numbers, text blocks, ...)
  for a range of question formats (multiple-choice, single-choice, numeric, text, and combinations thereof).
  The R/exams templates provide a description of the exercises - independent of
  a particular output format or learning management system - with
  the text in either Markdown or LaTeX and the randomization in R."
permalink: "/intro/dynamic/"
#
# Style
#
image:
  # shown on top of blog post
  title: laptop_on_table_deriv2.title.jpg
  # preview in list of posts
  thumb: laptop_on_table_deriv2.orig.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC-BY)."

workflow:
  - step:
      img: ../../images/dynamic-schoice.svg
      alt: schoice
      dsc: |
        ###### `schoice`: Single-Choice
        * Task: Select the only correct item out of a list of alternatives.
        * Knowledge quiz: Arbitrary number of shuffled distractors
          (e.g., [swisscapital](../../templates/swisscapital/)).
        * Numeric exercises: Distractors are random numbers (from a set/interval)
          and/or typical arithmetic mistakes (e.g., [deriv2](../../templates/deriv2/),
          [tstat2](../../templates/tstat2/)).
        * Shuffling (or subsampling) can be turned on or off.
  - step:
      img: ../../images/dynamic-mchoice.svg
      alt: mchoice
      dsc: |
        ###### `mchoice`: Multiple-Choice
        * Task: Select all correct items out of a list of alternatives.
        * Knowledge quiz: Arbitrary number of shuffled true or false statements
          (e.g., [switzerland](../../templates/switzerland/)).
        * Interpretations: Numeric statements that are approximately
          correct or clearly wrong (e.g., [boxplots](../../templates/boxplots/),
          [scatterplot](../../templates/scatterplot/), [ttest](../../templates/ttest/)).
  - step:
      img: ../../images/dynamic-num.svg
      alt: num
      dsc: |
        ###### `num`: Numeric
        * Task: Compute a single numeric value (within a tolerance interval).
        * Numeric exercise: Solving typical arithmetic problems often based on
          some random numbers (e.g., [deriv](../../templates/deriv/),
          [tstat](../../templates/tstat/)).
  - step:
      img: ../../images/dynamic-string.svg
      alt: string
      dsc: |
        ###### `string`: Character String
        * Task: Enter the answer (exactly) as a character string.
        * Knowledge quiz: Sample a word/phrase from a given vocabulary
          or list of question/answer pairs (e.g., [function](../../templates/function/),
          [countrycodes](../../templates/countrycodes/)).
  - step:
      img: ../../images/dynamic-cloze.svg
      alt: cloze
      dsc: |
        ###### `cloze`: Cloze (Combinations of the Above)
        * Task: Solve a set of sub-exercises combining any of the above types.
        * Numeric exercises: Several numeric quantities based on the same
          problem setting (e.g., [confint2](../../templates/confint2/),
          [dist2](../../templates/dist2/), [fourfold](../../templates/fourfold/)).
        * Statistics: Qualitative single-choice questions plus numeric
          exercises based on randomly-generated data (e.g.,
          [boxhist](../../templates/boxhist/), [lm](../../templates/lm/)).

---

## Blog ##

* Gallery: [Exercise Templates]({{ site.url }}/templates/).
* [Blog archive]({{ site.url }}/blog/).

