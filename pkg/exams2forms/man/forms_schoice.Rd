\name{forms_schoice}
\alias{forms_schoice}
\alias{forms_mchoice}
\alias{forms_string}
\alias{forms_num}

\title{Create Interaction Forms for Different Exercise Types}

\description{
Helper functions for \code{\link{exams2forms}} to create the interaction
forms for different R/exams exercise types: single-choice (\code{schoice}),
multiple-choice (\code{mchoice}), text (\code{string}), or numeric
(\code{num}).
}

\usage{
forms_schoice(answerlist, solution, display = c("buttons", "dropdown"), ...)

forms_mchoice(answerlist, solution, display = c("buttons", "dropdown"), ...)

forms_string(answer, width = NULL, usecase = TRUE, usespace = FALSE, regex = FALSE, ...)

forms_num(answer, tol = 0, width = NULL, usespace = FALSE, regex = FALSE, ...)
}

\arguments{
  \item{answerlist}{character vector of answer alternatives for a
    single-choice or multiple-choice answer.}
  \item{solution}{logical vector indicating which alternatives in
    \code{answerlist} are correct. Must have the same length as
    \code{answerlist}. For \code{forms_schoice} exactly one element
    of \code{solution} must be \code{TRUE}.}
  \item{display}{character. Should the interaction for single-choice
    or multiple-choice forms be displayed with buttons (radio buttons or
    checkboxes, respectively) or with drop-down menus?}
  \item{answer}{character (for \code{forms_string}) or numeric (for
    \code{forms_num}). Correct answer(s).}
  \item{width}{numeric. Width of the input box in characters. Defaults
    to the length of \code{answer}.}
  \item{usecase}{logical. Should the evaluation of the input be
    case-sensitive?}
  \item{usespace}{logical. Should the evaluation of the input assess
    white spaces?}
  \item{regex}{logical. Should the evaluation of the input employ
    regular expressions?}
  \item{tol}{numeric. Tolerance for the evaluation of numeric input.}
  \item{\dots}{additional arguments (not intended to be used directly).}
}

\value{
A character string with the HTML or Markdown code for the interaction
forms to be embedded in R/Markdown or Quarto documents.
}

\examples{
## single-choice: What is the third letter of the latin alphabet?
forms_schoice(c("A", "B", "C", "D"), c(FALSE, FALSE, TRUE, FALSE))

## multiple-choice: Which of these numbers are prime?
forms_mchoice(c("1", "2", "3", "4"), c(FALSE, TRUE, TRUE, FALSE))

## string: Which base R function estimates linear regression models?
forms_string("lm", width = 10)

## numeric: A population of 1000 grows with a nominal rate of 10% per period.
## How big is the population after three periods?
forms_num(1000 * exp(0.1 * 3), tol = 0.1, width = 10)
}

\keyword{utilities}
