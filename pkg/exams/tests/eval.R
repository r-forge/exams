## num/string/schoice/mchoice+partial=FALSE
## ----------------------------------------
##   |
##   | correct?
##   ---
##   | -> yes: 100%
##   | -> no: negative (FALSE=0%, TRUE=100%, numeric * 100%)
##
## mchoice+partial=TRUE
## --------------------
##   |
##   | for each _checked_ item:
##   ---
##   | -> true: 1/t * 100%
##   | -> false: rule * 100% (default rule = 1/f)
##   |
##   | sum over all items:
##   ---
##   | max(sum, negative) * 100%
## 
## cloze
## -----
##   |
##   | sum over all elements (as above):
##   ---
##   | max(sum, minvalue)

tdir <- tempfile()
dir.create(tdir)

## QTI 2.1 checks:
## ---------------
##
## negative = FALSE
##
## 01. num: -> OK!
exams2openolat("tstat.Rnw", n = 1, dir = "~/misc", name = "tstat-teval")

## 02. string: -> OK!
exams2openolat("function.Rmd", n = 1, dir = "~/misc", name = "string-teval")

## 03. schoice: -> OK!
exams2openolat("Rlogo.Rmd", n = 1, dir = "~/misc", name = "schoice-teval")

## 04. mchoice: -> OK!
##     partial = TRUE, negative = FALSE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-01")

## 05. mchoice: -> OK!
##     partial = FALSE, negative = FALSE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-02",
  mchoice = list("eval" = list(partial = FALSE)))

## negative = TRUE

## 06. num: -> OK!
exams2openolat("tstat.Rnw", n = 1, dir = "~/misc", name = "tstat-teval-n",
  num = list("eval" = list(negative = TRUE)))

## 07. string: -> OK!
exams2openolat("function.Rmd", n = 1, dir = "~/misc", name = "string-teval-n",
  string = list("eval" = list(negative = TRUE)))

## 08. schoice: -> OK!
exams2openolat("Rlogo.Rmd", n = 1, dir = "~/misc", name = "schoice-teval-n",
  schoice = list("eval" = list(negative = TRUE)))

## 09. mchoice: -> OK!
##     partial = TRUE, negative = TRUE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-03",
  mchoice = list("eval" = list(negative = TRUE)))

## 10. mchoice: -> OK!
##     partial = FALSE, negative = TRUE, rule = false2
exams2openolat("relfreq.Rmd", n = 1, dir = "~/misc", name = "mchoice-teval-04",
  mchoice = list("eval" = list(negative = TRUE, partial = FALSE)))

## cloze

## 11. cloze: -> OK
##     mchoice with no correct answer, num.
##     partial = TRUE, negative = FALSE
exams2openolat("numbers.Rnw", n = 1, dir = "~/misc", name = "cloze-teval-01",
  cloze = list("eval" = list(negative = FALSE, partial = TRUE)), points = 4,
  edir = "exams/tests")

## 12. cloze: -> OK
##     mchoice with no correct answer, num.
##     partial = TRUE, negative = TRUE, rule = "all"
exams2openolat("numbers.Rnw", n = 1, dir = "~/misc", name = "cloze-teval-01-n",
  cloze = list("eval" = list(negative = TRUE, partial = TRUE, rule = "all")), points = 4,
  edir = "exams/tests")

## 13. cloze. -> OK
##     all string.
##     partial = TRUE, negative = TRUE
exams2openolat("repro-fail.Rmd", n = 1, dir = "~/misc", name = "cloze-teval-02-n",
  cloze = list("eval" = list(negative = TRUE, partial = TRUE)), points = 4,
  edir = "exams/tests")

## 14. General eval test.
## 12. cloze: -> OK
##     mchoice with no correct answer, num.
##     partial = TRUE, negative = TRUE, rule = "all"
exams2openolat(c("numbers.Rnw", "boxplots.Rmd"), n = 1, dir = "~/misc", name = "cloze-teval-g",
  cloze = list("eval" = list(negative = TRUE, partial = TRUE, rule = "all")),
  mchoice = list("eval" = list(negative = FALSE)),
  points = 4)

