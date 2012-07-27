\name{b64encode}
\alias{b64encode}

\title{Encode a File in Base64 Format}

\description{
Encode a file in base64 format.
}

\usage{
b64encode(input, output = tempfile(), linesize = 72L)
}

\arguments{
  \item{input}{Input file.}
  \item{output}{Output file.}
  \item{linesize}{Number of characters per line in output file.}
}

\value{
None. The output file is written.
}

\references{
This is based on the base64 code available at \url{http://base64.sourceforge.net/}.

Base64 page at Wikipedia: \url{http://en.wikipedia.org/wiki/Base64}.
}

\author{
Romain Francois, based on code by Bob Trower.
}

\seealso{\link{decode} for the reverse operation}
\keyword{programming}
