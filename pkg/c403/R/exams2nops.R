#' Deprecated: Generation of NOPS Exams (Uni Innsbruck)
#' 
#' Unexported legacy interface to \code{\link[exams]{exams2nops}} with different default
#' values as used at Uni Innsbruck. Instead it is recommended to use \code{\link[exams]{exams2nops}}
#' directly.
#' 
#' \code{exams2nops} is a convenience interface for
#' \code{\link[exams]{exams2nops}} with somewhat different defaults:
#' German titles/descriptions, Uni Innsbruck logo, replacement sheets enabled,
#' duplex printing enabled.
#' 
#' @param file character. A specification of a (list of) exercise files.
#' @param n integer. The number of copies to be compiled from \code{file}.
#' @param dir character. The default is either display on the screen or
#'        the current working directory.
#' @param name character. A name prefix for resulting exercises and RDS file.
#' @param language character. Path to a DCF file with a language specification.
#'        Currently, \code{"en"} and \code{"de"} are shipped with the \pkg{exams} package.
#' @param title character. Title of the exam, e.g., \code{"Statistische Datenanalyse"}.
#' @param course character. Course number, e.g., \code{"403001"}.
#' @param institution character. Name of the institution at which the exam is conducted.
#' @param logo character. Path to a logo image. If the logo is not found, it is simply omitted.
#' @param date character or \code{"Date"} object specifying the date of the exam.
#' @param replacement logical. Should a replacement exam sheet be included?
#' @param intro character with LaTeX code for introduction text at the beginning of the exam.
#' @param blank integer. Number of blank pages to be added at the end.
#'        (Default is chosen to be half of the number of exercises.)
#' @param duplex logical. Should blank pages be added after the title page
#'        (for duplex printing)?
#' @param pages character. Path(s) to additional PDF pages to be included
#'        at the end of the exam.
#' @param usepackage character. Names of additional LaTeX packages to be included.
#' @param encoding character, passed to \code{\link[utils]{Sweave}}.
#' @param startid integer. Starting ID for the exam numbers (defaults to 1).
#' @param points integer. How many points should be assigned to each exercise? Note that this
#'        argument overules any exercise points that are provided within the \code{expoints} tags
#'        of the exercise files (if any). The vector of points supplied should either have
#'        length 1 or the number of exercises in the exam.
#' @param showpoints logical. Should the PDF show the number of points associated with
#'        each exercise (if specified in the Rnw/Rmd exercise or in \code{points})?
#' @param reglength integer. Number of digits in the registration ID. The
#'        default is 8 and it can be increased up to 10.
#' @param ... arguments passed on to \code{\link[exams]{exams2pdf}}.
#' 
#' @return A list of exams as generated by \code{\link[exams]{xexams}} is returned
#' invisibly.
#' 
#' @examples
#' ## load package and enforce par(ask = FALSE)
#' library("exams")
#' options(device.ask.default = FALSE)
#' 
#' ## define an exams (= list of exercises)
#' myexam <- list(
#'   "boxplots",
#'   c("tstat", "ttest", "confint"),
#'   c("regression", "anova"),
#'   c("scatterplot", "boxhist"),
#'   "relfreq"
#' )
#' 
#' if(interactive()) {
#'   ## compile a single random exam (displayed on screen)
#'   exams2nops(c("tstat2", "anova", "boxplots"))
#' }
#' 
#' @seealso nops_eval nops_register
#' @aliases exams2nops
#' @keywords utilities
exams2nops <- function(file, n = 1L, dir = NULL, name = NULL,
       language = "de", title = "Klausur", course = "",
       institution = "Universit\\\"at Innsbruck",
       logo = "uibk-logo-bw.png", date = Sys.Date(),
       replacement = TRUE, intro = NULL, blank = NULL,
       duplex = TRUE, pages = NULL, usepackage = NULL,
       encoding = "", startid = 1L, points = NULL,
       showpoints = FALSE, reglength = 8L, ...) {

  if(is.null(blank) && duplex && !is.null(pages)) {
    blank <- c(1L, ceiling(length(file)/2L))
  }

  ## Calling exams2nops from the exams package ...
  exams::exams2nops(file = file, n = n, dir = dir, name = name,
                    language = language, title = title, course = course,
                    institution = institution, logo = logo, date = date,
                    replacement = replacement, intro = intro, blank = blank,
                    duplex = duplex, pages = pages, usepackage = usepackage, encoding = encoding,
                    startid = startid, points = points, showpoints = showpoints,
                    reglength = reglength, ...)
}
