\name{exams_skeleton}
\alias{exams_skeleton}
\alias{exams.skeleton}

\title{Generate Skeleton for Exams Directory/Script}

\description{
  Generate a directory structure which contains a \file{demo.R}
  script along with directories containing all available
  demonstation exercise \file{.Rnw} files and necessary
  template files (LaTeX, HTML, or XML).
}

\usage{
exams_skeleton(dir = ".",
  type = c("num", "schoice", "mchoice", "cloze", "string"),
  writer = c("exams2html", "exams2pdf", "exams2moodle", "exams2qti12"),
  absolute = FALSE)
}

\arguments{
  \item{dir}{character with path to directory. The default is the current
    working directory.}
  \item{type}{character vector indicating types of exercises that should be included
    in the \file{demo.R} script. By default an example for each type of
    exercise is included.}
  \item{writer}{character vector indicating the \code{exams2xyz} writer functions
    that should be included in the \file{demo.R} script. By default an example
    for each type of writer is included.}
  \item{absolute}{logical. Should the paths in the \file{demo.R} script be
    absolute? The default is to use relative paths.}
}

\details{
  \code{exams_skeleton} (or equivalently \code{exams.skeleton}) creates a
  directory with a \file{demo.R} script illustrating the use of the various
  \code{exams2xyz} interfaces. Subdirectories with copies of all demonstration
  exercise \code{.Rnw} files and templates for different output formats
  (LaTeX, HTML, or XML) are also created.
  
  This should provide a starting point for users wishing to start their own
  collection of exercises with \pkg{exams}.
}

\value{
  \code{exams_skeleton} returns a character vector with the \file{demo.R}
  code invisibly.
}

\seealso{
  \code{\link[exams]{exams2html}},
  \code{\link[exams]{exams2pdf}},
  \code{\link[exams]{exams2moodle}},
  \code{\link[exams]{exams2qti12}}
}

\examples{
## output directory (replace this with "/path/to/your/directory")
mydir <- tempdir()

## create exams skeleton with absolute paths in demo.R
exams_skeleton(dir = mydir, absolute = TRUE)

## look at created files
dir(mydir)
dir(mydir, recursive = TRUE)

## now open demo.R in your favorite R code editor
## and run the examples...
}

\keyword{utilities}
