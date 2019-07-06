## R/exams useR! tutorial -----------------------------------------------------------

## 14:00 Introduction (overview, installation, written exam)
## 14:30 Dynamic exercises (numeric, single choice, multiple choice, cloze)
## 15:00 One-for-all (plain PDF, plain HTML, Moodle XML)
## 15:30 --- Break ---
## 16:00 E-Learning (Moodle, Canvas, ARSnova, ...)
## 16:30 Written exams (NOPS)
## 17:00 Outlook


## Introduction ---------------------------------------------------------------------

## for installation see Steps 1-4 in http://www.R-exams.org/tutorials/installation/

## load package
library("exams")

## below we follow http://www.R-exams.org/tutorials/first_steps/

## create exams skeleton with:
## - demo-*.R scripts
## - exercises/ folder with all .Rmd/.Rnw exercises
## - templates/ folder with various customizable templates
## - nops/ folder (empty) for exams2nops output
exams_skeleton()

## single-choice question: knowledge quiz about the Swiss capital
## (http://www.R-exams.org/templates/swisscapital/)
exams2html("swisscapital.Rmd")
exams2pdf("swisscapital.Rmd")

## numeric question with mathematical notation: product rule for derivatives
## (http://www.R-exams.org/templates/deriv/)
exams2html("deriv.Rmd")
exams2html("deriv.Rmd", converter = "pandoc-mathjax")
exams2pdf("deriv.Rmd")
    
## extract the meta-information to check whether it is processed correctly
exams_metainfo(exams2html(c("swisscapital.Rmd", "tstat.Rmd")))


## Dynamic exercises ----------------------------------------------------------------

## for the supported exercise types see http://www.R-exams.org/intro/dynamic/
## for example exercise templates see http://www.R-exams.org/templates/

## for an overview of the available exercise files, switch to the "exercises" folder
setwd("exercises")
dir()

## numeric exercises
exams2html(c(
  "deriv.Rmd",        ## product rule for derivatives
  "tstat.Rmd",        ## 1-sample t-test statistic
  "dist.Rmd",         ## distances and the Pythagorean theorem
  "regression.Rmd",   ## simple linear regression (by hand)
  "fruit.Rmd",        ## image-based systems of linear equations (numeric)
  "lagrange.Rmd",     ## method of Lagrange multipliers
  "currency8.Rmd"     ## convert currencies (UTF-8 encoding)
))

## single-choice exercises
exams2html(c(
  "swisscapital.Rmd", ## knowledge quiz question about the Swiss capital
  "Rlogo.Rmd",        ## knowledge quiz question about the R logo
  "deriv2.Rmd",       ## product rule for derivatives (single-choice, via num_to_schoice)
  "tstat2.Rmd",       ## 1-sample t-test statistic (single-choice, by hand)
  "dist3.Rmd",        ## distances and the Pythagorean theorem (single-choice, via num_to_schoice)
  "fruit2.Rmd",       ## image-based systems of linear equations (single-choice, via num_to_schoice)
  "hessian.Rmd",      ## 2x2 Hessian matrix (single-choice)
  "logic.Rmd"         ## interpretation of logic gates (using TikZ)
))

## multiple-choice exercises
exams2html(c(
  "switzerland.Rmd",  ## knowledge quiz question about Switzerland
  "gaussmarkov.Rmd",  ## knowledge quiz question about Gauss-Markov assumptions
  "anova.Rmd",        ## 1-way analysis of variance
  "boxplots.Rmd",     ## interpretation of 2-sample boxplots
  "scatterplot.Rmd",  ## interpretation of a scatterplot
  "ttest.Rmd",        ## interpretation of 2-sample t test
  "relfreq.Rmd",      ## interpretation of relative frequency tables
  "cholesky.Rmd",     ## Cholesky decomposition
  "automaton.Rmd"     ## interpretation of automaton diagrams (using TikZ)
))

## string exercises
exams2html(c(
  "function.Rmd",     ## string question about R functions
  "countrycodes.Rmd"  ## string question about ISO country codes
))

## cloze exercises (combining several num/schoice/mchoice/string parts)
exams2html(c(
  "lm.Rmd",           ## simple linear regression (with CSV data, schoice/num)
  "boxhist.Rmd",      ## univariate exploration of a CSV file (schoice/num)
  "confint2.Rmd",     ## 2-sided confidence interval (num)
  "dist2.Rmd",        ## three distances in a Cartesian coordinate system (num)
  "fourfold.Rmd"      ## fourfold table (num)
))

## download expderiv* files

## switch back to the original folder
setwd("..")


## One-for-all ----------------------------------------------------------------------

demo_exam <- c("swisscapital.Rmd", "deriv.Rmd")
exams2html(demo_exam)
exams2pdf(demo_exam)
exams2pandoc(demo_exam)


## E-Learning (Moodle, Canvas, ARSnova, ...) ----------------------------------------

## Moodle
moodle_exam <- c("conferences.Rmd", "deriv.Rmd", "ttest.Rmd", "boxplots.Rmd",
  "function.Rnw", "lm.Rmd", "fourfold2.Rmd", "confint3.Rmd")

set.seed(2019-07-09)
exams2moodle(moodle_exam, n = 30, name = "useR-2019",
  dir = "output", edir = "exercises")


## Canvas
set.seed(2019-07-09)
exams2canvas(moodle_exam[1:5], n = 3, name = "useR-2019",
  dir = "output", edir = "exercises", duration = 15)


## OpenOLAT
set.seed(2019-07-09)
exams2openolat(moodle_exam[1:7], n = 3, name = "useR-2019-olat",
  dir = "output", edir = "exercises")


## ARSnova
choice_exam <- list(
  "conferences.Rmd",
  "deriv2.Rmd",
  c("ttest.Rmd", "boxplots.Rmd")
)

set.seed(2019-07-09)
exams2arsnova(unlist(choice_exam), n = 1, name = "useR-2019",
  dir = "output", edir = "exercises")


## Written exams (NOPS) -------------------------------------------------------------

set.seed(2019-07-09)
exams2nops(choice_exam, n = 35, name = "useR-2019",
  dir = "nops", edir = "exercises",
  reglength = 8, blank = 1, date = "2019-07-09",
  title = "Demo Exam", institution = "useR! 2019")

set.seed(2019-07-09)
exams2nops(choice_exam, n = 35, name = "useR-2019",
  dir = "nops2", edir = "exercises", duplex = FALSE,
  reglength = 8, blank = 0, date = "2019-07-09",
  title = "Demo Exam", institution = "useR! 2019")


