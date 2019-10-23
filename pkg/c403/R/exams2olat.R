
#' Prepare exercises to be uploaded to OLAT
#'
#' Takes (a set of) exams questions (md/Rmd) files and creates
#' \code{n} randomized tests to be used in Olat.
#' Outputs an \code{rds} and \code{zip} file. The \code{rds} file
#' contains the questions/answers of the randomized tests and is
#' REQUIRED for evaluation (keep it; use a seed to make it
#' reproduceable), the zip archive file contains the files which
#' for the OLAT import.
#'
#' @param file list, of \code{md}/\code{Rmd} files to be used
#' @param n integer, number of randomized tests to be created (default \code{1L})
#' @param dir character, where to store the resulting file(s) (default \code{.})
#' @param name character name of the test/quiz
#' @param maxattempts integer, he maximum attempts for one question (must be
#'          smaller than \code{100000L}).
#' @param cutvalue numeric, the cutvalue at which the exam is passed
#' @param solutionswitch logical Should the question/item solutionswitch be
#'        enabled? In OLAT this means that the correct solution is
#'        shown after an incorrect solution was entered by an examinee
#'        (i.e., this is typically only useful if \code{maxattempts = 1}).
#' @param stitle character A title that should be used for the sections. May
#'        be a vector of length 1 to use the same title for each
#'        section, or a vector containing different section titles.
#' @param ititle character A title that should be used for the assessment
#'        items. May be a vector of length 1 to use the same title for
#'        each item, or a vector containing different item titles. Note
#'        that the maximum of different item titles is the number of
#'        sections/questions that are used for the exam.
#' @param adescription character  Description (of length 1) for the overall
#'        assessment (i.e., exam).
#' @param sdescription character Vector of descriptions for each section.
#' @param eval named list, specifies the settings for the evaluation policy,
#'        see function \code{\link[exams]{exams_eval}}
#' @param ... forwarded to \code{\link[exams]{exams2qui12}
#'
#' @export
exams2olat <- function(file, n = 1L, dir = ".", name = "olattest", maxattempts = 1L,
                       cutvalue = 1000, solutionswitch = FALSE, 
                       stitle = "Aufgabe", ititle = "Frage",
                       adescription = "Bitte bearbeiten Sie folgende Aufgaben.",
                       sdescription = "Bitte beantworten Sie folgende Frage.",
                       eval = list(partial = FALSE, negative = FALSE),
                       ...) {

  stopifnot(is.numeric(n) && length(n) == 1)
  stopifnot(is.numeric(maxattempts) && length(maxattempts) == 1)

  ## enable OLAT fixups
  olat <- getOption("olat_fix")
  options(olat_fix = TRUE)
  on.exit(options(olat_fix = olat))

  ## call exams2qti12
  rval <- exams::exams2qti12(file, n = n, dir = dir, name = name, maxattempts = maxattempts,
    cutvalue = cutvalue, solutionswitch = solutionswitch,
    stitle = stitle, ititle = ititle, adescription = adescription,
    sdescription = sdescription, eval = eval, ...)

  ## save exams list generated
  saveRDS(rval, file = file.path(dir, paste(name, ".rds", sep = "")))
  invisible(rval)
}
