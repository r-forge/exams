\name{xweave}
\alias{xweave}

\title{Wrapper Function for Weaving Either Rnw or Rmd Exercises}

\description{
  Simple wrapper function that either calls \code{\link[utils]{Sweave}}
  for Rnw exercises or \code{\link[knitr]{knit}} for Rmd exercises.
}

\usage{
  xweave(file, quiet = TRUE, encoding = NULL, envir = new.env(), png = FALSE, \dots)
}

\arguments{
  \item{file, quiet, encoding}{arguments passed to \code{\link[utils]{Sweave}}
    or \code{\link[knitr]{knit}}, respectively.}
  \item{envir}{argument passed to \code{\link[knitr]{knit}}.}
  \item{png, \dots}{arguments passed to \code{\link[utils]{Sweave}}.}
}

\details{
  Depending on whether \code{file} has an \code{.Rnw} or \code{.Rmd} suffix,
  either \code{\link[utils]{Sweave}} or \code{\link[knitr]{knit}} is called for
  weaving the file. If \code{png = TRUE} when calling \code{Sweave}, then
  the resulting includegraphics statements are supplemented with the \code{.png}
  suffix of the corresponding graphics.
}

\seealso{
  \code{\link[utils]{Sweave}},
  \code{\link[knitr]{knit}}
}

\keyword{utilities}
