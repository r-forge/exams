\name{exams2qti12}
\alias{exams2qti12}
\alias{make_itembody_qti12}

\title{Generation of Exams in IMS QTI 1.2 Format}

\description{
  Automatic generation of exams in IMS QTI 1.2 format.
}

\usage{
  exams2qti12(file, n = 1L, nsamp = NULL, dir,
    name = NULL, quiet = TRUE, edir = NULL,
    tdir = NULL, sdir = NULL, resolution = 100,
    width = 4, height = 4, num = NULL, mchoice = NULL,
    schoice = mchoice, string = NULL, cloze = NULL,
    template = "qti12", duration = NULL,
    stitle = "Question", ititle = NULL, maxattempts = 1,
    feedbackswitch = FALSE, hintswitch = FALSE,
    solutionswitch = FALSE, cutvalue = NULL, \dots)

  make_itembody_qti12(rtiming = FALSE, shuffle = FALSE,
    rshuffle = shuffle, minnumber = NULL, maxnumber = NULL,
    defaultval = NULL, minvalue = NULL, maxvalue = NULL,
    cutvalue = NULL, enumerate = TRUE, digits = 2,
    tolerance = is.null(digits), maxchars = 12)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{n}{integer. The number of copies to be compiled from \code{file}.}
  \item{nsamp}{integer. The number of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. The output directory, this has to be set if
    \code{n} is greater than 1.}
  \item{name}{character. A name prefix for resulting exercises and ZIP file.}
  \item{quiet}{logical. Should output be suppressed when calling
    \code{\link[utils]{Sweave}}?}
  \item{edir}{character specifying the path of the directory in which
    the files in \code{file} are stored (see also below).}
  \item{tdir}{character specifying a temporary directory, by default
    this is chosen via \code{\link[base]{tempdir}}.}
  \item{sdir}{character specifying a directory for storing supplements, by
    default this is chosen via \code{\link[base]{tempdir}}.}
  \item{resolution, width, height}{numeric. Options for rendering PNG
    graphics passed to \code{\link[utils]{Sweave}}.}
  \item{num}{function or named list applied to numerical (i.e., type \code{num})
    questions. If \code{num} is a function, \code{num} will be used
    for generating the item body of the question, see function \code{make_itembody_qti12()}.
    If \code{num} is a named list, these arguments will be passed to function
    \code{make_itembody_qti12()}.}
  \item{mchoice, schoice, string, cloze}{function or named list applied to multiple choice, 
    single choice, string, and cloze questions (i.e., type \code{mchoice}, \code{schoice},
    \code{string}, and \code{cloze}), respectively. See argument \code{num} for more details.}
  \item{template}{character. The IMS QTI 1.2 template that should be used. Currently,
    the package provides \code{"qti12.xml"}.}
  \item{duration}{integer. Set the duration of the exam in minutes.}
  \item{stitle}{character. A title that should be used for the sections. May be a vector of
    length 1 to use the same title for each section, or a vector containing different section
    titles.}
  \item{ititle}{character. A title that should be used for the assessement items. May be a vector 
    of length 1 to use the same title for each item, or a vector containing different item
    titles. Note that the maximum of different item titles is the number of sections/questions
    that are used for the exam.}
  \item{maxattempts}{integer. The maximum attempts for one question, may also be set to
    \code{Inf}.}
  \item{feedbackswitch}{logical. Should the question/item feedbackswitch be enabled.}
  \item{hintswitch}{logical. Should the question/item hintswitch be enabled.}
  \item{solutionswitch}{logical. Should the question/item solutionswitch be enabled.}
  \item{cutvalue}{numeric. The cutvalue for which the exam is passed.}
  \item{rtiming, shuffle, rshuffle, minnumber, maxnumber, defaultval, minvalue,
    maxvalue}{arguments used for IMS QTI 1.2 item construction, for details see the XML 
    specification (see IMS Global Learning Consortium, Inc. 2012), especially Section 4.}
  \item{enumerate}{logical. Insert potential solutions in enumerated list?}
  \item{digits}{integer. How many digits should be used for \code{num} exercises?}
  \item{tolerance}{logical. If \code{digits = NULL}, type \code{num} questions will use a
    tolerance interval for checking if the supplied answer/number is correct.}
  \item{maxchars}{numeric. Lower bound for the number of characters in fill-in-blank
    fields. The actual number of characters is selected as the maximum number of
    characters of this value and the actual solution.}
  \item{\dots}{arguments passed on to \code{make_exercise_transform_html}.}
}

\details{
  Still to do.
}

\references{
  IMS Global Learning Consortium, Inc. (2012).
  \emph{IMS Question & Test Interoperability: ASI XML Binding Specification Final Specification Version 1.2}.
  \url{http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bindv1p2.html}
}

\value{
  \code{exams2qti12} returns a list of exams as generated by \code{\link[exams]{xexams}}.
  
  \code{make_itembody_qti12} returns a function that generates the XML code
  for the itembody tag in IMS QTI 1.2 format.
}

\seealso{
  \code{\link[exams]{xexams}},
  \code{\link[tth]{ttm}},
  \code{\link[tth]{tth}},
  \code{\link[exams]{tex2image}},
  \code{\link[exams]{make_exercise_transform_html}},
}

\examples{
## load package and enforce par(ask = FALSE)
library("exams")
options(device.ask.default = FALSE)

## define an exams (= list of exercises)
myexam <- list(
  "boxplots",
  c("tstat", "ttest", "confint"),
  c("regression", "anova"),
  "scatterplot",
  "relfreq"
)

## generate .zip with QTI 1.2 exam in temporary directory
mydir <- tempdir()
exams2qti12(myexam, n = 5, dir = mydir)
dir(mydir)
}

\keyword{utilities}
