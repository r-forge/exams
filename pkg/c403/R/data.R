
#' Olat evaluation language data set
#'
#' Depending on the user profile language settings OLAT
#' exports test results (xlsx file) in differnet languages.
#' To make things easier in the \code{c403} package the
#' variable names are modified using this language
#' search-and-replace data set.
#'
#' @format A data frame with a language flag (given your
#' export was in German, only rows with \code{lang == "de"}
#' will be considered). The two columns \code{search} and
#' \code{replace} are used for \code{gsub()} (regular expression
#' string replacement).
#'
#' @author Reto Stauffer
"olat_eval_lang"
