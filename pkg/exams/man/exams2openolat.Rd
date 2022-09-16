\name{exams2openolat}
\alias{exams2openolat}
\alias{openolat_config}

\title{Generation of Exams for OpenOlat}

\description{
  Automatic generation of exams in QTI 2.1 (or 1.2) with some
  tweaks optimized for OpenOlat.
}

\usage{
  exams2openolat(file, n = 1L, dir = ".", name = "olattest",
    qti = "2.1", config = TRUE, converter = "pandoc-mathjax", table = TRUE,
    maxattempts = 1, \dots)

  openolat_config(cancel = FALSE, suspend = FALSE, scoreprogress = FALSE,
    questionprogress = FALSE, maxscoreitem = FALSE, menu = TRUE,
    titles = TRUE, notes = FALSE, hidelms = TRUE, hidefeedbacks = FALSE,
    blockaftersuccess = FALSE, attempts = 1, anonym = FALSE,
    signature = FALSE, signaturemail = FALSE, resultsonfinish = TRUE,
    itemback = FALSE, itemresethard = FALSE, itemresetsoft = FALSE,
    itemskip = FALSE, passedtype = "none", metadata = FALSE,
    sectionsummary = TRUE, questionsummary = FALSE, usersolutions = TRUE,
    correctsolutions = TRUE, questions = FALSE)
}

\arguments{
  \item{file}{character. A specification of a (list of) exercise files.}
  \item{n}{integer. The number of copies to be compiled from \code{file}.}
  \item{dir}{character. The default is the current working directory.}
  \item{name}{character. A name prefix for resulting exercises and ZIP file.}
  \item{qti}{character indicating whether QTI \code{"1.2"} or \code{"2.1"}
    (default) should be generated.}
  \item{config}{logical or named list with arguments to be passed to
    function \code{openolat_config}, see below. When using the \code{config} argument
    a \code{XML} file named \code{QTI21PackageConfig.xml} will be written to the
    final directory.}
  \item{converter}{character passed on to \code{\link[exams]{make_exercise_transform_html}},
    indicating the type of converter from LaTeX/Markdown to HTML. Defaults
    to HTML with MathJax (and OpenOlat-specific fixups).}
  \item{table}{logical or character. Should a dedicated table class be
    used in the HTML for OpenOlat? For details see below.}
  \item{maxattempts}{integer. The maximum attempts for one question.
    Set to \code{0} for unlimited attempts. For a finite number of attempts this
    must be smaller than \code{100000}.}
  \item{\dots}{arguments passed on to \code{\link[exams]{exams2qti12}} or
    \code{\link[exams]{exams2qti21}}, respectively. See the corresponding
    manual pages for further important arguments such as \code{cutvalue},
    \code{solutionswitch}, \code{casesensitive}, \code{cloze_schoice_display}
    \code{navigation}, \code{shufflesections}, \code{eval}, \code{selection},
    among many others.}
  \item{cancel}{logical, whether the test may be canceled.}
  \item{suspend}{logical, whether the test may be suspended.}
  \item{scoreprogress}{logical, should score be shown when running the exam.}
  \item{questionprogress}{logical, should the number of solved questions be shown during the exam.}
  \item{maxscoreitem}{logical, should the maximum score of the item be shown.}
  \item{menu}{logical, should the menu be shown.}
  \item{titles}{logical, should titles be shown.}
  \item{notes}{logical, should notes be allowed.}
  \item{hidelms}{logical, hide the OLAT LMS.}
  \item{hidefeedbacks}{logical, should feedback ne displayed.}
  \item{blockaftersuccess}{logical, is the test blocked after successful completion.}
  \item{attempts}{integer, how many attempts are allowed for the test.}
  \item{anonym}{logical, can the test be taken as an anonymous user.}
  \item{signature}{logical, should signatures of users be allowed.}
  \item{signaturemail}{logical, similar as above.}
  \item{resultsonfinish}{logical, should results after finishing the test be displayed.}
  \item{itemback}{logical}
  \item{itemresethard}{logical}
  \item{itemresetsoft}{logical}
  \item{itemskip}{logical, can items be skipped.}
  \item{passedtype}{character, which passed type should be displayed after completion of the test.}
  \item{metadata}{logical}
  \item{sectionsummary}{logical, should section summaries be displayed after completion of the test.}
  \item{questionsummary}{logical, should question summaries be displayed after completion of the test.}
  \item{usersolutions}{logical, should the user solutions be displayed after completion of the test.}
  \item{correctsolutions}{logical, should the correct solutions be displayed after completion of the test.}
  \item{questions}{logical}
}

\details{
  \code{exams2openolat} is a convenience interface to \code{\link[exams]{exams2qti12}}
  and \code{\link[exams]{exams2qti21}} for generating either QTI 1.2 or 2.1
  (default) output with some small tweaks for OpenOlat. Specifically, the MathJax
  and table output from pandoc is post-processed as expected by OpenOlat. See the
  corresponding manual page for many more arguments that are supported by
  \code{exams2openolat}.
  
  Dedicated \code{table} classes currently include: Full-width tables with borders
  (\code{"b_grid"}, \code{"b_border"}) or without (\code{"b_full"}, \code{"b_borderless"}).
  Or regular tables without background color (\code{"b_middle"}) or with white grid
  and color background (\code{"b_gray"}, \code{"b_red"}, \code{"b_green"}, \code{"b_blue"},
  \code{"b_yellow"}). Setting \code{table = TRUE} corresponds to \code{table = "b_gray"}.

  Function \code{openolat_config} generates \code{XML} code that controls the overall options
  of the test. These options are not part of the QTI 2.1 standard but are specific to
  OpenOlat only. This is why they are not part of \code{exams2qti21} but provided in a
  separate wrapper function. As the XML config file is not part of the "official" OpenOlat
  interface, it may be subject to more changes in the future.
}

\value{
  \code{exams2openolat} returns a list of exams as generated by \code{\link[exams]{xexams}}.
}

\seealso{
  \code{\link[exams]{exams2qti12}},
  \code{\link[exams]{exams2qti21}}
}

\examples{
\donttest{
## load package and enforce par(ask = FALSE)
library("exams")
options(device.ask.default = FALSE)

## define an exams (= list of exercises)
myexam <- list(
  "boxplots",
  c("tstat", "ttest", "confint"),
  c("regression", "anova"),
  c("scatterplot", "boxhist"),
  "relfreq"
)

## output directory
dir.create(mydir <- tempfile())

## generate .zip with OpenOlat test in temporary directory
exams2openolat(myexam, n = 3, dir = mydir)
dir(mydir)
}
}

\keyword{utilities}
