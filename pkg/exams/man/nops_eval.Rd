\name{nops_eval}
\alias{nops_eval}

\title{Evaluate NOPS Exams}

\description{
  Evaluate NOPS exams produced with \code{\link[exams]{exams2nops}},
  and scanned by \code{\link[exams]{nops_scan}}.
}

\usage{
  nops_eval(register = dir(pattern = "\\\\.csv$"), solutions = dir(pattern = "\\\\.rds$"),
    scans = dir(pattern = "^nops_scan_[[:digit:]]*\\\\.zip$"),
    points = NULL, eval = exams_eval(partial = TRUE, negative = FALSE, rule = "false2"),
    mark = c(0.5, 0.6, 0.75, 0.85), dir = ".", results = "nops_eval",
    html = NULL, col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90),
    encoding = "UTF-8", language = "en", interactive = TRUE,
    string_scans = dir(pattern = "^nops_string_scan_[[:digit:]]*\\\\.zip$"),
    string_points = seq(0, 1, 0.25))
}

\arguments{
  \item{register}{character. File name of a CSV file (semicolon-separated)
    of the registered students. Must contain columns \code{"registration"}
    (registration number), \code{"name"} (student name), \code{"id"} (some user name
    or other string unique for each student). The file name should not contain spaces,
    umlaut or other special characters (e.g., something like
    \code{"exam-2015-07-01.csv"} is recommended).}
  \item{solutions}{character. File name of the RDS exam file
    produced by \code{\link[exams]{exams2nops}}.}
  \item{scans}{character. File name of the ZIP file with scanning results
    (containing Daten.txt and PNG files) as produced by
    \code{\link[exams]{nops_scan}}.}
  \item{points}{numeric. Vector of points per exercise. By default read from
    \code{solutions}.}
  \item{eval}{list specification of evaluation policy as computed by
    \code{\link[exams]{exams_eval}}.}
  \item{mark}{logical or numeric. If \code{mark = FALSE}, no marks are computed.
    Otherwise \code{mark} needs to be a numeric vector with threshold values to
    compute marks. The thresholds can either be relative (all lower than 1)
    or absolute. In case results exactly matching a threshold, the better mark is used.}
  \item{dir}{character. File path to the output directory (the default being the
    current working directory).}
  \item{results}{character. Prefix for output files.}
  \item{html}{character. File name for individual HTML report files, by default
    the same as \code{register} with suffix \code{.html}.}
  \item{col}{character. Hex color codes used for exercises with
    negative, neutral, positive, full solution.}
  \item{encoding}{character. Encoding of \code{register}, e.g.,
    \code{"latin1"} or \code{"UTF-8"} (default).}
  \item{language}{character. Path to a DCF file with a language specification.
    Currently, \code{"en"} and \code{"de"} are shipped with the package.}
  \item{interactive}{logical. Should possible errors in the Daten.txt file
    by corrected interactively? Requires the \pkg{png} package for full
    interactivity.}
  \item{string_scans}{character. Optional file name of the ZIP file with scanning results
    of string exercise sheets (if any) containing Daten2.txt and PNG files as produced
    by \code{\link[exams]{nops_scan}}.}
  \item{string_points}{numeric. Vector of length 5 with points assigned
    to string results.}
}

\details{
  \code{nops_eval} is a companion function for \code{\link[exams]{exams2nops}}
  and \code{\link[exams]{nops_scan}}. It evaluates the scanned exams by computing
  the sums of the points achived and (if desired) maps them to marks. Furthermore
  a HTML report for each individual student is generated (e.g., for upload into
  a learning management system).
}

\value{
  A \code{data.frame} with the detailed exam results is returned invisibly.
  It is also written to a CSV file in the current directory, along with a ZIP
  file containing the HTML reports.
}

\seealso{\code{\link[exams]{exams2nops}}, \code{\link[exams]{nops_scan}}}

\keyword{utilities}
