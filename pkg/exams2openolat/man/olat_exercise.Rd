\name{olat_exercise}
\alias{olat_exercise}

\title{Extract (and Display) Exercises from OpenOlat Exams}

\description{
  Extract (and display) selected exercises from OpenOlat exams
  produced with \code{\link{exams2openolat}} in order
  to see both question and solution.
}

\usage{
  olat_exercise(x, \dots, fixed = TRUE, show = TRUE, mathjax = TRUE)
}

\arguments{
  \item{x}{character or list. Either an OpenOlat exam list as produced
    by \code{\link{exams2openolat}} or a character with the file
    path to an \code{.rds} file containing such an exam.}
  \item{\dots}{character. Either a single numeric index of the exam to be selected.
    Or, alternatively, patterns to be searched for in the question text
    of the exams in \code{x}.}
  \item{fixed}{logical. Should the search pattern(s) be matched
    as is?}
  \item{show}{logical. Should the exercise(s) found be shown
    in the browser?}
  \item{mathjax}{logical. Should the JavaScript from \url{https://www.MathJax.org/}
    be included for rendering mathematical formulas?}
}

\details{
  \code{olat_exercise} is a companion function for \code{\link{exams2openolat}}.
  As OpenOlat has no option to look at the precise question of a particular
  student -- and more importantly the corresponding solution -- one strategy
  is to search for particular words, numbers, or other strings in the
  database of all questions from an OpenOlat exam.
  
  \code{olat_exercise} goes through all questions in the exam and selects
  those question(s) that match(es) the given search patterns. By default
  the question(s)/solution(s) are displayed in the browser and returned
  invisibly.
}

\value{
  A \code{list} containing either a single exercise or a list of such
  exercises (in case the search patterns do not yield a unique question).
}

\seealso{\code{\link{exams2openolat}}}

\keyword{utilities}
