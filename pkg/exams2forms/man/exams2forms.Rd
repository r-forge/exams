\name{exams2forms}
\alias{exams2forms}

\title{R/exams Interface for Forms in R/Markdown or Quarto Documents}

\description{
The \code{exams2forms} interface can be used within R/Markdown or Quarto
documents to dynamically insert individual questions or entire quizzes
based on R/exams exercise templates.
}

\usage{
exams2forms(file,
  write = TRUE, check = TRUE, box = TRUE, solution = TRUE, nchar = c(20, 40),
  schoice_display = "buttons", mchoice_display = "buttons",
  cloze_schoice_display = "dropdown", cloze_mchoice_display = mchoice_display,
  usecase = TRUE, usespace = TRUE, auto = FALSE,
  show_filename = !isFALSE(auto), show_tolerance = !isFALSE(auto),
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = NULL, obfuscate = TRUE, \dots)
}

\arguments{
  \item{file}{character. A specification of (a list of) exercise files.}
  \item{write}{logical. Should \code{\link{writeLines}} be called on the
    resulting Markdown/HTML text?}
  \item{check}{logical. Should a check for showing the answer be added to
    the exercise?}
  \item{box}{logical. Should a box be added around the \code{check} environment?}
  \item{solution}{logical or character. Should the solution environment
    of the R/exams exercises (if any) be displayed or not? Optionally,
    \code{solution} can also be a character with the title for the
    corresponding solution box.}
  \item{nchar}{numeric. Number of characters for numeric or string fields
    (\code{\link{forms_num}}, \code{\link{forms_string}}). If a vector of length 2 is provided
    it is used as the minimum and maximum number of characters, respectively.}
  \item{schoice_display, mchoice_display, cloze_schoice_display, cloze_mchoice_display}{character.
    Should the interaction for single-choice or multiple-choice forms be displayed
    with buttons (radio buttons or checkboxes, respectively) or with drop-down menus?
    The default is to use buttons for single-choice and multiple-choice
    items and for multiple-choice interactions within cloze items. Only
    for single-choice interactions within cloze items, the default is
    to use drop-down menus.}
  \item{usespace}{logical. Defaults to \code{TRUE}, only used for string questions.
      If \code{FALSE} spaces are ignored when evaluating correct answers.}
  \item{usecase}{logical. Defaults to \code{TRUE}, only used for string questions.
      If \code{FALSE} answers are evaluated ignoring uppercase/lowercase.}
  \item{auto}{logical or named list/vector. If set to \code{TRUE}, the form
    fields are prefilled, the check button is clicked, the solution button
    (if any) is clicked, and the order of the exercises (if \code{n > 1})
    is not shuffled. The options can also be controlled separately if
    \code{auto} is a named list/vector with (a subset of the) names
    \code{prefill}, \code{check}, \code{solution}, \code{noshuffle}.}
  \item{show_filename}{logical. Should the tolerance for numeric fields be
    shown before the field? Enabled by default only if the form is
    \code{auto}-filled/clicked.}
  \item{show_tolerance}{logical. Should the filename be displayed in the
    form? Enabled by default only if the form is \code{auto}-filled/clicked.}
  \item{n}{integer. The number of copies to be taken from \code{file}.}
  \item{nsamp}{integer. The number(s) of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. Standard argument for exams interfaces and hence
    included in the argument - but actually not used because \code{exams2forms}
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
  \item{converter}{passed on to \code{\link[exams]{make_exercise_transform_html}}
    (if \code{markup = "html"}).}
  \item{base64}{logical. Should supplementary files be embedded using Base 64 coding?
    Passed on to \code{\link[exams]{make_exercise_transform_pandoc}}.
    The default is to enable Base 64 when an HTML-type document is produced.}
  \item{\dots}{currently not used.}
  \item{obfuscate}{logical. Should the correct answer be obfuscated when
    embedded in the HTML source code? If \code{FALSE}, it is included as
    plain text.}
}

\details{
  \code{exams2forms} provides an interface for including exercises from
  R/exams (\url{https://www.R-exams.org/}) in R/Markdown or Quarto documents.
  This is done by rendering the exercises (either in .Rnw or .Rmd format)
  into Markdown which can then be included in .Rmd or .qmd
  documents. For a short introduction see
  \url{https://www.R-exams.org/tutorials/exams2forms/}.
  
  The function \code{\link[exams2forms]{exams2webquiz}}
  can set up a suitable .Rmd file and directly render it. This is intended mostly
  for quick interactive testing when authoring R/exams exercises.

  The idea and original code for inserting interactions into R/Markdown documents
  along with CSS and Javascript is adapted from the \pkg{webexercises} package,
  authored by Dale Barr and Lisa DeBruine.
}

\value{
  A list of exercises, each of which is a character
  vector with the Markdown code of the individual exercises.
}

\seealso{
  \code{\link[exams2forms]{exams2webquiz}},
  \code{\link[exams]{xexams}},
  \code{\link[exams]{xweave}}
}

\examples{
## example R/exams exercises: string, num, schoice, mchoice
exams2forms("function.Rmd")
exams2forms("deriv.Rmd")
exams2forms("swisscapital.Rmd")
exams2forms("switzerland.Rmd")

## usually exams2forms() is used within R/Markdown or Quarto tutorials,
## two example files are shipped within the package.
## - questions.Rmd: all questions set up indvidually
## - quiz.Rmd: an entire quiz set up in one go
lr <- system.file("forms", package = "exams2forms")
dir(lr)

## quiz.Rmd is rather short and straightforward
rmd <- file.path(lr, "quiz.Rmd")
writeLines(readLines(rmd))

\dontrun{
## either .Rmd file can be loaded in RStudio and rendered from there or
## using the command line, e.g.,
rmarkdown::render(rmd)
}
}
