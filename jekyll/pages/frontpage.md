---
# uses metadata to contruct frontpage
layout: frontpage

# disable feeling responisve header. We use slick carousel instead
header: no

# 4 Topics. Image in Carousel + Icon
topics:
  - icon: vector/elearning.svg
    image: "seminar.cut.big.jpg"
    # align is placed as background-position style
    # https://www.w3schools.com/CSSref/pr_background-position.asp
    align: left center
    title: E-Learning
    url: '/intro/elearning/'
    description: |
      Exercises for Moodle, Blackboard, OLAT, ...

  - icon: vector/oneforall.svg
    image: "moodle-arsnova-nops.orig.jpg"
    title: One-for-All
    url: '/intro/oneforall/'
    description: |
      The same exercises in exams, online tests, and live voting.

  - icon: vector/written.svg
    image: "olympia_side_zoom.big.jpg"
    title: Written Exams
    url: '/intro/written/'
    description: |
      Automatic generation, scanning, and evaluation.

  - icon: vector/dynamic.svg
    image: "laptop_on_table_deriv2.cut.big.jpg"
    title: Dynamic Exercises
    url: '/intro/dynamic/'
    description: |
      Multiple choice, numeric, and text answers.

# Mission Statement
mission:
  title: <img width='50%' src='assets/img/logo_wide.svg'>
  statement: |
    The [open-source package exams](resources) for
    the R system for statistical computing provides a
    [one-for-all approach](intro/oneforall) to automatic exams generation. Based on (potentially)
    [dynamic exercise templates](intro/dynamic) large numbers of personalized exams/quizzes/tests can be
    created for various systems: PDFs for classical [written exams](intro/written) (with
    automatic evaluation), import formats for [learning management systems](intro/elearning) (like
    Moodle, Blackboard, OLAT, or Ilias), live voting (via ARSnova), and the
    possibility to create custom output (in PDF, HTML, Docx, ...).
    
    Exercises types include multiple-choice or single-choice questions, numeric
    or text answers, or combinations of these. Formatting can be done either in
    Markdown or LaTeX with the possibility to generate dynamic content using R,
    e.g., random numbers, graphics, data sets, or shuffled text blocks.

    R/exams is open-source software that can be freely used and extended. This
    web site provides an overview, short tutorials, a gallery of exercise
    templates, and links to further materials.

permalink: /
---
