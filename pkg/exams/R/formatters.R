## convenience functions
mchoice2string <- function(x, single = FALSE) {
  if(single && !(sum(x) == 1L)) stop("single choice items must have exactly one correct solution")
  paste(as.numeric(x), collapse = "")
}

string2mchoice <- function(x, single = FALSE) {
  x <- strsplit(x, "")[[1]] == "1"
  if(single && !(sum(x) == 1L)) stop("single choice items must have exactly one correct solution")
  return(x)
}

mchoice2text <- function(x, markup = c("tex", "md"))
{
  switch(match.arg(markup),
    "tex" = ifelse(x, "\\\\textbf{True}", "\\\\textbf{False}"),
    "md" = ifelse(x, "**True**", "**False**"))
}

answerlist <- function(..., sep = ". ", markup = c("tex", "md"))
{
  if(match.arg(markup) == "tex") {
    writeLines(c(
      "\\begin{answerlist}",
      paste("  \\item", do.call("paste", list(..., sep = sep))),
      "\\end{answerlist}"
    ))
  } else {
    writeLines(c(
      "Answerlist",
      "----------",
      paste("*", do.call("paste", list(..., sep = sep)))
    ))
  }
}
