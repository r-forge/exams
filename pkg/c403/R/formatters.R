mchoice2text <- function(x, true = "\\\\textbf{Richtig}", false = "\\\\textbf{Falsch}")
  ifelse(x, true, false)
