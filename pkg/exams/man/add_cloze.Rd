\name{add_cloze}
\alias{add_cloze}
\alias{format_cloze}
\alias{initialize_cloze}

\title{Convenience Functions for Managing Cloze Meta-Information}

\description{
  Convenience functions for adding elements to the meta-information of
  a cloze exercise and for formatting the collected meta-information,
  respectively.
}

\usage{
  add_cloze(solution, single = NULL, tolerance = NULL, answertag = TRUE, \dots)
  format_cloze(field)
  initialize_cloze()
}
\arguments{
  \item{solution}{solution for an answer field in a cloze exercise.
    See also the details below.}
  \item{single}{logical. If \code{solution} is logical, does it specify
    a single-choice solution? By default \code{single} is set to \code{TRUE}
    if there is exactly one \code{TRUE} element in \code{solution}.}
  \item{tolerance}{numeric. Tolerance to be used in case of a numeric
    \code{solution}. By default selected via \code{\link[exams]{num_to_tol}}.}
  \item{answertag}{logical. Should a ANSWERi tag be returned for
    inclusion in the text?}
  \item{\dots}{arguments passed to \code{\link[exams]{fmt}} in case of a
    numeric \code{solution}.}
  \item{field}{character indicating whether the \code{"type"}, \code{"solution"},
    \code{"tolerance"}, or the \code{"answerlist"} for the cloze should
    be returned, formatted suitably.}
}

\details{
  The function \code{add_cloze(solution)} adds meta-information to an
  internal list in order to facilitate tracking of the elments in a cloze
  exercise.
  
  If \code{solution} is numeric, a \code{num} element is added along with
  the corresponding \code{tolerance}, by default selected via
  \code{num_to_tol(solution)}.
  
  If \code{solution} is a character, a \code{string} element is added.
  
  Additionally, \code{solution} can be a numeric or character vector or
  matrix in which case all elements are added (row-wise) to the meta-information
  and suitably-formatted answer tags are included as well
  (if \code{answertag = TRUE}, default).
  
  Finally, if \code{solution} is a named logical vector, an \code{mchoice} or
  \code{schoice} element is added, depending on whether \code{single = FALSE}
  or \code{TRUE}, respectively. If \code{solution} has only one \code{TRUE}
  element, \code{schoice} is used by default. The names of the \code{solution}
  elements

  Using \code{format_cloze(type)} the collected meta-information can be extracted,
  suitably formatted for inclusion an exercise. The \code{format_cloze("answerlist")}
  is intended to be included at the end of the question section which the other
  types (\code{"type"}, \code{"solution"}, and \code{"tolerance"}) are intended
  to be included in the meta-information tags.

  The function \code{initialize_cloze()} resets and initializes the cloze
  meta-information in the package's internal environment. Usually, this does
  not have be called by the user because it is called automatically prior to
  processing an exercise file. However, it is still provided for testing
  and illustration purposes as in the example below.
}

\seealso{\code{\link[exams]{answerlist}}}

\examples{

## initialize cloze meta-information (done automatically within xexams())
initialize_cloze()

## add num, string, and schoice elements
add_cloze(123.456789)
add_cloze("ABC")
add_cloze(c(
  "Zurich is the capital of Switzerland." = FALSE,
  "Italian is an official language in Switzerland." = TRUE,
  "Switzerland is part of the European Union." = FALSE
))

## add a numeric matrix
tab <- matrix(10^(1:4), ncol = 2, byrow = TRUE, dimnames = list(c("Top", "Bottom"), c("Left", "Right")))
add_cloze(tab)

## format collected meta-information
format_cloze("type")
format_cloze("solution")
format_cloze("tolerance")
writeLines(format_cloze("answerlist"))

## re-initialize cloze meta-information for cleanup
initialize_cloze()
}

\keyword{utilities}
