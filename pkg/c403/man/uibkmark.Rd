\name{uibkmark}
\alias{uibkmark}
\alias{mchoice2text}

\title{Auxiliary Formatting Functions}

\description{
  Auxiliary functions for formatting elements of exams.
}

\usage{
uibkmark(x, factor = TRUE)

mchoice2text(x, true = "\\\\\\\\textbf{Richtig}", false = "\\\\\\\\textbf{Falsch}")
}

\arguments{
  \item{x}{numeric (\code{uibkmark}) or logical (\code{mchoice2text}) vector.}
  \item{factor}{logical. Should the result be a factor or a character?}
  \item{true, false}{character. German text for true and false results.}
}

\details{
  The function \code{uibkmark} maps the numbers 1 to 5 to the mark labels
  SGT1, GUT2, etc. as used by UIBK.

  The function \code{mchoice2text} masks the exams function of the same name
  in order to show German text.
}

\examples{
uibkmark(1:5)
mchoice2text(c(TRUE, FALSE))
}

\keyword{utilities}
