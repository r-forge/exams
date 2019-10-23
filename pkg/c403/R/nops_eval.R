
#' Auxiliary Formatting Functions
#'
#' Auxiliary functions for formatting elements of exams.
#' \code{mchoice2text(x, true = "\\textbf{Richtig}", false = "\\textbf{Falsch}")}
#'
#' @param x numeric (\code{uibkmark}) or logical (\code{mchoice2text}) vector.
#' @param factor logical. Should the result be a factor or a character?
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
#' @aliases mchoice2text
#' @keywords utilities
#' @export
uibkmark <- function(x, factor = TRUE) {
  rval <- factor(x, levels = 1L:5L, labels = c("SGT1", "GUT2", "BEF3", "GEN4", "NGD5"))
  if(!factor) {
    rval <- as.character(rval)
    rval[is.na(rval)] <- ""
  }
  return(rval)
}


#' Evaluate NOPS Exams
#' 
#' Evaluate NOPS exams produced with \code{\link[c403]{exams2nops}},
#' and scanned by \code{\link[exams]{nops_scan}}.
#' 
#' @param register character. File name of a CSV file (semicolon-separated)
#'        of the registered students, e.g., as produced by \code{nops_register}
#'        based on the VIS registration lists. Must contain columns
#'        \code{"Matrikelnr"}, \code{"Name"}, \code{"Account"}
#'        (and \code{"LV"}, in case \code{module} marks should be computed).
#'        The file name should not contain spaces, umlaut or other special characters
#'        (something like \code{"GP-2014-02.csv"} is recommended).
#' @param solutions character. File name of the RDS exercise file
#'        produced by \code{\link[c403]{exams2nops}}.
#' @param scans character. File name of the ZIP file with scanning results
#'        (containing Daten.txt and PNG files) as produced by \code{\link[exams]{nops_scan}}
#'        (or the FSS).
#' @param points numeric. Vector of points per exercise. By default read from
#'        \code{solutions}.
#' @param eval list specification of evaluation policy as computed by
#'        \code{\link[exams]{exams_eval}}.
#' @param mark logical or numeric. If \code{mark = FALSE}, no marks are computed.
#'        Otherwise \code{mark} needs to be a numeric vector with four threshold values to
#'        compute marks from 5 to 1. The thresholds can either be relative (all lower than 1)
#'        or absolute. In case results exactly matching a threshold, the better mark is used.
#' @param dir character. File path to the output directory (the default being the
#'        current working directory).
#' @param results character. Prefix for output files.
#' @param html character. File name for individual HTML files, by default
#'        the same as \code{register} with suffix \code{.html}.
#' @param col character. Hex color codes used for exercises with
#'        negative, neutral, positive, full solution.
#' @param encoding character. Encoding of \code{register}, typically either
#'        \code{"latin1"} (default) or \code{"UTF-8"}.
#' @param language character. Path to a DCF file with a language specification.
#'        Currently, \code{"en"} and \code{"de"} are shipped with the package.
#' @param module logical or numeric. Should module marks (in addition to the
#'        exam marks) be computed? If this is numeric, this can be a vector of
#'        two ECTS weights for the written exam and seminar, respectively (by
#'        default equal weights of 0.5 and 0.5 are used). If \code{module} is not \code{FALSE},
#'        \code{register} needs to contain a column \code{"LV"} with the seminar marks.
#' @param interactive logical. Should possible errors in the Daten.txt file
#'        by corrected interactively? Requires the \pkg{png} package for full
#'        interactivity.
#' @param string_scans character. Optional file name of the ZIP file with scanning results
#'        of string exercise sheets (if any) containing Daten2.txt and PNG files as produced
#'        by \code{\link[exams]{nops_scan}}.
#' @param string_points numeric. Vector of length 5 with points assigned
#'        to string results.
#' @param ... arguments passed on to \code{\link[exams]{nops_eval}}.
#'        Arguments which might be of interest:
#'        \code{file} (character), file name of an XLS file from VIS.
#'        The file name should not contain spaces, umlaut or other special characters
#'        (something like \code{"GP-2014-02.xls"} is recommended).
#'        \code{startid} (integer), tarting ID for the seats (defaults to 1).
#' 
#' @details \code{nops_eval} is a companion function for
#' \code{\link[c403]{exams2nops}} and \code{\link[exams]{nops_scan}}. It evaluates
#' the scanned exams by computing the sums of the points achived and (if desired)
#' mapping them to marks (and to module marks). Furthermore HTML reports for each
#' individual student are generated for upload into OLAT.
#' 
#' \code{nops_register} is another companion function for preprocessing the
#' registration lists that are provided by VIS. The function assigns random seats
#' for every student and saves the result in both CSV and XLSX format as well as a
#' tab-separated text file with the seat numbers for import into OLAT.  The
#' underlying workhorse function is \code{\link[c403]{read_vis}}.
#' 
#' @return A \code{data.frame} with the detailed exam results is returned
#' invisibly.  It is also written to a CSV file in the current directory, along
#' with a ZIP file containing the HTML reports (for upload into OLAT), and an XLSX
#' file (for importing the marks into VIS).
#' 
#' @seealso \code{\link[c403]{exams2nops}}, \code{\link[exams]{nops_scan}}, \code{\link[c403]{read_vis}}
#' 
#' @keywords utilities
#' @export
nops_eval <- function(register = Sys.glob("*.csv"), solutions = Sys.glob("*.rds"),
                      scans = Sys.glob("nops_scan_*.zip"), points = NULL,
                      eval = exams_eval(partial = FALSE, negative = 0.25),
                      mark = c(0.5, 0.6, 0.75, 0.85), dir = ".", results = "nops_eval",
                      html = NULL, col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90),
                      encoding = "latin1", language = "de", module = NULL,
                      interactive = TRUE, string_scans = Sys.glob("nops_string_scan_*.zip"),
                      string_points = seq(0, 1, 0.25)) {

  ## additional result file
  res_xls <- paste0(results, ".xlsx")

  ## call ported nops_eval() from "exams" package
  results <- exams::nops_eval(register = register, solutions = solutions, scans = scans,
                              points = points, eval = eval, mark = mark, dir = dir,
                              results = results, html = html, col = col, encoding = encoding,
                              language = language, interactive = interactive,
                              string_scans = string_scans, string_points = string_points)

  ## and then just add generation of UIBK-specific marks in an Excel spreadsheet    
  ## (including module marks if desired)
  if(!identical(mark, FALSE)) {

    ## read registration information
    register <- read.csv2(register, colClasses = "character")

    ## check whether 'register' comes from c403::nops_register()
    if("registration" %in% tolower(names(register)) && is.na(match("matrikel", substr(tolower(names(register)), 1L, 8L)))) {
      warning("'register' file does not seem to be generated by c403::nops_register()")
      names(register)[which(tolower(names(register)) == "registration")] <- "Matrikelnr"
      names(results)[which(tolower(names(results)) == "registration")] <- "Matrikelnr"
    }

    ## select subset of 'register' that corresponds to 'results'
    if(any(nchar(register$Matrikelnr) < 7L)) {
      register$Matrikelnr <- gsub(" ", "0", format(as.numeric(register$Matrikelnr)), fixed = TRUE)
    }
    rownames(register) <- register$Matrikelnr
    register <- register[results$Matrikelnr, ]
    
    ## main mark (GP) and possibly module mark (Modul) if LV mark is available
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

    ## write results
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

