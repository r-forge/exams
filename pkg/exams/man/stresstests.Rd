\name{stresstest_exercise}
\alias{stresstest_exercise}
\alias{stresstest}

\title{
  Stress Testing Exercises
}

\description{
  In order to check the correct behavior of an exercise it is compiled several times.
  In each iteration the objects created by the exercise are collected and its values
  can be inspected.
}

\usage{
stresstest_exercise(file, n = 100, plot = TRUE,
  verbose = TRUE, seeds = NULL,
  stop_on_error = length(as.character(unlist(file))) < 2,
  ...)
}

\arguments{
  \item{file}{character. A specification of an exercise file. If multiple files
    should be tested, argument \code{file} can also be a vector, matrix or list of
    files. The latter case sets argument \code{plot = FALSE}.}
  \item{n}{integer. The number of replications.}
  \item{plot}{logical. Should the results be plotted.}
  \item{verbose}{logical. Should the seeds used for compiling the exercise
    be prompted on the console.}
  \item{seeds}{The seeds that should be used when compiling the exercise. The
    default is \code{seeds = 1:n}.}
  \item{stop_on_error}{logical. Should the function stop on error or return
    the the seed, the file name and the error message. Useful when testing
    a number of exercises.}
  \item{\dots}{Arguments passed to \code{\link{xexams}}.}
}

\details{
  In order to check the correct behavior of an exercise function \code{stresstest_exercise} runs
  \code{\link{xexams}} \code{n} times using different seeds. If an error occurs when compiling,
  the error can be reproduced by setting the seed that is prompted at the console and create
  the exercise again, e.g., with \code{\link{exams2html}}. This way errors can be detected
  systematically.

  All objects with length 1, which are created by the exercise, are collected in a data frame.
  These objects are assumed to be input parameters that control the output of the exercise. This
  can be used to detect certain input values that, e.g., lead to very long run times, or
  drive the number of correct answers in multiple choice exercises.

  For single and multiple choice type question the position(s) of the correct solution(s) is
  returned. For single choice questions that are created from a numeric version, e.g., using
  function \code{\link{num_to_schoice}} the answers are again converted to numeric and the ordering
  of the correct solution is reported. The ordering is sometimes heavily driven by some input
  parameters, e.g., the correct solution is always the largest or the smallest.

  The plotting function creates a summary about compiling run times, input parameters vs.
  runtimes, for single and multiple choice exercises summaries about the position of the correct
  solution(s), solution ordering vs. input parameters for single choice questions that are
  created, e.g., using function \code{\link{num_to_schoice}}.
}

\value{
  A list with the following objects:
  \item{seeds}{The seeds that where used.}
  \item{runtime}{Compiling times for each iteration.}
  \item{objects}{A data frame of length 1 objects that are created by the exercise.}
  \item{solution}{The numeric solution, availability is depending on the type of exercise.}
  \item{position}{A matrix indicating the position of correct solutions.}
  \item{ordering}{The ordering of the correct solution, only available for single choice exercises
    that are created, e.g., with function \code{\link{num_to_schoice}}.}
  \item{ntrue}{The number of correct answers in multiple choice type questions.}
}

\seealso{
  \code{\link{xexams}}, \code{\link{num_to_schoice}}
}

\examples{
\dontrun{## Stress testing.
t1 <- stresstest_exercise("tstat.Rnw", n = 100, plot = FALSE)
t2 <- stresstest_exercise("tstat2.Rnw", n = 100, plot = FALSE)

## Plotting.
plot(t1)
plot(t2)

## Multiple testing.
files <- list(
  "boxplots",
  c("tstat", "ttest", "confint"),
  c("regression", "anova"),
  "scatterplot",
  "relfreq"
)
t3 <- stresstest_exercise(files, n = 100)
}
}

\keyword{utilities}
