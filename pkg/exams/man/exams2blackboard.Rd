\name{exams2blackboard}
\alias{exams2blackboard}
\alias{make_itembody_blackboard}

\title{Generation of Exams in Blackboard Format}

\description{
  Automatic generation of exams in Blackboard format (which is
  partially based on QTI 1.2).
}

\usage{
  exams2blackboard(file, n = 1L, nsamp = NULL, dir = ".",
    name = NULL, quiet = TRUE, edir = NULL,
    tdir = NULL, sdir = NULL, verbose = FALSE,
    resolution = 100, width = 4, height = 4, encoding = "",
    num = NULL, mchoice = NULL,
    schoice = mchoice, string = NULL, cloze = NULL,
    template = "blackboard",
    adescription = "Please solve the following exercises.",
    atitle = "Please answer the following question.",
    maxattempts = 1, zip = TRUE, points = NULL,
    eval = list(partial = TRUE, negative = FALSE),
    \dots)

  make_itembody_blackboard(rtiming = FALSE, shuffle = FALSE,
    rshuffle = shuffle, minnumber = NULL, maxnumber = NULL,
    defaultval = NULL, minvalue = NULL, maxvalue = NULL,
    cutvalue = NULL, enumerate = TRUE, digits = NULL,
    tolerance = is.null(digits), maxchars = 12,
    eval = list(partial = TRUE, negative = FALSE),
    fix_num = TRUE)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{n}{integer. The number of copies to be compiled from \code{file}.}
  \item{nsamp}{integer. The number of exercise files sampled from each
    list element of \code{file}. Sampling without replacement is used
    if possible. (Only if some element of \code{nsamp} is larger than
    the length of the corresponding element in \code{file}, sampling
    with replacement is used.)}
  \item{dir}{character. The default is the current working directory.}
  \item{name}{character. A name prefix for resulting exercises and ZIP file.}
  \item{quiet}{logical. Should output be suppressed when calling
    \code{\link[utils]{Sweave}}?}
  \item{edir}{character specifying the path of the directory in which
    the files in \code{file} are stored (see also below).}
  \item{tdir}{character specifying a temporary directory, by default
    this is chosen via \code{\link[base]{tempdir}}. Note that this
    is cleaned up and potentially temporary files are deleted.}
  \item{sdir}{character specifying a directory for storing supplements, by
    default this is chosen via \code{\link[base]{tempdir}}.}
  \item{verbose}{logical. Should information on progress of exam generation
    be reported?}
  \item{resolution, width, height}{numeric. Options for rendering PNG
    graphics passed to \code{\link[utils]{Sweave}}.}
  \item{encoding}{character, passed to \code{\link[utils]{Sweave}}.}
  \item{num}{function or named list applied to numerical (i.e., type \code{num})
    questions. If \code{num} is a function, \code{num} will be used
    for generating the item body of the question, see function \code{make_itembody_blackboard()}.
    If \code{num} is a named list, these arguments will be passed to function
    \code{make_itembody_blackboard()}.}
  \item{mchoice, schoice, string, cloze}{function or named list applied to multiple choice, 
    single choice, string, and cloze questions (i.e., type \code{mchoice}, \code{schoice},
    \code{string}, and \code{cloze}), respectively. See argument \code{num} for more details.}
  \item{template}{character. The IMS QTI 1.2 or 2.1 template that should be used. Currently,
    the package provides \code{"blackboard.xml"}.}
  \item{adescription}{character. Description (of length 1) for the overall assessment (i.e., exam).}
  \item{atitle}{character. Tescriptions of the overall assessment.}
  \item{maxattempts}{integer. The maximum attempts for one question, may also be set to
    \code{Inf}.}
  \item{zip}{logical. Should the resulting XML file (plus supplements) be zipped?}
  \item{points}{integer. How many points should be assigned to each exercise? Note that this
    argument overules any exercise points that are provided within an \code{"\expoints{}"} tag
    in the \code{.Rnw} file. The vector of points supplied is expanded to the number of exercises in
    the exam.}
  \item{eval}{named list, specifies the settings for the evaluation policy, see function
    \code{\link{exams_eval}}.}
  \item{rtiming, shuffle, rshuffle, minnumber, maxnumber, defaultval, minvalue,
    maxvalue}{arguments used for IMS QTI 1.2 item construction, for details see the XML 
    specification (see IMS Global Learning Consortium, Inc. 2012), especially Section 4.}
  \item{cutvalue}{numeric. The cutvalue at which the exam is passed.}
  \item{enumerate}{logical. Insert potential solutions in enumerated list?}
  \item{digits}{integer. How many digits should be used for \code{num} exercises?}
  \item{tolerance}{logical. Should tolerance intervals be used for checking if the supplied
    \code{num} answer/number is correct? The default is to use tolerance intervals if \code{digits = NULL}.}
  \item{maxchars}{numeric. Lower bound for the number of characters in fill-in-blank
    fields. The actual number of characters is selected as the maximum number of
    characters of this value and the actual solution.}
  \item{fix_num}{logical. This is a special flag to enable/force the display of the
    correct solutions for numeric exercises/answers as well as to obtain results when archiving tests.
    Note that this is only a workaround.}
  \item{\dots}{arguments passed on to \code{make_exercise_transform_html}.}
}

\details{
  Blackboard employs an XML format that essentially uses the Question & Test Interoperability (QTI) 
  standard, version 1.2, see IMS Global Learning Consortium, Inc. (2012). However, as this deviates
  from the plain QTI 1.2 standard in several places, the \code{\link{exams2qti12}} cannot be used
  directly. Instead, \code{exams2blackboard} is an experimential new interfaces which has not been
  fully implmented/tested, yet, though.
}

\references{
IMS Global Learning Consortium, Inc. (2012).
\emph{IMS Question & Test Interoperability: ASI XML Binding Specification Final Specification Version 1.2}.
\url{http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bindv1p2.html}

Zeileis A, Umlauf N, Leisch F (2014).
  Flexible Generation of E-Learning Exams in R: Moodle Quizzes, OLAT Assessments, and Beyond.
  \emph{Journal of Statistical Software}, \bold{58}(1), 1--36.
  \url{http://www.jstatsoft.org/v58/i01/}.
}

\value{
  \code{exams2blackboard} returns a list of exams as generated by \code{\link[exams]{xexams}}.
  
  \code{make_itembody_blackboard} returns a function that generates the XML code
  for the itembody tag in Blackboard's version of the IMS QTI 1.2 format.
}

\seealso{
  \code{\link[exams]{exams2qti12}}
}

\examples{
## load package and enforce par(ask = FALSE)
library("exams")
options(device.ask.default = FALSE)

## define an exams (= list of exercises)
myexam <- list(
  "boxplots",
  "ttest",
  "anova",
  "scatterplot",
  "relfreq"
)

## output directory
mydir <- tempdir()

## generate .zip with Blackboard exam in temporary directory
exams2blackboard(myexam, n = 3, dir = mydir)
dir(mydir)
}

\keyword{utilities}
