#' @importFrom tools file_path_sans_ext
#' @rdname nops_eval
#' @export
nops_eval_write_uibk <- function(results = "nops_eval.csv", file = "exam_eval", dir = ".", language = "en", ...) {
  ## create .zip with individual .html report files
  exams::nops_eval_write(results = results, file = file, dir = dir, language = language, ...)

  ## additionally create .xlsx with UIBK-specific grades
  stopifnot(requireNamespace("openxlsx"))
  out_xlsx <- paste0(tools::file_path_sans_ext(basename(results)), ".xlsx")
  
  ## read results and unify column names
  results <- read.csv2(results, colClasses = "character")
  names(results)[1L:2L] <- c("Matrikelnr", "Name")
  if(!("SKZ" %in% names(results))) warning("the registration CSV file does not provide an 'SKZ' column with the Studienkennzahl")
  results <- results[, c("Matrikelnr", "Name", "SKZ", "mark")]
  names(results)[4L] <- "Note"

  ## UIBK-specific grades
  results$Note <- uibkmark(results$Note)

  ## write .xlsx with grades
  openxlsx::write.xlsx(results, file.path(dir, out_xlsx))
}
