\name{exams2kahoot}
\alias{exams2kahoot}

\title{Generation of Excel Sheets with Quiz Questions for Kahoot!}

\description{
  Interface for generating Excel sheets with plain-text quiz questions
  for the Kahoot! game-based learning platform.
}

\usage{
exams2kahoot(file, n = 1L, dir = ".", name = "kahootquiz",
  quiet = TRUE, time = NULL, \dots)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{n}{integer. The number of copies to be compiled from \code{file}.}
  \item{dir}{character. The default is the current working directory.}
  \item{name}{character. A name prefix for resulting Excel sheets.}
  \item{quiet}{logical. Should output be suppressed when calling \code{\link[exams]{xweave}}?}
  \item{time}{numeric. Time limit (in seconds) allowed for answering the question
    in Kahoot!, must be one of 5, 10, 20, 30, 60, 90, 120, 240. If other numeric
    inputs are made, they are forced to the nearest admissable specification.
    Default: 60 seconds.}
  \item{\dots}{arguments passed on to \code{\link[exams]{xexams}}.}
}

\details{
  \code{exams2kahoot} generates Excel sheets, requiring \code{\link[openxlsx]{write.xlsx}}
  from the \pkg{openxlsx} package, that can be imported to the Kahoot!
  game-based learning platform. Only single-choice (schoice) and multiple-choice
  (mchoice) questions are allowed with plain questions and answers
  (using conversion via \code{\link[rmarkdown]{pandoc_convert}}). Questions
  and answers must not exceed 120 and 75 characters, respectively.
}

\value{
  A list of exams as generated by \code{\link[exams]{xexams}} is
  returned invisibly.
}

\examples{
\dontrun{
## create an .xlsx file for Kahoot! (requiring openxslx) based
## on three simple text-based single-choice and multiple-choice questions
exams2kahoot(c("capitals", "swisscapital", "switzerland"))
}
}

\keyword{utilities}
