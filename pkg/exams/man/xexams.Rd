\name{xexams}
\alias{xexams}
\alias{exams_metainfo}
\alias{print.exams_metainfo}

\title{Extensible Generation of Exams}

\description{
  Extensible automatic generation of exams including
  multiple choice questions and arithmetic problems.
}

\usage{
  xexams(file, n = 1L, nsamp = NULL,
    driver = list(sweave = NULL, read = NULL, transform = NULL, write = NULL),
    dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
    points = NULL, seed = NULL, rds = FALSE, \dots)

  exams_metainfo(x, class = "exams_metainfo", tags = TRUE, factors = FALSE,
    \dots)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files,
    for details see below.}
  \item{n}{integer. The number of copies to be taken from \code{file}.}
  \item{nsamp}{integer. The number(s) of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{driver}{list with elements \code{sweave} (weaver function or list of arguments
    for the default \code{\link[exams]{xweave}}), \code{read} (function
    for reading exercise files, defaulting to \code{\link[exams]{read_exercise}}),
    \code{transform} (function to transform each exercise, by default
    no transformations are done), \code{write} (function to write exams
    to output files, by default nothing is written). For more details,
    see below.}
  \item{dir}{character. The output directory passed on to \code{driver$write}.}
  \item{edir}{character specifying the path of the directory (along with its
    sub-directories) in which the files in \code{file} are stored (see also below).}
  \item{tdir}{character specifying a temporary directory, by default
    this is chosen via \code{\link[base]{tempfile}}. Note that this
    is cleaned up (i.e., existing files are deleted) and only certain
    temporary files are preserved.}
  \item{sdir}{character specifying a directory for storing supplements, by
    default this is chosen via \code{\link[base]{tempfile}}.}
  \item{verbose}{logical. Should information on progress of exam generation
    be reported?}
  \item{points}{integer. How many points should be assigned to each exercise? Note that this
    argument overules any exercise points that are provided within the \code{expoints} tags
    of the exercise files (if any). The vector of points supplied should either have
    length 1 or the number of exercises in the exam.}
  \item{seed}{integer matrix or logical. Either \code{NULL} (default), logical, or a
    matrix of random seeds for each possible exercise to be set prior to calling
    \code{driver$sweave}. If \code{NULL} no random seeds are set. If a matrix,
    the number of rows must be \code{n} and the number of columns must
    correspond to \code{unlist(file)}. If \code{TRUE} a suitable matrix of seeds
    is sampled.}
  \item{rds}{logical or character indicating whether the list returned by
    \code{xexams} should also be saved as an RDS data file. If \code{rds = TRUE}
    the file name \code{"metainfo.rds"} is used. Alternatively, \code{rds} can
    also be a character file name to be used.}
  \item{x}{a list as returned by \code{xexams} (or one of the \code{exams2xyz} interfaces).}
  \item{class}{character. Should the meta-information be returned as a list of
    lists with class \code{"exams_metainfo"} or as a \code{"data.frame"}?}
  \item{tags}{logical. Should the \code{extags} entries be processed into separate
    columns if \code{class = "data.frame"}?}
  \item{factors}{logical. Should the character columns for \code{class = "data.frame"}
    be turned into factors?}
  \item{\dots}{currently not used.}
}

\details{
  \code{xexams} is meant to provide an extensible framework for generating exams
  based on exercises in R/LaTeX format (via \code{\link[utils]{Sweave}}) or
  R/Markdown format (via \code{\link[knitr]{knit}}) and rendering them
  into various output formats such as PDF, HTML, or XML (e.g., for Moodle or IMS QTI).
  \code{xexams} is typically not called by the user directly but is used as a common
  infrastructure for functions such as \code{\link[exams]{exams2pdf}}, \code{\link[exams]{exams2html}},
  \code{\link[exams]{exams2moodle}}, \code{\link[exams]{exams2qti12}}, or
  \code{\link[exams]{exams2lops}}.
  
  \code{xexams} generates exams from lists (or vectors) of Rnw/Rmd source files by:
  (1) running \code{driver$sweave} on each exercise (by default \code{\link[exams]{xweave}} is
    used, calling \code{\link[utils]{Sweave}} or \code{\link[knitr]{knit}}),
  (2) running \code{driver$read} on the resulting LaTeX/Markdown file which by default
    uses \code{\link[exams]{read_exercise}} to read question/solution texts plus
    metainformation and stores the result in a list,
  (3) running \code{driver$transform} on this list for possible transformations
    (e.g., from LaTeX to HTML),
  (4) running \code{driver$write} on the list of exercises within each exam.

  Each exercise in an exam is essentially a standalone source file
  that \code{xexams} knows (almost) nothing about, it just calls \code{driver$sweave}
  in each iteration and assumes that \code{driver$read} can read the resulting
  LaTeX or Markdown file into a list.
  
  The specification in \code{file} should be either of form \code{"foo.Rnw"}
  (or equivalently just \code{"foo"}) or \code{"foo.Rmd"}, where the file should
  either be in the local directory, the \code{edir} directory or in
  the \code{exercises} directory of the package. If \code{edir} is specified,
  the directory along with all its sub-directories is searched for the exercises
  in \code{file}. Also, \code{file} can either be a simple vector or a list of vectors.
  In the latter case, exercises are chosen randomly within each list element. For example,
  the specification \code{file = list(c("a", "b"), "xyz")} will result in an exam with two
  exercises: the first exercise is chosen randomly between \code{"a"} and
  \code{"b"} while \code{"xyz"} is always included as the second exercise.
}

\references{
Zeileis A, Umlauf N, Leisch F (2014).
  Flexible Generation of E-Learning Exams in R: Moodle Quizzes, OLAT Assessments, and Beyond.
  \emph{Journal of Statistical Software}, \bold{58}(1), 1--36.
  \doi{10.18637/jss.v058.i01}.
}

\value{
  A list of exams (of length \code{n}),
  each of which is a list of exercises (whose length depends on the length of \code{file} and \code{nsamp}),
  each of which is a list (whose length/contents depends on \code{driver$read}).

  When using the default reader, the resulting list can be simplified
  using \code{exams_metainfo}, returning the same (classed) structure
  as the older \code{\link[exams]{exams}} interface. It is recommended
  to use this to inspect whether the \sQuote{extype} and \sQuote{exsolution}
  (and corresponding tolerance, if any) are correctly specified.
}

\seealso{
  \code{\link[exams]{xweave}},
  \code{\link[exams]{exams2pdf}},
  \code{\link[exams]{exams2html}},
  \code{\link[exams]{exams2moodle}},
  \code{\link[exams]{exams2canvas}},
  \code{\link[exams]{exams2openolat}},
  \code{\link[exams]{exams2nops}}
}

\examples{
## define an exam with five exercises
myexam <- list(
  "boxplots.Rmd",
  c("tstat.Rmd", "ttest.Rmd", "confint.Rmd"),
  c("regression.Rmd", "anova.Rmd"),
  "scatterplot.Rmd",
  "relfreq.Rmd"
)

## run exams with default drivers (i.e., no transformations or writer)
x <- xexams(myexam, n = 2)
## x is a list of 2 exams,
## each of which contains 5 exercises,
## each of which contains LaTeX code for question(list) and solution(list),
## plus metainformation and potential supplements

## The first exercise in each exam is "boxplots.Rmd", a multiple choice question.
## Its general question text is
x[[1]][[1]]$question
## with a list of multiple choice questions given as
x[[1]][[1]]$questionlist
## the corresponding graphic is in supplementary file
x[[1]][[1]]$supplements

## The metainformation is a list read from the ex* items
x[[1]][[1]]$metainfo

## The metainformation can also be extracted/printed
exams_metainfo(x)
## customize printing: only exam 1 in blocks of up to 3 exercises
print(exams_metainfo(x), which = 1, block = 3)

## The metainformation can also be prepared as a data.frame
exams_metainfo(x, class = "data.frame")
}

\keyword{utilities}
