nops_register <- function(file = Sys.glob("*.xls*"), startid = 1L)
{
  ## ensure a non-C locale
  if(identical(Sys.getlocale(), "C")) Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## there should be exactly one .xls file
  if(length(file) < 1L) stop("one .xls 'file' must be supplied")
  if(length(file) > 1L) {
    warning("more than one .xls 'file' supplied, only the first one is used")
    file <- file[1L]
  }

  ## make copy in case of .xlsx file
  if(file_ext(file) == "xlsx") {
    file.copy(file, paste0(file_path_sans_ext(file), "-orig.", file_ext(file)))
  }

  ## read data
  x <- read_vis(file)
  info <- attr(x, "info")
  if(!(info[1L] %in% c("GP", "LVP"))) stop("'file' does not seem to be for an exam registration (GP or LVP)")
  location <- switch(info[1L], "GP" = info[4L], "LVP" = info[6L], NA)
  start <- switch(info[1L], "GP" = as.POSIXlt(info[3L]), "LVP" = as.POSIXlt(info[5L]), NA)
  mon <- c("Januar", "Februar", "M&auml;rz", "April", "Mai", "Juni", "Juli",
    "August", "September", "Oktober", "November", "Dezember")
  wday <- c("So", "Mo", "Di", "Mi", "Do", "Fr", "Sa")
  start <- sprintf("%s. %s %s (%s), %s", format(start, "%d"), mon[start$mon + 1L],
    format(start, "%Y"), wday[start$wday + 1L], format(start, "%H:%M"))

  ## add random seat
  x$Sitzplatz <- sample(1L:nrow(x)) + (startid - 1L)

  ## extract only the variables needed and fix up names
  if("Wiederholung" %in% names(x)) {
    x$Wiederholung[x$Wiederholung == ""] <- "0"
    x$Antritt <- as.character(as.numeric(x$Wiederholung) + 1L)
  }
  if(!("Account" %in% names(x))) stop("'file' does not contain information about Account/ZID-Benutzerkennung")
  if("LV-Note" %in% names(x)) {
    x <- x[, c("Matrikelnr", "Name", "SKZ", "Antritt", "LV-Note", "Sitzplatz", "Account")]
    names(x)[5] <- "LV"
  } else {
    x <- x[, c("Matrikelnr", "Name", "SKZ", "Antritt", "Sitzplatz", "Account")]
  }

  ## cat information about commission exams
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
  if(nrow(x4) > 0L | nrow(x5) > 0L) cat("\n")

  ## set up HTML with all personalized information for import into OLAT
  html <- c("Name", "Matrikelnummer", "Beginn", "Ort", "Sitzplatz")
  html <- paste(html, ": %s", sep = "", collapse = "<br/>")
  html <- sprintf(html, x$Name, x$Matrikelnr, start, location, x$Sitzplatz)    
  
  ## export .xlsx (UTF-8), .csv (latin1), .tab (latin1)
  xlsx::write.xlsx(x, file = paste0(tools::file_path_sans_ext(file), ".xlsx"),
    row.names = FALSE)
  con <- file(paste0(tools::file_path_sans_ext(file), ".csv"), "w", encoding = "latin1")
  write.table(x, file = con, quote = FALSE, row.names = FALSE, sep = ";", fileEncoding = "latin1")
  close(con)
  con <- file(paste0(tools::file_path_sans_ext(file), ".tab"), "w", encoding = "latin1")
  writeLines(paste(x$Account, html, sep = "\t"), con = con)
  close(con)
  
  ## return list invisibly
  invisible(x)
}
