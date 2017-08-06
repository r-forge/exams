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
  title: multiple-choice.big.jpg
  # preview in list of posts
  thumb: multiple-choice.150.jpg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "Photo from Alberto G. (CC-BY)."
  caption_url: "https://www.flickr.com/photos/albertogp123/5843577306/"
---

<table>
<tr>
  <td width="30%"><img src="../../images/written-create.svg" alt="create"/></td>
  <td width="70%">
  <b>Step 1</b>
  <ul>
    <li>Prepare a separate text file for each single- or multiple-choice exercise.</li>
    <li>Using <code class="highlighter-rouge">exams2nops()</code> from R/exams, create (individual) PDF files for each examinee.</li>
  </ul>
  </td>
</tr>
</table>

<table>
<tr>
  <td width="30%"><img src="../../images/written-print.svg" alt="create"/></td>
  <td width="70%">
  <b>Step 2</b>
  <ul>
    <li>Print the PDF exams, e.g., on a standard printer.</li>
    <li>...or for large exams at a print shop.</li>
  </ul>
  </td>
</tr>
</table>

<table>
<tr>
  <td width="30%"><img src="../../images/written-exam.svg" alt="create"/></td>
  <td width="70%">
  <b>Step 3</b>
  <ul>
    <li>Conduct the exam as usual.</li>
    <li>Collect the completed exams sheets.</li>
  </ul>
  </td>
</tr>
</table>

<table>
<tr>
  <td width="30%"><img src="../../images/written-scan.svg" alt="create"/></td>
  <td width="70%">
  <b>Step 4</b>
  <ul>
    <li>Scan all exam sheets, e.g., on a photopier.</li>
    <li>Output can be either PDF (multiple sheets per file) or PNG (1 sheet per file).</li>
    <li>Using <code class="highlighter-rouge">nops_scan()</code> from R/exams, process the scanned exam sheets to obtain machine-readable content.</li>
  </ul>
  </td>
</tr>
</table>

<table>
<tr>
  <td width="30%"><img src="../../images/written-evaluate.svg" alt="create"/></td>
  <td width="70%">
  <b>Step 5</b>
  <ul>
    <li>And with <code class="highlighter-rouge">nops_eval()</code> evaluate the exam to obtain marks, points, etc. and individual HTML reports for each participant.</li>
    <li>Required files: Correct answers from Step 1, scans from Step 4, and a participant list in CSV format.</li>
  </ul>
  </td>
</tr>
</table>


