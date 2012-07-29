\name{b64decode}
\alias{b64decode}

\title{Decode a file Formatted in Base64}

\description{
Decode a file formatted in base64.
}
\usage{
b64decode(input, output = tempfile())
}
\arguments{
  \item{input}{Input file.}
  \item{output}{Output file.}
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

\seealso{\code{\link{b64encode}} for the reverse operation}
\keyword{programming}

