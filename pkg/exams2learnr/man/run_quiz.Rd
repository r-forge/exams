\name{run_quiz}
\alias{run_quiz}

\title{Setting Up and Running Simple learnr Quizzes with R/exams Exercises}

\description{
The \code{run_quiz} function is a convenience tool that sets up a learnr
tutorial embedding R/exams exercises in a temporary directory and directly
running it in a shiny app.
}

\usage{
run_quiz(file, name = "quiz", title = "R/exams quiz", dir = NULL, \dots,
  default_file = NULL, auto_reload = TRUE, shiny_args = NULL, render_args = NULL)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{name}{character. A name prefix for the resulting learnr tutorial .Rmd file.}
  \item{title}{character. Title of the learnr tutorial.}
  \item{dir}{character. A path in which the tutorial file is created, by default
    chosen as a \code{\link{tempfile}}.}
  \item{\dots}{arguments passed to \code{\link[exams2learnr]{exams2learnr}}.}
  \item{default_file, auto_reload, shiny_args, render_args}{arguments passed
    to \code{\link[rmarkdown]{run}}.}
}

\details{
  \code{run_quiz} is a convenience function that sets up a learnr .Rmd
  tutorial (in a temporary directory by default) with a \code{\link[learnr]{quiz}}
  and then calls \code{\link[rmarkdown]{run}} from \pkg{rmarkdown} to quickly try out the
  quiz interactively.
  
  For full customization it is recommended to set up a dedicated .Rmd file
  within which \code{\link[exams2learnr]{exams2learnr}} can be used to include
  R/exams exercises.
}

\value{
  Invisible \code{NULL} (from \code{link[rmarkdown]{run}}).
}

\seealso{
  \code{\link[exams2learnr]{exams2learnr}},
  \code{\link[rmarkdown]{run}}
}

\examples{
\dontrun{
## quickly run a quiz with two R/exams exercises
rmarkdown::run(c("capitals.Rmd", "fruit.Rmd"))
}
}
