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

mchoice2text <- function(x, markup = c("latex", "markdown"))
{
  switch(match.arg(markup),
    "latex" = ifelse(x, "\\\\textbf{True}", "\\\\textbf{False}"),
    "markdown" = ifelse(x, "**True**", "**False**"))
}

answerlist <- function(..., sep = ". ", markup = c("latex", "markdown"))
{
  if(match.arg(markup) == "latex") {
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

toLatex.matrix <- function(object, skip = FALSE, fix = getOption("olat_fix"), ...)
{
  ## workaround for OLAT's mis-layouting of matrices
  fix <- if(is.null(fix)) FALSE else !identical(fix, FALSE)
  collapse <- if(fix) " & \\\\phantom{aa} & " else " & "
  nc <- if(fix) ncol(object) * 2L - 1L else ncol(object)

  ## collapse matrix to LaTeX code lines
  tm <- fmt(object, 6L)
  tmp <- apply(tmp, 1L, paste, collapse = collapse)
  tmp <- paste(tmp, collapse = if(skip) " \\\\smallskip \\\\smallskip \\\\\\\\  " else " \\\\\\\\ ")
  tmp <- paste("\\\\left( \\\\begin{array}{",
    paste(rep("r", nc), collapse = ""), "} ",
    tmp,
    " \\\\end{array} \\\\right)", sep = "")
  return(tmp)
}

round2 <- function (x, digits = 0) 
  round(x + sign(x) * 1e-10, digits)

fmt <- function(x, digits = 2L, zeros = digits < 4L) {
  x <- round2(x, digits = digits)
  if(zeros) {
    format(x, nsmall = digits, scientific = FALSE, digits = 12)
  } else {
    format(x, scientific = FALSE, digits = 12)
  }
}

char_with_braces <- function(x) {
  rval <- paste(ifelse(x >= 0, "", "("), x, ifelse(x >= 0, "", ")"), sep = "")
  dim(rval) <- dim(x)
  return(rval)
}

num_to_tol <- function(x, reltol = 0.0002, min = 0.01, digits = 2)
  pmax(min, round(reltol * abs(x), digits = digits))
