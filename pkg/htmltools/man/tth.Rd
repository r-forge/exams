\name{tth}
\alias{tth}
\title{
R interface to the tth TeX to HTML converter.
}
\description{
Convert TeX or LaTeX markup to HTML. Works for snippets as well as
complete documents.
}
\usage{
tth(x, delblanks = TRUE)
}
\arguments{
  \item{x}{character vector of (La)TeX code.}
  \item{delblanks}{logical, delete blank or empty lines?}
}
\value{A character vector with HTML code.
}
\references{
  Ian H Hutchinson: The TtH TeX to HTML translator.
  \url{http://hutchinson.belmont.ma.us/tth/}
}
\examples{
tth(c("This is \\\\textbf{bold} and this \\\\textit{italic}.",
      "Points on the unit cirecle: $x^2+y^2=1$."))
}
\keyword{utilities}

