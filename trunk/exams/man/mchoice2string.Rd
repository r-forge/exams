\name{mchoice2string}
\alias{mchoice2string}
\alias{mchoice2summary}
\alias{mchoice2tex}
\alias{string2mchoice}
\alias{num2string}

\title{Convenience Functions for Exam Generation}

\description{
  A collection of convenience functions for exam generation
  that can be used for switching between suitable text/LaTeX/numeric
  representations of exam solutions.
}

\usage{
  mchoice2string(x)
  mchoice2summary(x)
  mchoice2tex(x)
  string2mchoice(x)
  num2string(x, digits = 3)
}
\arguments{
  \item{x}{an object, see below for examples}
  \item{digits}{integer. Number of digits for rounding.}
}

\details{
  These functions are a small set of convenience functions
  for facilitating work with solutions of exams. All have almost
  trivial definitions, see also examples below.
  
  They should be employed in the development phase of the package
  and might be replaced/improved in future versions.
}

\seealso{\code{\link[exams]{exams}}}

\examples{
  ## multiple choice answer
  mc <- c(TRUE, FALSE, TRUE, FALSE, FALSE)
  
  ## switching to string, human-readable summary, TeX representation
  mchoice2string(mc)
  mchoice2summary(mc)
  mchoice2tex(mc)
  
  ## reverse string encoding
  string2mchoice("10100")
  
  ## turn numeric into string
  num2string(1.87519)
  num2string(1.8)
}

\keyword{utilities}
