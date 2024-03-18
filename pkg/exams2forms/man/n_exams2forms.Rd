\name{n_exams2forms}

\title{R/exams Interface for Forms in R/Markdown or Quarto Documents}

\description{
This function serves as a wrapper for \code{exams2forms} function. It generates an HTML group and question tag around questions of the same type and allows users to generate multiple questions from the same type. It starts at a random question and will iterate over the questions from there to ensure the longest time possible to revisit this question. The JavaScript file "webex.js" will create the button with the correct handler.
}

\usage{
n_exams2forms(file, n = 1, ...)
}

\arguments{
  \item{file}{Character. A specification of a (list of) exercise files.}
  \item{n}{Integer. The number of copies to be taken from \code{file}.}
  \item{...}{Additional arguments to be passed to \code{exams2forms}.}
}

\value{
A character string with the HTML or Markdown code for the interaction forms to be embedded in R/Markdown or Quarto documents.
}

\examples{
## Generate 3 copies of forms from "swisscapital.Rmd"
n_exams2forms("swisscapital.Rmd", 3)
}
