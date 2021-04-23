
#' @param true character, text for true results
#' @param false character, text for false results
#'
#' @rdname uibkmark
#' @export
mchoice2text <- function(x, true = "\\\\textbf{Richtig}", false = "\\\\textbf{Falsch}")
  ifelse(x, true, false)
