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
#'   runShinyExams()
#' }
#' @import shiny
#' @import shinythemes
#' @export
runShinyExams = function(...) {
  appDir = system.file("shinyExams", package = "shinyExams")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `shinyExams`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal")
}
