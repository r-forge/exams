\name{b64img}
\alias{b64img}

\title{Encode a PNG File as a IMG Data URI}

\description{
Create HTML code to embed a PNG file into an HTML document. 
}

\details{
The following graph is embedded in the document using the \code{b64img} function.
	
\ifelse{html}{ 
	\Sexpr[results=rd, stage=build, echo=FALSE]{
	    
	library(htmltools)
	library(grDevices)
	library(graphics)
	library(stats)
	
	pngfile <- tempfile()
	png(pngfile, width = 600, height = 400)
	plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2)
	dev.off()
	b64img(pngfile, Rd = TRUE)
	
	}
}{ (only when rendered in HTML) }

}

\usage{
b64img(file, Rd = FALSE, alt = file)
}

\arguments{
  \item{file}{PNG file to translate into a data URI.}
  \item{Rd}{If \code{TRUE}, extra markup is added to facilitate inclusion of the image in an Rd file.}
  \item{alt}{Alternate text.}
}

\value{
The HTML code.
}

\references{
Wikipedia entry for data URI \url{http://en.wikipedia.org/wiki/Data_URI_scheme}.
}

\author{
Romain Francois
}

\note{
No checking on the file is performed, so it is up to the user to 
make sure the input file is indeed a PNG file.
}

\seealso{\link{b64encode} is used to encode the file}

\examples{
\dontrun{
pngfile <- tempfile()
png(pngfile, width = 600, height = 600)
plot(1:100, rnorm(100), pch = 21, bg = "red", cex = 2)
dev.off()
b64img(pngfile)
}
}

\keyword{programming}
