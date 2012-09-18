\name{tex2image}
\alias{tex2image}

\title{Transforming LaTeX Code Using ImageMagick}

\description{
  Transformation of LaTeX code into an image by compiling
  to PDF and then transforming to PNG (by default) via
  ImageMagick.
}

\usage{
tex2image(tex, format = "png", width = 6, pt = 12, density = 350,
  dir = NULL, tdir = NULL, idir = NULL,
  width.border = 0L, col.border = "white", resize = 650, shave = 4,
  packages = c("amsmath", "amssymb", "amsfonts"),
  header, header2 = NULL, Sweave = TRUE, show = TRUE,
  name = "tex2image", \dots)
}

\arguments{
  \item{tex}{ still to do. }
  \item{format}{ still to do. }
  \item{width}{ still to do. }
  \item{pt}{ still to do. }
  \item{density}{ still to do. }
  \item{edir}{ still to do. }
  \item{tdir}{ still to do. }
  \item{idir}{ still to do. }
  \item{width.border}{ still to do. }
  \item{col.border}{ still to do. }
  \item{resize}{ still to do. }
  \item{shave}{ still to do. }
  \item{template}{ still to do. }
  \item{itemplate}{ still to do. }
  \item{show}{ still to do. }
  \item{bsname}{ still to do. }
  \item{\dots}{ still to do. }
}

\details{
  Still to do.
}

\value{
  Still to do.
}

\seealso{
  \code{\link[tools]{texi2dvi}}
}

\examples{
\dontrun{
tex <- c("This is \\\\textbf{bold} and this \\\\textit{italic}.",
  "Points on the unit circle: $x^2 + y^2 = 1$.")
tex2image(tex)
}
}

\keyword{utilities}
