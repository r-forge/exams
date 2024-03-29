% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vis_groups.R
\name{vis_groups}
\alias{vis_groups}
\title{Randomly Assign VIS Participants into Groups (as HTML Table)}
\usage{
vis_groups(x, nrow = 5L, ncol = 2L, ...)
}
\arguments{
\item{x}{character. Either a vector of names or a file name (csv or xls/xlsx from VIS)
from which the \code{Name} column can be extracted.}

\item{nrow, ncol}{numeric. Number of rows and columns into which the students should be assigned.}

\item{...}{additional arguments passed to \code{\link{read_vis}} or \code{\link[utils]{read.csv2}}.}
}
\value{
A character vector with the HTML code is returned invisibly.
}
\description{
Randomly assign a vector of names (typically obtained from a VIS registration)
into groups and display the result as an HTML table.
}
\keyword{utilities}
