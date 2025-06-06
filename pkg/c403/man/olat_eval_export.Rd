% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/olat_eval.R
\name{olat_eval_export}
\alias{olat_eval_export}
\title{Olat eval export}
\usage{
olat_eval_export(
  results,
  xexam,
  file = "olat_eval.zip",
  html = "Testergebnisse.html",
  col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90)
)
}
\arguments{
\item{results}{data.frame,  results from \code{\link[c403]{read_olat_results}}}

\item{xexam}{list the object loaded from the rds file which contains the
individual questions/answers. The length of the list corresponds to the
number of randomized tests, each list element contains N elements (N =
number of questions) with all the information required to generate the
output.}

\item{file}{character, name of the zip flie, the final archive file where to
store the exported html files}

\item{html}{character, name of the output files (html files)}

\item{col}{character vector of length \code{4L} with hex colors, default
is \code{hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90)}}
}
\value{
Return of the \code{zip()} call.
}
\description{
Takes the results from \code{\link[c403]{read_olat_results}} and the information
from the \code{rds} file with the individual questions/answers to generate a
zip archive file with individual test results (html file). This zip file
can be used to upload to OLAT.
}
