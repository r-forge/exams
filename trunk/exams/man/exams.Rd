\name{exams}
\alias{exams}
\alias{print.exams_metainfo}

\title{Generation of Simple Exams}

\description{
  Sweave-based automated generation of exams including
  multiple choice questions and arithmetic problems.
}

\usage{
  exams(file, n = 1, dir = NULL, template = "solution",
    name = NULL, quiet = TRUE, header = list(date = Sys.Date()))
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files,
    for details see below.}
  \item{n}{integer. The number of copies to be compiled from \code{file}.}
  \item{dir}{character. The output directory, this has to be set if
    \code{n} is greater than 1 (or \code{template} is longer than 1).}
  \item{template}{character. A specification of a LaTeX template.}
  \item{name}{character. A name prefix for resulting exercises, by default
    chosen based on \code{template}.}
  \item{quiet}{logical. Should output be surpressed when calling
    \code{\link[utils]{Sweave}} and \code{\link[tools]{texi2dvi}}.}
  \item{header}{list. A list of further options to be passed to
    the LaTeX files.}
}

\details{
  \code{exams} generates exams from lists of \code{\link[utils]{Sweave}}
  source files by: (1) running \code{Sweave} on each exercise,
  (2) including the resulting LaTeX files in a \code{template},
  (3) running \code{\link[tools]{texi2dvi}} on the template, and
  (4) storing the resulting PDF file in an output \code{dir}
  (or displaying it interactively).
  
  Each exercise in an exam is essentially a standalone Sweave source file
  that \code{exams} knows (almost) nothing about, it just calls \code{Sweave}
  (\code{n} times). The only exception is some meta-information which
  is passed by means of three commands back to \code{exams}. The commands
  are \code{\extype} (which may be \code{mchoice} or \code{num}),
  \code{\exsolution} (e.g., \code{3.124} for a numeric solution and
  \code{10010} for a multiple choice solution) and \code{\exstring}
  (containing a human-readable string with the solution).
  
  The specification in \code{file} should be either of form \code{"foo"}
  or equivalently \code{"foo.Rnw"}, where the file \code{"foo.Rnw"} should
  either be in the local directory or in the \code{exercises} directory
  of the package. \code{file} can either be a simple vector or a list of
  vectors. In the latter case, exercises are chosen randomly within
  each list element. For example, the specification
  \code{file = list(c("a", "b"), "xyz")} will result in an exam with two
  exercises: the first exercise is chosen randomly between \code{"a"} and
  \code{"b"} while \code{"xyz"} is always included as the second exercise.

  The \code{template} is a (vector of) specification(s) of LaTeX template.
  It can be \code{"foo"} or equivalently \code{"foo.tex"} where \code{"foo.tex"}
  should either be in the local directory or in the \code{tex} directory
  of the package. It should specify where in the template the exercises
  are included, using the markup \code{\exinput{exercises}}. Additionally,
  it may contain \code{\exinput{questionnaire}} and \code{\exinput{header}}.
  \code{template} can also be a vector, then for each of the \code{n} runs
  several output files (one for each template) are created.
  
  The name prefix for each file is by default the base name of the 
  corresponding \code{template} but can also be changed via \code{name}.
  
  \code{exams} creates the PDF files and stores them in an output
  directory together with the solution meta information as \code{metainfo.rda}
  and \code{metainfo.csv} (see also below). If only a single PDF is created (currently
  the default), \code{dir} may be \code{NULL} and it is only displayed
  on the screen.
}

\value{
An object of class \code{"exams_metainfo"} is returned invisibly. It is a
list of length \code{n}, containing a list of meta informations for each
exercise:
  \item{mchoice}{logical. Is the exercise a multiple choice exercise?}
  \item{length}{integer. Length of solution.}
  \item{solution}{either a logical vector (for multiple choice) or numeric
    vector (for numeric exercises).}
  \item{string}{character. A human-readable version of the solution,
    possibly with brief explanations.}
}

\seealso{\code{\link[utils]{Sweave}},
  \code{\link[tools]{texi2dvi}},
  \code{\link[exams]{mchoice2string}}}

\examples{
## load package and enforce par(ask = FALSE)
library("exams")
options(par.ask.default = FALSE)

## define list of exercises
exam56 <- list(
  "ch03-boxplot",
  c("ch05-tstat1", "ch05-tstat2", "ch05-ttest1", "ch05-ttest2"),
  c("ch05-rsquared", "ch05-anova"),
  c("ch06-wilcoxon1", "ch06-wilcoxon2"),
  "ch06-boxplots"
)

## compile a single random exam (displayed on screen)
sol <- exams(exam56)
sol

## generate multiple exams (stored in output directory)
sol <- exams(exam56, n = 5, dir = tempfile(), template = c("exam", "solution"))
sol

## inspect solution for a particular exam
print(sol, 3)
}

\keyword{utilities}
