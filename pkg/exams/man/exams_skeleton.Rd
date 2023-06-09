\name{exams_skeleton}
\alias{exams_skeleton}
\alias{exams.skeleton}

\title{Generate Skeleton for Exams Directory/Script}

\description{
  Generate a directory structure which contains \file{demo-*.R}
  scripts along with directories containing all available
  demonstation exercise \file{.Rnw} or \file{.Rmd} files and necessary
  template files (LaTeX, HTML, or XML).
}

\usage{
exams_skeleton(dir = ".",
  type = c("num", "schoice", "mchoice", "string", "cloze"),
  writer = c("exams2html", "exams2pdf", "exams2moodle",
    "exams2qti12", "exams2qti21", "exams2arsnova", "exams2nops"),
  markup = "markdown", absolute = FALSE, encoding = "UTF-8")
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
  \item{markup}{character vector indicating whether the example exercises
    use \code{"latex"} markup (.Rnw files) or \code{"markdown"} markup
    (.Rmd files).}
  \item{absolute}{logical. Should the paths in the \file{demo.R} script be
    absolute? The default is to use relative paths.}
  \item{encoding}{character, ignored. The encoding is always assumed to be UTF-8.}
}

\details{
  \code{exams_skeleton} (or equivalently \code{exams.skeleton}) creates a
  directory with several \file{demo-*.R} scripts illustrating the use of the various
  \code{exams2xyz} interfaces. Subdirectories with copies of all demonstration
  exercise \code{.Rnw} or \code{.Rmd} files and templates for different output formats
  (LaTeX, HTML, or XML) are also created.
  
  This should provide a starting point for users wishing to start their own
  collection of exercises with \pkg{exams}.
}

\value{
  \code{exams_skeleton} returns a list of character vectors with the demo scripts
  invisibly.
}

\seealso{
  \code{\link[exams]{exams2html}},
  \code{\link[exams]{exams2pdf}},
  \code{\link[exams]{exams2moodle}},
  \code{\link[exams]{exams2qti12}},
  \code{\link[exams]{exams2qti21}},
  \code{\link[exams]{exams2arsnova}},
  \code{\link[exams]{exams2nops}}
}

\examples{
## output directory (replace this with mydir <- "/path/to/your/directory")
dir.create(mydir <- tempfile())

## create exams skeleton with absolute paths in demo.R
exams_skeleton(dir = mydir, absolute = TRUE)

## look at created files
dir(mydir)
dir(mydir, recursive = TRUE)

## now open demo-all.R or any of the other demo-*.R scripts in your
## favorite R code editor and run the examples...
}

\keyword{utilities}
