\name{exams2learnr}
\alias{exams2learnr}

\title{R/exams Interface for learnr Tutorials}

\description{
The \code{exams2learnr} interface can be used within \pkg{learnr}
tutorials (in R/Markdown format) to dynamically insert individual questions
or entire quizzes based on R/exams exercise templates.
}

\usage{
exams2learnr(file, output = NULL,
  show_solution = TRUE, allow_retry = FALSE, random_answer_order = FALSE, 
  correct = "Correct!", incorrect = "Incorrect", try_again = incorrect, caption = "Quiz",
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = TRUE, label = NULL,
  \dots)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{output}{character specifying the output. Can either be a single learnr
    \code{"question"}, a learnr \code{"quiz"} containing one or more questions,
    or a standard \code{"list"} of lists of learnr questions. Details are provided
    below.}
  \item{show_solution}{logical. Should solution texts (if any) be shown
    after an attempt in a question (via \code{post_message}).}
  \item{allow_retry}{logical. Should users be allowed to retry a question after
    answering it incorrectly?}
  \item{random_answer_order}{logical. Should answer options be shuffled randomly
    by learnr when running the quiz?}
  \item{correct}{character. Text to print for a correct answer.}
  \item{incorrect}{character. Text to print for an incorrect answer (when
    \code{allow_retry} is \code{FALSE}.}
  \item{try_again}{character. Text to print for an incorrect answer (when
    \code{allow_retry} is \code{TRUE}.}
  \item{caption}{character. Text to display at the start of the quiz
    (provided \code{output = "quiz"} is used).}
  \item{n}{integer. The number of copies to be taken from \code{file}.
    Typically this is \code{n = 1} because learnr questions and quizzes
    do not support question banks with multiple variations.}
  \item{nsamp}{integer. The number(s) of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. Standard argument for exams interfaces and hence
    included in the argument - but actually not used because \code{exams2learnr}
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
  \item{converter, base64}{arguments passed on to \code{make_exercise_transform_html}.
    Usually neither of the defaults should be modified.}
  \item{label}{character. Label to be used internally as the (prefix for the)
    question ID(s).}
  \item{\dots}{further arguments passed on to \code{\link[learnr]{question}}.}
}

\details{
  \code{exams2learnr} provides an interface for including exercises from
  R/exams (\url{https://www.R-exams.org/}) in \pkg{learnr} tutorials.
  This is done by rendering the exercises (either in .Rnw or .Rmd format)
  into HTML and embedding that into learnr \code{\link[learnr]{question}}
  objects. These can then be rendered by learnr shiny apps.

  Currently, \code{num}, \code{schoice} (single-choice), \code{mchoice}
  (multiple-choice), and \code{string} exercises from R/exams are supported.
  But \code{cloze} questions that combine several of these question types
  in a single exercise are not supported yet.
  
  The output format of \code{exams2learnr} is chosen automatically, by default.

  If it is applied just to a single \code{file} (and with just a single random
  replication) a single learnr \code{\link[learnr]{question}} is produced. This is useful
  if the learnr tutorial should include other text elements or different questions
  with different control options.
  
  If \code{exams2learnr} is applied to a vector or list of files (with just
  a single random replication), then an entire learnr \code{\link[learnr]{quiz}}
  is produced. This is useful when multiple questions should be set up with the
  same control options in one go.
  
  If more than \code{n = 1} random replications are produced then a standard list
  is returned - because learnr currently does not provide a compound object that can
  capture a question bank with multiple replications. The list has one element per
  random replication, each of which is a list of learnr \code{question} objects.

  The format of the return value can also be controlled by the \code{output}
  argument if the desired format is not selected automatically.

  The function \code{exams2learnr} is intended to be used within the code of
  learnr .Rmd tutorials. Additionally, the function \code{\link[exams2learnr]{run_quiz}}
  can set up a suitable .Rmd file and directly run it. This is intended mostly
  for quick interactive testing when authoring R/exams exercises.
}

\value{
  Depending on its arguments, \code{exams2learnr} either returns a single learnr
  \code{\link[learnr]{question}}, an entire learnr \code{\link[learnr]{quiz}}, or
  a list of learnr question lists. See above for more details and some illustrations
  in the examples below.
}

\seealso{
  \code{\link[learnr]{question}}, \code{\link[learnr]{quiz}},
  \code{\link[exams]{xexams}}, \code{\link[exams]{xweave}},
  \code{\link[exams2learnr]{run_quiz}}
}

\examples{
## Default outputs:
## - a single exercise yields a learnr tutorial_question
## - several exercises yields a learnr tutorial_quiz

## Example R/exams exercise:
## - function: "string" question, represented as "learnr_text"
qn <- exams2learnr("function.Rmd")
class(qn)
print(qn)

## Example R/exams exercises:
## - swisscapital: "schoice" question, represented as "learnr_radio"
## - switzerland: "mchoice" question, represented as "learnr_checkbox"
qz <- exams2learnr(c("swisscapital.Rmd", "switzerland.Rmd"))
class(qz)
print(qz)

## Usually exams2learnr() is used within learnr .Rmd tutorials,
## two example files are shipped within the package.
## - learnr_questions.Rmd: all questions set up indvidually
## - learnr_quiz.Rmd: an entire quiz set up in one go
lr <- system.file("learnr", package = "exams2learnr")
dir(lr)

## The quiz .Rmd file is rather short and straightforward.
rmd <- file.path(lr, "learnr_quiz.Rmd")
writeLines(readLines(rmd))

\dontrun{
## Either .Rmd file can be loaded in RStudio and run from there or
## using the command line, e.g.,
rmarkdown::run(rmd)
}
}
