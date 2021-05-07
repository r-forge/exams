## Default strategy:
## ----------------
##
## num/string/schoice
## ------------------
##   |           
##   | correct? 
##   ---
##   | -> yes: 100%
##   | -> no: negative = FALSE
##
## mchoice
## -------
##   |
##   | correct? partial = TRUE
##   ---
##   | -> yes: * 1/c * 100%
##   | -> no: rule? default: 1/f * 100%
##   |        default: negative = FALSE
##   |
##   | correct? partial = FALSE
##   ---
##   | -> yes: max(sum, negative) * 100%
##   | -> no:  max(sum, minvalue)
##             default: negative = FALSE

tdir <- tempfile()
dir.create(tdir)

## QTI 2.1 checks:
## ---------------
##
## negative = FALSE
##
## 1. num: -> OK!
exams2openolat("tstat.Rnw", n = 1, dir = "~/misc", name = "tstat-teval")

## 2. string: -> OK!
exams2openolat("function.Rmd", n = 1, dir = "~/misc", name = "string-teval")

## 3. schoice: -> OK!
exams2openolat("Rlogo.Rmd", n = 1, dir = "~/misc", name = "schoice-teval")

## 4. mchoice: -> OK!
##    partial = TRUE, negative = FALSE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-01")

## 5. mchoice: -> OK!
##    partial = FALSE, negative = FALSE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-02",
  mchoice = list("eval" = list(partial = FALSE)))

## negative = TRUE

## 6. num: -> OK!
exams2openolat("tstat.Rnw", n = 1, dir = "~/misc", name = "tstat-teval-n",
  num = list("eval" = list(negative = TRUE)))

## 7. string: -> OK!
exams2openolat("function.Rmd", n = 1, dir = "~/misc", name = "string-teval-n",
  string = list("eval" = list(negative = TRUE)))

## 8. schoice: -> OK!
exams2openolat("Rlogo.Rmd", n = 1, dir = "~/misc", name = "schoice-teval-n",
  schoice = list("eval" = list(negative = TRUE)))

## 9. mchoice: -> OK!
##    partial = TRUE, negative = TRUE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-03",
  mchoice = list("eval" = list(negative = TRUE)))

