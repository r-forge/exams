\name{exams2webexercises}
\alias{exams2webexercises}

\title{R/exams Interface for Documents with webexercises}

\description{
The \code{exams2webexercises} interface can be used within \pkg{webexercises}
documents (in R/Markdown format) to dynamically insert individual questions
or entire quizzes based on R/exams exercise templates.
}

\usage{
exams2webexercises(file,
  write = TRUE, check = TRUE, box = TRUE, markup = "markdown", solution = TRUE, nchar = c(20, 100),
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", \dots)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{write}{logical. Should \code{\link{writeLines}} be called on the
    resulting webexercise HTML/Markdown text?}
  \item{check}{logical. Should a check for showing the answer be added to
    the exercise?}
  \item{box}{logical. Should a box be added around the \code{check} environment
    (if set to \code{TRUE})?}
  \item{markup}{character. Should the R/exams exercises be rendered as
    \code{"markdown"} or \code{"html"}?}
  \item{solution}{logical or character. Should the solution environment
    of the R/exams exercises (if any) be displayed or not? Optionally,
    \code{solution} can also be a character with the title for the
    corresponding solution button (default: \code{"Correct solution"}).}
  \item{nchar}{numeric. Number of characters for fill-in-the-blank fields
    (\code{\link[webexercises]{fitb}}). If a vector of length 2 is provided
    it is used as the minimum and maximum number of characters, respectively.}
  \item{n}{integer. The number of copies to be taken from \code{file}.
    Typically this is \code{n = 1} because webexercises questions and quizzes
    do not support question banks with multiple variations.}
  \item{nsamp}{integer. The number(s) of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. Standard argument for exams interfaces and hence
    included in the argument - but actually not used because \code{exams2webexercises}
    does not write output files.}
  \item{edir}{character specifying the path of the directory (along with its
    sub-directories) in which the files in \code{file} are stored.}
  \item{tdir}{character specifying a temporary directory, by default
    this is chosen via \code{\link[base]{tempfile}}. Note that this
    is cleaned up (i.e., existing files are deleted) and only certain
    temporary files are preserved.}
  \item{sdir}{character specifying a directory for storing supplements, by
    default this is chosen via \code{\link[base]{tempfile}}.}
  \item{verbose}{logical. Should information on progress of exam generation
    be reported?}
  \item{quiet}{logical. Should output be suppressed when calling
    \code{\link[exams]{xweave}}?}
  \item{resolution, width, height}{numeric. Options for rendering PNG (or SVG)
    graphics passed to \code{\link[exams]{xweave}}.}
  \item{svg}{logical. Should graphics be rendered in SVG or PNG (default)?}
  \item{converter}{passed on to \code{make_exercise_transform_html}
    (if \code{markup = "html"}).}
  \item{\dots}{currently not used.}
}

\details{
  \code{exams2webexercises} provides an interface for including exercises from
  R/exams (\url{https://www.R-exams.org/}) in \pkg{webexercises} documents.
  This is done by rendering the exercises (either in .Rnw or .Rmd format)
  into HTML/Markdown which can then be included in \pkg{webexercises} .Rmd
  documents. The function \code{\link[exams2webexercises]{render_quiz}}
  can set up a suitable .Rmd file and directly render it. This is intended mostly
  for quick interactive testing when authoring R/exams exercises.

  If more than \code{n = 1} random replications are produced then they are 
  all included sequentially in the output - because webexercises currently does
  not provide a compound object that can capture a question bank with multiple
  replications.
}

\value{
  A list of exams, each of which is a list of exercises, each of which is a character
  vector with the HTML/Markdown code of the individual webexercises.
}

\seealso{
  \code{\link[webexercises]{fitb}},
  \code{\link[webexercises]{mcq}},
  \code{\link[webexercises]{longmcq}},
  \code{\link[webexercises]{torf}},
  \code{\link[exams]{xexams}}, \code{\link[exams]{xweave}},
  \code{\link[exams2webexercises]{render_quiz}}
}

\examples{
## Example R/exams exercise:
## - function: "string" question, represented via fitb()
exams2webexercises("function.Rmd")

## Example R/exams exercises:
## - swisscapital: "schoice" question, represented as longmcq()
## - switzerland: "mchoice" question, represented as list of torf()
exams2webexercises("swisscapital.Rmd")
exams2webexercises("switzerland.Rmd")

## Usually exams2webexercises() is used within webexercises .Rmd tutorials,
## two example files are shipped within the package.
## - webexercises_questions.Rmd: all questions set up indvidually
## - webexercises_quiz.Rmd: an entire quiz set up in one go
lr <- system.file("webexercises", package = "exams2webexercises")
dir(lr)

## The quiz .Rmd file is rather short and straightforward.
rmd <- file.path(lr, "webexercises_quiz.Rmd")
writeLines(readLines(rmd))

\dontrun{
## Either .Rmd file can be loaded in RStudio and render from there or
## using the command line, e.g.,
rmarkdown::render(rmd)
}
}
