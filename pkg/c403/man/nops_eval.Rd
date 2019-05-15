\name{nops_eval}
\alias{nops_eval}
\alias{nops_register}
\alias{nops_itemresp}
\alias{nops_zip2tab}

\title{Evaluate NOPS Exams}

\description{
  Evaluate NOPS exams produced with \code{\link[c403]{exams2nops}},
  and scanned by \code{\link[exams]{nops_scan}}.
}

\usage{
  nops_eval(register = Sys.glob("*.csv"), solutions = Sys.glob("*.rds"),
    scans = Sys.glob("nops_scan_*.zip"),
    points = NULL, eval = exams_eval(partial = FALSE, negative = 0.25),
    mark = c(0.5, 0.6, 0.75, 0.85), dir = ".", results = "nops_eval",
    html = NULL, col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90),
    encoding = "latin1", language = "de", module = NULL, interactive = TRUE,
    string_scans = Sys.glob("nops_string_scan_*.zip"), string_points = seq(0, 1, 0.25))

  nops_register(file = Sys.glob("*.xls*"), startid = 1L)

  nops_itemresp(eval = "nops_eval.csv", exam = Sys.glob("*.rds"),
    psychotools = NULL, labels = NULL, ...)

  nops_zip2tab(file = "nops_eval.zip")
}

\arguments{
  \item{register}{character. File name of a CSV file (semicolon-separated)
    of the registered students, e.g., as produced by \code{nops_register}
    based on the VIS registration lists. Must contain columns
    \code{"Matrikelnr"}, \code{"Name"}, \code{"Account"}
    (and \code{"LV"}, in case \code{module} marks should be computed).
    The file name should not contain spaces, umlaut or other special characters
    (something like \code{"GP-2014-02.csv"} is recommended).}
  \item{solutions}{character. File name of the RDS exercise file
    produced by \code{\link[c403]{exams2nops}}.}
  \item{scans}{character. File name of the ZIP file with scanning results
    (containing Daten.txt and PNG files) as produced by \code{\link[exams]{nops_scan}}
    (or the FSS).}
  \item{points}{numeric. Vector of points per exercise. By default read from
    \code{solutions}.}
  \item{eval}{For \code{nops_eval}: List specification of evaluation policy as computed by
    \code{\link[exams]{exams_eval}}. For \code{nops_itemresp}: File name of CSV output from
    \code{nops_eval}.}
  \item{mark}{logical or numeric. If \code{mark = FALSE}, no marks are computed.
    Otherwise \code{mark} needs to be a numeric vector with four threshold values to
    compute marks from 5 to 1. The thresholds can either be relative (all lower than 1)
    or absolute. In case results exactly matching a threshold, the better mark is used.}
  \item{dir}{character. File path to the output directory (the default being the
    current working directory).}
  \item{results}{character. Prefix for output files.}
  \item{html}{character. File name for individual HTML files, by default
    the same as \code{register} with suffix \code{.html}.}
  \item{col}{character. Hex color codes used for exercises with
    negative, neutral, positive, full solution.}
  \item{encoding}{character. Encoding of \code{register}, typically either
    \code{"latin1"} (default) or \code{"UTF-8"}.}
  \item{language}{character. Path to a DCF file with a language specification.
    Currently, \code{"en"} and \code{"de"} are shipped with the package.}
  \item{module}{logical or numeric. Should module marks (in addition to the
    exam marks) be computed? If this is numeric, this can be a vector of
    two ECTS weights for the written exam and seminar, respectively (by
    default equal weights of 0.5 and 0.5 are used). If \code{module} is not \code{FALSE},
    \code{register} needs to contain a column \code{"LV"} with the seminar marks.}
  \item{interactive}{logical. Should possible errors in the Daten.txt file
    by corrected interactively? Requires the \pkg{png} package for full
    interactivity.}
  \item{string_scans}{character. Optional file name of the ZIP file with scanning results
    of string exercise sheets (if any) containing Daten2.txt and PNG files as produced
    by \code{\link[exams]{nops_scan}}.}
  \item{string_points}{numeric. Vector of length 5 with points assigned
    to string results.}
  \item{file}{character with file name. For \code{nops_zip2tab}: Output ZIP file
    from \code{nops_eval}. For \code{nops_register}: Name of an XLS file from VIS.
    The file name should not contain spaces, umlaut or other special characters
    (something like \code{"GP-2014-02.xls"} is recommended).}
  \item{startid}{integer. Starting ID for the seats (defaults to 1).}
  \item{exam}{file name of RDS output from \code{exams2nops}.}
  \item{psychotools}{logical. Should \code{itemresp} from \pkg{psychotools} be
    used as the class for item response columns? By default, this is used if
    the \pkg{psychotools} package is available. If \code{FALSE}, matrices with
    dummy codings are used.}
  \item{labels}{function for extracting exercise labels from each \code{$metainfo}.
    By default the original file name \code{$metainfo$file} is used.}
  \item{\dots}{additional arguments (such as \code{colClasses}) passed to
    \code{read.csv2(eval, dec = ".", ...)}.}

  nops_itemresp(eval = "nops_eval.csv", exam = Sys.glob("*.rds"),
    psychotools = NULL, labels = NULL, ...)
}

\details{
  \code{nops_eval} is a companion function for \code{\link[c403]{exams2nops}}
  and \code{\link[exams]{nops_scan}}. It evaluates the scanned exams by computing
  the sums of the points achived and (if desired) mapping them to marks (and to
  module marks). Furthermore HTML reports for each individual student are
  generated for upload into OLAT.
  
  \code{nops_register} is another companion function for preprocessing the
  registration lists that are provided by VIS. The function assigns random
  seats for every student and saves the result in both CSV and XLSX format
  as well as a tab-separated text file with the seat numbers for import into OLAT.
  The underlying workhorse function is \code{\link[c403]{read_vis}}.
  
  \code{nops_itemresp} returns a data frame with several item response outcomes
  for each student: \code{solved} indicates whether or not an exercise was
  fully solved, \code{partial} whether or not it was at least partially solved.
  \code{points} gives the points achieved for each exercise. The corresponding
  \code{nsolved}, \code{npartial}, and \code{npoints} are the sums of these
  for each student. Moreover, \code{solved2}, \code{partial2}, and \code{points2}
  distinguish not only the exercises within the exam but also the actual
  source template within each exercise.
  
  \code{nops_zip2tab} takes the ZIP file from \code{nops_eval}, extracts all
  information from the students' individual HTML files but omits the scanned
  exam sheet, and stores everything as a tab-separated text file.
}

\value{
  A \code{data.frame} with the detailed exam results is returned invisibly.
  It is also written to a CSV file in the current directory, along with a ZIP
  file containing the HTML reports (for upload into OLAT), and an XLSX file
  (for importing the marks into VIS).
}

\seealso{\code{\link[c403]{exams2nops}}, \code{\link[exams]{nops_scan}}, \code{\link[c403]{read_vis}}}

\keyword{utilities}
