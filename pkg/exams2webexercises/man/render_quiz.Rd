\name{render_quiz}
\alias{render_quiz}

\title{Setting Up and Running Simple webexercises Quizzes with R/exams Exercises}

\description{
The \code{render_quiz} function is a convenience tool that sets up a webexercises
tutorial embedding R/exams exercises in a (temporary) directory and directly
rendering it to an HTML page.
}

\usage{
render_quiz(file, name = "quiz", title = "R/exams quiz", show = TRUE,
  dir = NULL, edir = NULL, \dots,
  clean = TRUE, quiet = TRUE, envir = parent.frame())
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{name}{character. A name prefix for the resulting webexercises tutorial .Rmd file.}
  \item{title}{character. Title of the webexercises tutorial.}
  \item{show}{logical. Should the resulting tutorial be shown using
    \code{\link[utils]{browseURL}}?}
  \item{dir}{character. A path in which the tutorial file is created, by default
    chosen as a \code{\link{tempfile}}.}
  \item{edir}{character. The path of the directory (along with its
    sub-directories) in which the files in \code{file} are stored (see also below).
    If both \code{dir} and \code{edir} are \code{NULL} (the default), the \code{edir}
    is set to the current working directory.}
  \item{\dots}{arguments passed to \code{\link[exams2webexercises]{exams2webexercises}}.}
  \item{clean, quiet, envir}{arguments passed to \code{\link[rmarkdown]{render}}.}
}

\details{
  \code{render_quiz} is a convenience function that sets up a webexercises .Rmd
  document (in a temporary directory by default) and then calls \code{\link[rmarkdown]{render}}
  from \pkg{rmarkdown} to quickly try out the quiz interactively.
  
  For full customization it is recommended to set up a dedicated .Rmd file
  within which \code{\link[exams2webexercises]{exams2webexercises}} can be used to include
  R/exams exercises.
}

\value{
  Invisible character vector containing the path of the Rmd document and
  rendered HTML file, respectively.
}

\seealso{
  \code{\link[exams2webexercises]{exams2webexercises}},
  \code{\link[rmarkdown]{render}}
}

\examples{
\dontrun{
## quickly render a quiz based on a set of R/exams exercises
render_quiz(c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd"))
}
}
