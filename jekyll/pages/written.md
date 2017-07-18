---
layout: page
#
# Content
#
title: "<img height='100%' src='../../images/vector/written.svg'> Written Exams"
meta_title: "R/exams: Written Exams"
subheadline: "Large-Scale Pen-and-Paper Exams"
teaser: "Manage large-scale exams from generation to evaluation using R/exams."
permalink: "/intro/written/"
#
# Style
#
image:
  # shown on top of blog post
  title: olympia_side_zoom.big.jpg
  # preview in list of posts
  thumb: olympia_side_zoom.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC0)."
---

#### Workflow

- Create participant list (CSV).
- Generate exam files (PDF, via `exams2nops()`).
- Conduct the exam and collect the exams sheets.
- Scan the exam sheets (e.g., on a photopier) to either PDF or PNG format.
- Process the scanned exam sheets to obtain machine-readable content (via `nops_scan()`).
- Evaluate the exam to obtain marks, points, etc. and individual HTML reports for the students (vai `nops_eval()`).
