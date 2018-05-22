\name{olat_exercise}
\alias{olat_exercise}

\title{Extract (and Display) Exercises from OLAT Exams}

\description{
  Extract (and display) selected exercises from OLAT exams
  produced with \code{\link[c403]{exams2olat}} in order
  to see both question and solution.
}

\usage{
  olat_exercise(x, \dots, fixed = TRUE, show = TRUE, mathjax = TRUE)
}

\arguments{
  \item{x}{character or list. Either an OLAT exam list as produced
    by \code{\link[c403]{exams2olat}} or a character with the file
    path to an \code{.rds} file containing such an exam.}
  \item{\dots}{character. Patterns to be searched for in the
    question text of the exams in \code{x}.}
  \item{fixed}{logical. Should the search pattern(s) be matched
    as is?}
  \item{show}{logical. Should the exercise(s) found be shown
    in the browser?}
  \item{mathjax}{logical. Should the JavaScript from \url{http://www.MathJax.org/}
    be included for rendering mathematical formulas?}
}

\details{
  \code{olat_exercise} is a companion function for \code{\link[c403]{exams2olat}}.
  As OLAT has no option to look at the precise question of a particular
  student -- and more importantly the corresponding solution -- one strategy
  is to search for particular words, numbers, or other strings in the
  database of all questions from an OLAT exam.
  
  \code{olat_exercise} goes through all questions in the exam and selects
  those question(s) that match(es) the given search patterns. By default
  the question(s)/solution(s) are displayed in the browser and returned
  invisibly.
}

\value{
  A \code{list} containing either a single exercise or a list of such
  exercises (in case the search patterns do not yield a unique question).
}

\seealso{\code{\link[c403]{exams2olat}}}

\keyword{utilities}
