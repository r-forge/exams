\name{exams2learnr}
\alias{exams2learnr}

\title{R/exams Interface for learnr Tutorials}

\description{Interface to learnr.}

\usage{
exams2learnr(file, output = NULL,
  show_solution = TRUE, allow_retry = FALSE, random_answer_order = FALSE, 
  correct = "Correct!", incorrect = "Incorrect", try_again = incorrect,
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = TRUE, label = NULL,
  \dots)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{output}{character. Type of output: \code{"question"}, \code{"quiz"},
    \code{"list"}.}
  \item{show_solution}{logical. Should solution texts (if any) be shown
    after an attempt in a question (via \code{post_message}).}
  \item{allow_retry, random_answer_order, correct, incorrect, try_again}{arguments passed to question}
  \item{n, nsamp, dir, edir, tdir, sdir, verbose}{arguments passed to xexams}
  \item{quiet, resolution, width, height, svg}{arguments passed to xweave}
  \item{converter, base64}{arguments passed to HTML converter}
  \item{label}{internal label}
  \item{\dots}{arguments passed on to question}
}

\details{
  \code{exams2learnr} interface to learnr.
}

\value{
  \code{exams2learnr} returns a question/quiz/list.
}

\seealso{
  \code{\link[learnr]{question}},
  \code{\link[learnr]{quiz}},
  \code{\link[exams]{xexams}}
}

\examples{
\donttest{
if(require("rmarkdown")) rmarkdown::run("quiz.Rmd")
}
}
