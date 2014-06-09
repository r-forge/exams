
<!-- This is the project specific website template -->
<!-- It can be changed as liked or replaced by other content -->

<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='r-forge.r-project.org/themes/rforge/';

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en   ">

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>exams: Automatic Generation of Exams in R</title>
	<link href="http://<?php echo $themeroot; ?>styles/estilo1.css" rel="stylesheet" type="text/css" />
  </head>

<body>

<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr><td>
<a href="http://R-Forge.R-project.org/"><img src="http://<?php echo $themeroot; ?>/imagesrf/logo.png" border="0" alt="R-Forge Logo" /> </a> </td> </tr>
</table>


<!-- get project title  -->
<!-- own website starts here, the following may be changed as you like -->

<h2>exams: Automatic Generation of Exams in R</h2>

<p>Sweave-based automatic generation of exams including multiple-choice questions and arithmetic problems.
Exams can be produced in various formats, including PDF, HTML, Moodle XML, QTI 1.2 (for OLAT/OpenOLAT), QTI 2.1.</p>

<ul>
  <li>Release version on <a href="http://CRAN.R-project.org/package=exams">CRAN</a>.</li>
  <li>Development version on <a href="http://R-Forge.R-project.org/R/?group_id=1337">R-Forge</a>.</li>
</ul>

<h3>Version 2: Exams in PDF, HTML, Moodle XML, QTI 1.2 (for OLAT/OpenOLAT), QTI 2.1</h3>

<ul>
  <li><a href="http://www.jstatsoft.org/v58/i01/">Manuscript</a> in Journal of Statistical Software, 58(1), 1-36.</li>
  <li><a href="http://eeecon.uibk.ac.at/~zeileis/papers/useR-2013.pdf">Presentation slides</a> from useR! 2013 conference.</li>
  <li><a href="http://R-Forge.R-project.org/forum/?group_id=1337">Support forum</a> for e-learning exams in Moodle, OLAT, etc.</li>
  <li><a href="http://R-Forge.R-project.org/projects/exams/">Project summary</a> on R-Forge.</li>
  <li><a href="tth-src">Source distribution</a> of the C code for the TeX-to-HTML converter TtH.</li>
</ul>


<h3>Version 1: Exams (and self-study materials) as PDF files</h3>

<ul>
  <li><a href="http://www.jstatsoft.org/v29/i10/">Manuscript</a> in Journal of Statistical Software, 29(10), 1-14.</li>
  <li><a href="http://eeecon.uibk.ac.at/~zeileis/papers/useR-2011.pdf">Presentation slides</a> from useR! 2011 conference.</li>
</ul>

</body>
</html>
