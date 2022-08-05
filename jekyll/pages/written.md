---
layout: workflow
#
# Content
#
title: "<img height='100%' src='../../images/vector/written.svg' alt='Written Exams'> Written Exams"
meta_title: "R/exams: Written Exams"
subheadline: "Large-Scale Pen-and-Paper Exams"
teaser: "Manage large-scale written exams from generation to evaluation using R/exams."
permalink: "/intro/written/"
#
# Style
#
image:
  # shown on top of blog post
  title: olympia_side_zoom.title.jpg
  # preview in list of posts
  thumb: olympia_side_zoom.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams photo (CC-BY)."

workflow:
  - step:
      img: ../../images/written-create.svg
      alt: create
      dsc: |
        ###### 1. Create
        * Prepare a separate text file for each multiple-choice exercise.
        * Using `exams2nops()` from R/exams,
          create (individual) PDF files for each examinee.
  - step:
      img: ../../images/written-print.svg
      alt: print
      dsc: |
        ###### 2. Print
        * Print the PDF exams, e.g., on a standard printer.
        * ...or for large exams at a print shop.
  - step:
      img: ../../images/written-exam.svg
      alt: exam
      dsc: |
        ###### 3. Exam
        * Conduct the exam as usual.
        * Collect the completed exam sheets.
  - step:
      img: ../../images/written-scan.svg
      alt: scan
      dsc: |
        ###### 4. Scan
        * Scan all exam sheets, e.g., on a photocopier.
        * Using `nops_scan()` from R/exams,
          process the scanned exam sheets to obtain machine-readable content.
  - step:
      img: ../../images/written-evaluate.svg
      alt: evaluate
      dsc: |
        ###### 5. Evaluate
        * Using `nops_eval()` from R/exams,
          evaluate the exam to obtain grades, points, etc.
          and individual HTML reports for each examinee.
        * Required files: Correct answers from Step 1, scans from Step 4, and a
          participant list in CSV format.

---

## Blog ##

* Tutorial: [Installing R/exams]({{ site.url }}/tutorials/installation/).
* Tutorial: [First Steps]({{ site.url }}/tutorials/first_steps/).
* Tutorial: [Written Multiple-Choice Exams with R/exams]({{ site.url }}/tutorials/exams2nops/).
* [Blog archive]({{ site.url }}/blog/).

