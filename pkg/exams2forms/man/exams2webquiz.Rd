\name{exams2webquiz}
\alias{exams2webquiz}
\alias{webquiz}

\title{Setting Up and Running Simple Web Quizzes with R/exams Exercises}

\description{
The \code{exams2webquiz} function is a convenience tool that sets up an
R/Markdown document embedding R/exams exercises in a (temporary) directory
and directly rendering it to an HTML page.
}

\usage{
exams2webquiz(file, n = 1L, nsamp = NULL, dir = NULL,
  name = "webquiz", title = "R/exams quiz", browse = TRUE, edir = NULL,
  \dots, clean = TRUE, quiet = TRUE, envir = parent.frame())

webquiz(\dots)
}

\arguments{
  \item{file}{character. A specification of (a list of) exercise files.}
  \item{n}{integer. The number of copies to be taken from \code{file}.}
  \item{nsamp}{integer. The number(s) of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. A path in which the tutorial file is created, by default
    chosen as a \code{\link{tempfile}}.}
  \item{name}{character. A name prefix for the resulting .Rmd document.}
  \item{title}{character. Title of the quiz.}
  \item{browse}{logical. Should the resulting tutorial be displayed using
    \code{\link[utils]{browseURL}}?}
  \item{edir}{character. The path of the directory (along with its
    sub-directories) in which the files in \code{file} are stored.
    If both \code{dir} and \code{edir} are \code{NULL} (the default), the \code{edir}
    is set to the current working directory.}
  \item{\dots}{arguments passed to \code{\link[exams2forms]{exams2forms}}
    (in \code{exams2webquiz}) or \code{\link[rmarkdown]{html_document}}
    (in \code{webquiz}), respectively.}
  \item{clean, quiet, envir}{arguments passed to \code{\link[rmarkdown]{render}}.}
}

\details{
  \code{exams2webquiz} is a convenience function that sets up a .Rmd
  document (in a temporary directory by default) and then calls \code{\link[rmarkdown]{render}}
  from \pkg{rmarkdown} to quickly try out the quiz interactively.
  
  \code{webquiz} is a small wrapper function that creates an
  \code{\link[rmarkdown]{html_document}} but includes some custom CSS and
  Javascript for the quiz display and user interactions. The idea and
  original code is adapted from the \pkg{webexercises} package, authored
  by Dale Barr and Lisa DeBruine.
  
  For full customization it is recommended to set up a dedicated .Rmd file
  within which \code{\link[exams2forms]{exams2forms}} can be used to include
  R/exams exercises.
}

\value{
  Invisible character vector containing the path of the Rmd document and
  rendered HTML file, respectively.
}

\seealso{
  \code{\link[exams2forms]{exams2forms}},
  \code{\link[rmarkdown]{render}}
}

\examples{
\dontrun{
## quickly render a quiz based on a set of R/exams exercises
ex <- c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd", "lm2.Rmd")
exams2webquiz(ex)
}
}
