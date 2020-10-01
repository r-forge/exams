\name{moodle2exams}
\alias{moodle2exams}

\title{Convert Moodle XML Quizzes to R/exams Exercises}

\description{
  Function to convert numerical, multichoice, shortanswer and essay type Moodle quiz exercises
  to R/exams exercises (currently in R/Markdown only).
}

\usage{
moodle2exams(x, markup = c("markdown", "latex"), dir = ".",
  exshuffle = TRUE, names = NULL)
}

\arguments{
  \item{x}{character, a path to a Moodle XML file. Optionally also the completely read, with 
    \code{\link[base]{readLines}}, XML code as character string.}
  \item{markup}{character, the markup language to convert to.}
  \item{dir}{character, the directory where the converted exercises should be saved.}
  \item{exshuffle}{meta-information tag used for multiple-choice items.}
  \item{names}{character, optional names that should be used for the exercises. If supplied,
    the names will also be written in the meta-information and overwrites all names
    that are supplied in the Moodle XML file.}
}

\details{
  The function should make it possible to convert an existing Moodle question pool to Markdown exams 
  in a relatively simple way. Exercises can be easily edited afterwards and can be randomized.

  The function takes a Moodle quiz and converts each exercise into a Markdown or LaTeX exams exercise.
  The HTML answers and questions are converted using pandoc. Note that conversion
  needs to be checked by the user, because it can naturally happen that certain sections are not
  as needed. Currently only numerical, multichoice, shortanswer and essay type Moodle quiz exercises
  are converted.

  However, the function can also convert cloze type exercises, but the resulting
  meta-information needed by exams will be incorrect, therefore the function gives a warning
  when converting cloze exercises.
}

\value{
  A list. Each list entry is one exercise saved as character string and can be saved using
  \code{\link[base]{writeLines}}. If a \code{dir} is specified, each exercise will be save here.
}

\seealso{\code{\link{exams2moodle}}}

\examples{
if(require("xml2")) {
## Path to saved Moodle quiz.
path_to_quiz <- file.path(find.package("exams"), "xml", "moodlequiz.xml")

## Open a temporary directory.
dir.create(tdir <- tempfile())

## Convert the quiz to exams Markdown.
ex_converted <- moodle2exams(path_to_quiz, dir = tdir)
print(dir(tdir))

## Each exercise is one list entry, can be saved
## using writeLines.
names(ex_converted)
writeLines(ex_converted[[1]])

## Remove files.
unlink(tdir)
}
}

\keyword{utilities}
