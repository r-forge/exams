---
# uses metadata to contruct frontpage
layout: frontpage

# disable feeling responisve header. We use slick carousel instead
header: no

# 4 Topics. Image in Carousel + Icon
topics:
  - icon: vector/elearning.svg
    image: "wikipedia_e-learning_cc0.big.jpg"
    title: E-Learning
    url: '/nowhere'
    description: |
      Exercises for Moodle, Blackboard, OLAT, ...

  - icon: vector/oneforall.svg
    image: "unsplash_helloquence-61189.big.jpg"
    title: One-For-All
    url: '/nowhere'
    description: |
      The same exercises in exams, online tests, and live voting.

  - icon: vector/written.svg
    image: "olympia_side_zoom.big.jpg"
    title: Written Exams
    url: '/nowhere'
    description: |
      Automatic generation, scanning, and evaluation.

  - icon: vector/dynamic.svg
    image: "screenshot-deriv-nvim-montage2.big.jpg"
    title: Dynamic Exercises
    url: '/nowhere'
    description: |
      Multiple choice, numeric, and text answers.

# Mission Statement
mission:
  title: <img width='50%' src='assets/img/logo_wide.svg'>
  statement: |
    The package exams for
    the R system for statistical computing provides a
    one-for-all approach to automatic exams generation. Based on dynamic
    exercise templates large numbers of personalized exams/quizzes/tests can be
    created for various systems: PDFs for classical written exams (with
    automatic evaluation), import formats for learning management systems (like
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
