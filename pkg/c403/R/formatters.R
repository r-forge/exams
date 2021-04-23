#' Auxiliary Formatting Functions
#'
#' Auxiliary functions for formatting elements of exams.
#'
#' @param x numeric (\code{uibkmark}) or logical (\code{mchoice2text}) vector.
#' @param factor logical. Should the result be a factor or a character?
#' @param true character. Text for true results.
#' @param false character. Text for false results.
#'
#' @details The function \code{uibkmark} maps the numbers 1 to 5 to the mark labels
#' SGT1, GUT2, etc. as used by UIBK.
#'
#' The function \code{mchoice2text} masks the exams function of the same name
#' in order to show German text.
#'
#' @examples
#' uibkmark(1:5)
#' mchoice2text(c(TRUE, FALSE))
#'
#' @aliases uibkmark mchoice2text
#' @keywords utilities
#'
#' @export
uibkmark <- function(x, factor = TRUE) {
  rval <- factor(x, levels = 1L:5L, labels = c("SGT1", "GUT2", "BEF3", "GEN4", "NGD5"))
  if(!factor) {
    rval <- as.character(rval)
    rval[is.na(rval)] <- ""
  }
  return(rval)
}


#' @rdname uibkmark
#' @export
mchoice2text <- function(x, true = "\\\\textbf{Richtig}", false = "\\\\textbf{Falsch}")
  ifelse(x, true, false)
