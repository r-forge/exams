\name{match_exams_call}
\alias{match_exams_call}

\title{Query Last xexams/exams2xyz Call}

\description{
  Query the last call made to \code{xexams} (typically through
  some \code{exams2xyz} interface).
}

\usage{
match_exams_call(which = 1L, deparse = TRUE)
}

\arguments{
  \item{which}{integer. Specifies the hierarchy level
    at which the \code{exams2xyz} call should be extracted.}
  \item{deparse}{logical. Should only the deparsed function name
    be computed (or the entire call)?}
}

\details{
The function \code{match_exams_call} is useful for determining
within an exercise which \code{exams2xyz} interface is used in order
to behave slightly differently, e.g., for PDF vs. HTML output.
}

\examples{
if(interactive()) {
## call exams2nops
exams2nops("tstat2.Rnw")

## exams2nops called exams2pdf called xexams:
match_exams_call(which = 1)
match_exams_call(which = 2)
match_exams_call(which = 3)

## get full exams2nops call
match_exams_call(deparse = FALSE)

## get full sequence of calls
match_exams_call(which = NULL)
}
}

\keyword{utilities}
