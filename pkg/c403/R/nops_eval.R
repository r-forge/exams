uibkmark <- function(x, factor = TRUE) {
  rval <- factor(x, levels = 1L:5L, labels = c("SGT1", "GUT2", "BEF3", "GEN4", "NGD5"))
  if(!factor) {
    rval <- as.character(rval)
    rval[is.na(rval)] <- ""
  }
  return(rval)
}

nops_eval <- function(register = Sys.glob("*.csv"), solutions = Sys.glob("*.rds"), scans = Sys.glob("nops_scan_*.zip"),
  points = NULL, eval = exams_eval(partial = FALSE, negative = 0.25), mark = c(0.5, 0.6, 0.75, 0.85),
  dir = ".", results = "nops_eval", html = NULL, col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90), encoding = "latin1",
  language = "de", module = NULL, interactive = TRUE, string_scans = Sys.glob("nops_string_scan_*.zip"), string_points = seq(0, 1, 0.25))
{
  ## additional result file
  res_xls <- paste0(results, ".xlsx")

  ## call ported nops_eval() from "exams" package
  results <- exams::nops_eval(register = register, solutions = solutions, scans = scans,
    points = points, eval = eval, mark = mark, dir = dir, results = results, html = html, col = col, encoding = encoding,
    language = language, interactive = interactive, string_scans = string_scans, string_points = string_points)
  ## and then just add generation of UIBK-specific marks in an Excel spreadsheet
    
  ## read registration information
  register <- read.csv2(register, colClasses = "character")
  if(any(nchar(register$Matrikelnr) < 7L)) {
    register$Matrikelnr <- gsub(" ", "0", format(as.numeric(register$Matrikelnr)), fixed = TRUE)
  }
  rownames(register) <- register$Matrikelnr

  ## try to write xlsx with marks (including module marks if desired)
  if(!identical(mark, FALSE)) {
    register <- register[results$Matrikelnr, ]
    register$GP <- results$mark
    if(is.null(module)) module <- ("LV" %in% names(register))
    if(isTRUE(module)) module <- c(0.5, 0.5)
    if(!identical(module, FALSE) & ("LV" %in% names(register))) {
      module <- module/sum(module)
      register$Modul <- round2(module[1] * as.numeric(register$GP) + module[2] * as.numeric(register$LV))
      register$LV <- uibkmark(register$LV, factor = FALSE)
      register$Modul <- uibkmark(register$Modul, factor = FALSE)
      register$Modul[register$LV == ""] <- ""
      register$Modul[as.numeric(register$GP) > 4] <- "NGD5"
    } else {
      if(!identical(module, FALSE)) warning("'register' does not provide 'LV' marks")
    }
    register$GP <- uibkmark(register$GP, factor = FALSE)
    ## omit columns that are not needed anymore
    register$Account <- register$Passwort <- register$Sitzplatz <- register$Wiederholung <- NULL    
    if(requireNamespace("xlsx")) {
      write_eval <- function(data) xlsx::write.xlsx(data, file = res_xls, row.names = FALSE)
    } else if(requireNamespace("openxlsx")) {
      write_eval <- function(data) {
        wb <- openxlsx::createWorkbook("")
        openxlsx::addWorksheet(wb, "Sheet1")
        openxlsx::writeData(wb, 1, data)
        openxlsx::saveWorkbook(wb, res_xls)      
      }
    } else {
      warning("packages 'openxlsx' or 'xlsx' not available, the .xlsx file is actually a .csv")
      write_eval <- function(data) write.table(data, file = res_xls, row.names = FALSE, quote = FALSE, sep = ";")
    }
    write_eval(register)
  }

  invisible(results)
}