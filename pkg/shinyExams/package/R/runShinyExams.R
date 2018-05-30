#' @title Run shinyExams
#' 
#' @description 
#' Run a local instance of shinyExams.
#'
#' @param ... [\code{any}]\cr
#'   Additional arguments passed to shiny's
#'   \code{runApp()} function.
#' @examples
#' \dontrun{
#'   runShinyRexams()
#' }
#' @import shiny
#' @import shinythemes
#' @export
runShinyExams = function(...) {
  runApp(appDir = system.file("application", package = "shinyExams"), ...)
}
