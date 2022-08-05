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
      Exercises for Moodle, Canvas, OpenOlat, Blackboard, ...

  - icon: vector/oneforall.svg
    image: "moodle-arsnova-nops.big.jpg"
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
  title: <img width='50%' src='assets/img/logo_wide.svg' alt='R/exams logo'>
  statement: |
    **Overview:** The [open-source package 'exams'](/resources/) for
    the R system for statistical computing provides a
    [one-for-all approach](/intro/oneforall/) to automatic exams generation. Based on (potentially)
    [dynamic exercise templates](/intro/dynamic/) large numbers of personalized exams/quizzes/tests can be
    created for various systems: PDFs for classical [written exams](/intro/written/) (with
    automatic evaluation), import formats for [learning management systems](/intro/elearning/) (like
    Moodle, Canvas, OpenOlat, or Blackboard), live voting (via ARSnova), and the
    possibility to create custom output (in PDF, HTML, Docx, ...).
    
    **Get started:** Follow the tutorials on [Installation]((/tutorials/installation/))
    and [First Steps](/tutorials/first_steps/). Subsequently, start creating
    [exercises](/intro/dynamic/) and use them for [e-learning](/intro/elearning/) or
    [written exams](/intro/written/) etc. See also the available
    [video tutorials on YouTube](https://www.youtube.com/playlist?list=PLsEZAAbioUw1IBnhtBi9eIo0uqMHmqDor)

permalink: /
---
