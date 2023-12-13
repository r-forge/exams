
#' @param file character. Name of the VIS file with the registration list.
#' @param startid integer or logical, default \code{1L}. If \code{FALSE} no
#'   random seats are generated.
#' @param tab logical. Should a tab-separated file with the seat information
#'   be generated for OpenOlat? Defaults to \code{TRUE} if random seats are
#'   generated.
#' @param pdf logical. Should PDF files with participant lists be generated for
#'   printing? Defaults to \code{TRUE} if random seats are generated.
#' @param split integer. Number of participant lists ordered by seat.
#' @param info character. Vector of length 4 with information about the exam:
#'   (1) type of exam (GP, LVP, VO, ...), (2) title of exam,
#'   (3) date/time (YYYY-MM-DD HH:MM), (4) location/room. By default
#'   the information is inferred from the VIS file.
#' @param verbose logical. Should information about the registrations be printed
#'   to the screen?
#'
#' @importFrom tools file_path_sans_ext file_ext texi2pdf
#' @rdname nops_eval
#' @export
nops_register <- function(file = Sys.glob("*.xls*"), startid = 1L,
  tab = !identical(startid, FALSE), pdf = !identical(startid, FALSE),
  split = NULL, info = NULL, verbose = TRUE)
{
  ## ensure a non-C locale
  if(identical(Sys.getlocale(), "C")) Sys.setlocale("LC_ALL", "en_US.UTF-8")


  ## file handling -----------------------------------------

  ## there should be exactly one VIS file
  if(length(file) < 1L) stop("one VIS 'file' must be supplied")
  if(length(file) > 1L) {
    warning("more than one VIS 'file' supplied, only the first one is used")
    file <- file[1L]
  }
  file0 <- file_path_sans_ext(file)

  ## make copy in case of original VIS file in .xlsx format
  if(file_ext(file) == "xlsx") file.copy(file, paste0(file0, "-orig.xlsx"))


  ## consolidate VIS information ---------------------------

  ## read VIS data
  x <- read_vis(file)
  
  ## meta-information
  if(is.null(info)) info <- attr(x, "info")
  if(!is.null(info)) {
    if(info[1L] == "LVP") info <- info[-(3L:4L)]
    location <- info[4L]
    start <- as.POSIXlt(info[3L])
    mon <- c("Januar", "Februar", "M&auml;rz", "April", "Mai", "Juni", "Juli",
      "August", "September", "Oktober", "November", "Dezember")
    wday <- c("So", "Mo", "Di", "Mi", "Do", "Fr", "Sa")
    start <- sprintf("%s. %s %s (%s), %s", format(start, "%d"), mon[start$mon + 1L],
      format(start, "%Y"), wday[start$wday + 1L], format(start, "%H:%M"))
    if(verbose) cat(sprintf("\n%s: %s\nTermin: %s, %s\n", info[1L], info[2L], info[3L], info[4L]))
  } else {
    location <- ""
    start <- ""
  }

  ## previous attempts?
  if("Wiederholung" %in% names(x)) {
    x$Wiederholung[x$Wiederholung == ""] <- "0"
    x$Antritt <- as.character(as.numeric(x$Wiederholung) + 1L)
  }
  
  ## grade from tutorial/seminar?
  if("LV-Note" %in% names(x)) names(x)[names(x) == "LV-Note"] <- "LV"

  ## add random seat?
  if(!identical(startid, FALSE)) {
    startid <- as.integer(startid)
    x$Sitzplatz <- sample(1L:nrow(x)) + (startid - 1L)
    if(verbose) cat(sprintf("Sitzplatz: %s-%s\n", startid, max(x$Sitzplatz)))
  }

  ## check necessary variables
  nam <- intersect(c("Matrikelnr", "Name", "SKZ", "Antritt", "LV", "Sitzplatz", "Account"), names(x))
  err <- setdiff(c("Matrikelnr", "Name", "SKZ", "Account"), nam)
  if(length(err) > 0L) stop(sprintf("'file' does not contain the following necessary information: %s", paste(err, collapse = ", ")))
  x <- x[, nam]

  ## cat information about commission exams
  if(verbose) {
    x4 <- x[x$Antritt == "4", , drop = FALSE]
    if(nrow(x4) > 0L) {
      cat("\nKommissionelle Antritte (3. Wiederholung = 4. Antritt)\n")
      cat(paste(x4$Matrikelnr, x4$Name, collapse = "\n"))
      cat("\n")
    }
    x5 <- x[x$Antritt == "5", , drop = FALSE]
    if(nrow(x5) > 0L) {
      cat("\nKommissionelle Antritte (4. Wiederholung = 5. Antritt)\n")
      cat(paste(x5$Matrikelnr, x5$Name, collapse = "\n"))
      cat("\n")
    }
  }


  ## write files -------------------------------------------

  ## Excel
  openxlsx::write.xlsx(x, file = paste0(file0, ".xlsx"), rowNames = FALSE)
  if(verbose) cat(sprintf("\nTeilnehmerlisten:\n- %s: Excel\n", paste0(file0, ".xlsx")))

  ## CSV
  con <- file(paste0(file0, ".csv"), "w", encoding = "UTF-8")
  write.table(x, file = con, quote = FALSE, row.names = FALSE, sep = ";", fileEncoding = "UTF-8")
  close(con)
  if(verbose) cat(sprintf("- %s: CSV fuer nops_eval\n", paste0(file0, ".csv")))

  ## tab-separated file with personalized information in HTML for OpenOlat
  if(tab) {
    html <- c("Name", "Matrikelnummer", "Beginn", "Ort", "Sitzplatz")
    html <- paste(html, ": %s", sep = "", collapse = "<br/>")
    html <- sprintf(html, x$Name, x$Matrikelnr, start, location, x$Sitzplatz)    
    con <- file(paste0(file0, ".tab"), "w", encoding = "UTF-8")
    writeLines(paste(x$Account, html, sep = "\t"), con = con)
    close(con)
    if(verbose) cat(sprintf("- %s: Sitzplatzinformation fuer OpenOlat\n", paste0(file0, ".tab")))
  }

  ## PDFs with participant lists
  if(pdf) {
    ## temporary LaTeX file and PDF output
    tfile <- paste0(tempfile(), c(".tex", ".pdf"))

    ## template for LaTeX list document  
    doc <- paste(c(
      "\\documentclass[10pt,a4paper]{report}",
      "\\usepackage{a4wide,amssymb,booktabs,longtable}",
      "\\thispagestyle{empty}",
      "\\topmargin-3cm",
      "\\textheight26.4cm",
      "\\parskip4mm",
      "\\parindent0mm",
      "\\renewcommand{\\rmdefault}{phv}",
      "",
      "\\begin{document}",
      "\\small",
      "",
      "\\begin{longtable}{%s}",
      "\\toprule\\noalign{}",
      "%s \\multicolumn{4}{l}{\\it %s} \\\\",
      "%s Matrikelnr & Name & Antritt & Sitzplatz \\\\",
      "\\midrule\\noalign{}",
      "\\endhead",
      "\\bottomrule\\noalign{}",
      "\\endlastfoot",
      "%s",
      "\\end{longtable}",
      "",
      "\\end{document}"), collapse = "\n")

    ## alphabetical ordering
    x <- x[order(x$Name), ]
    tex <- sprintf("%s & %s & %s & %s \\\\ %s",
      x$Matrikelnr, x$Name, x$Antritt, x$Sitzplatz, rep(c("\\midrule", ""), c(nrow(x) - 1, 1)))
    tex <- sprintf(doc, "rlrr", "", paste(info[1:2], collapse = " "), "", paste(tex, collapse = "\n"))
    con <- file(tfile[1L], "w", encoding = "UTF-8")
    writeLines(tex, con = con)
    close(con)
    texi2pdf(tfile[1L], clean = TRUE)
    unlink(tfile[1L])
    file.rename(basename(tfile[2L]), paste0(file0, "-abc.pdf"))
    if(verbose) cat(sprintf("- %s: PDF alphabetisch (beidseitig drucken)\n", paste0(file0, "-abc.pdf")))

    ## seat ordering
    x <- x[order(x$Sitzplatz), ]
    n <- nrow(x)
    rules <- rep.int("\\midrule", n)
    if(!is.null(split)) {
      m <- ceiling(n/split)
      rules[seq(m, by = m, length.out = floor(n/m))] <- "\\bottomrule \\newpage"
    } else {
      m <- 40L
    }
    rules[length(rules)] <- ""
    tex <- sprintf("\\Large $\\square$ & \\Large $\\square$ & %s & %s & %s & %s \\\\ %s",
      x$Matrikelnr, x$Name, x$Antritt, x$Sitzplatz, rules)
    tex <- sprintf(doc,
      "ccrlrr",
      "\\multicolumn{2}{l}{Teilnahme} &",
      paste(info[1:2], collapse = " "),
      "Ja & Nein &",
      paste(tex, collapse = "\n"))
    con <- file(tfile[1L], "w", encoding = "UTF-8")
    writeLines(tex, con = con)
    close(con)
    texi2pdf(tfile[1L], clean = TRUE)
    unlink(tfile[1L])
    file.rename(basename(tfile[2L]), paste0(file0, "-123.pdf"))

    if(verbose) cat(sprintf("- %s: PDF nach Sitzplatz (%sseitig drucken)\n",
      paste0(file0, "-123.pdf"), if(m <= 40L) "ein" else "beid"))
  }


  ## return list invisibly ---------------------------------
  if(verbose) cat("\n")
  invisible(x)
}
