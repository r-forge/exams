---
layout: workflow
#
# Content
#
title: "<img height='100%' src='../../images/vector/elearning.svg' alt='E-Learning'> E-Learning"
meta_title: "R/exams: E-Learning"
subheadline: "Tests for Moodle, Blackboard, ..."
teaser: "Easily generate large online tests for various learning management systems (like Moodle, Blackboard, OLAT, Ilias, ...)."
permalink: "/intro/elearning/"
#
# Style
#
image:
  # shown on top of blog post
  title: seminar.title.jpg
  # preview in list of posts
  thumb: seminar.cut.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC-BY)."

workflow:
  - step:
      img: ../../images/elearning-goal.svg
      alt: goal
      dsc: |
        ###### 1. Goal
        * Online tests as part of your course, typically using your
          university's learning management system (like Moodle,
          Blackboard, OLAT, Ilias).
        * But entering exams "by hand" is tedious and...
        * ...(a large number of) random variations of
          similar exercises is required to reduce the risk of cheating.
  - step:
      img: ../../images/elearning-create.svg
      alt: create
      dsc: |
        ###### 2. Create
        * Set up [(dynamic) exercise templates](../../intro/dynamic/).
        * Easily draw (very many) random replications from these templates.
        * Automatically embed these into an exchange file format (typically in HTML/XML).
  - step:
      img: ../../images/elearning-import.svg
      alt: import
      dsc: |
        ###### 3. Import
        * Import this file into a learning management system.
        * Either directly into an online test or into some question bank or item pool.
        * From there handle the online test "as usual" in the respective learning management system.

---

## Blog ##

* Tutorial: [Installing R/exams]({{ site.url }}/tutorials/installation/).
* Tutorial: [First steps]({{ site.url }}/tutorials/first_steps/).
* Tutorial: [Dynamic Online Tests with Blackboard and R/exams]({{ site.url }}/tutorials/exams2blackboard/).
* [Blog archive]({{ site.url }}/blog/).
