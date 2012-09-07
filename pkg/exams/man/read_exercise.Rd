\name{read_exercise}
\alias{read_exercise}
\alias{extract_command}
\alias{extract_environment}
\alias{extract_items}
\alias{read_images}
\alias{read_metainfo}

\title{Reading LaTeX Exercise Files}

\description{
  Reading an exercise in LaTeX format (i.e.,
  after \code{\link[utils]{Sweave}} was run).
}

\usage{
  read_exercise(file)
}

\arguments{
  \item{file}{character. Name of the LaTeX file
    that should be read into R.}
}

\details{
  \code{read_exercise} extracts the LaTeX code from the question
  and solution environments of the exercise LaTeX file, extracting
  the answerlist environments separately (if any). Paths to supplementary
  files (such as graphics or data files) are stored and the 
  metainformation is extracted (including sanity checks).
}

\value{
  A list with elements
  \item{question}{a character vector with LaTeX code from the
    question environment (excluding the answerlist environment,
    if any).}
  \item{questionlist}{a character vector with LaTeX code from the
    answerlist environment within the question environment (if any).}
  \item{solution}{a character vector with LaTeX code from the
    solution environment (excluding the answerlist environment,
    if any).}
  \item{solutionlist}{a character vector with LaTeX code from the
    answerlist environment within the solution environment (if any).}
  \item{metainfo}{a list of metainformation options.}
  \item{supplements}{a character vector with paths to supplementary
    files such as graphics or data files (if any).}
}

\seealso{
  \code{\link[exams]{xexams}}
}

\examples{
## xexams() uses read_exercise() by default to read in
## each individual exercise, e.g., here for only a single
## exam with only a single exercise the result is:
xexams("tstat")[[1]][[1]]
}

\keyword{utilities}
