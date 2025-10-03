#' Reading VIS Registrations
#'
#' Read registration lists (for exams or courses) from the Excel export
#' of VIS (which actually may or may not be XLS or HTML files).
#'
#' @param file character with file name of an XLS file from VIS.
#' @param subset logical or character. If logical: Should students without confirmed registration be omitted?
#' If character: Select only the students with certain student IDs provided in \code{subset}.
#' @param ... additional arguments passed to \code{\link[xlsx]{read.xlsx}}.
#'
#' @details VIS offers Excel exports but in case of registration lists these are
#' actually HTML files containing an HTML table. (Note that as of 2021 VIS offers an additional
#' \dQuote{real Excel} export.) HTMLtables are read using the XML
#' package. However, some exports are also converted to actual Excel files which are read using
#' the xlsx package. In either case some basic cleaning is done and additional
#' meta-information is extracted.
#'
#' The \code{vis_register} function loops over reading several VIS exports and then
#' consolidates the resulting data frames.
#'
#' @return A \code{data.frame} with an additional attribute \code{"info"} providing
#' details about the type of course (\code{"LV"}) or exam (\code{"GP"}).
#'
#' @importFrom tools file_ext
#' @aliases read_vis vis_register
#' @keywords utilities
#' @export
read_vis <- function(file, ...) {
  fex <- tools::file_ext(file)
  if(fex == "xlsx") return(read_vis_xlsx(file, ...))
  if(fex == "xls") {
    if(identical(rawToChar(readBin(file, what = "raw", n = 9L)), "<!DOCTYPE")) {
      return(read_vis_html(file, ...))
    } else {
      return(read_vis_xls(file, ...))    
    }
  }
  stop("not yet implemented")
}

## transform to cleaned-up character
to_char <- function(x, fixup = NULL) {
  x <- as.character(x)
  if(is.null(fixup)) fixup <- cbind(c("\u00a0", ".", "&#039;"), c(" ", "", "'"))
  for(j in 1L:nrow(fixup)) x <- gsub(fixup[j, 1], fixup[j, 2], x, fixed = TRUE)
  x <- gsub("  ", " ", x, fixed = TRUE)
  x <- gsub("[[:space:]]+$", "", x)
  x <- gsub("^+[[:space:]]", "", x)
  x[x == " "] <- ""
  x[x == ""] <- NA_character_
  return(x)
}


## transform to character date/time
to_datetime <- function(x) {
  xn <- suppressWarnings(as.numeric(x))
  if(any(is.na(xn))) {
    xp <- try(strptime(x, "%d.%m.%Y %H:%M:%S"), silent = TRUE)
    if(!inherits(xp, "try-error")) {
      x <- format(xp, "%Y-%m-%d %H:%M:%S")
    }
  } else {
    x <- xn - 2L
    x <- as.POSIXct(paste(as.Date("1900-01-01") + floor(x), "00:00:00")) +
      (x - floor(x)) * 24 * 60 * 60
    x <- format(x, "%Y-%m-%d %H:%M:%S")
  }
  return(x)
}


## workhorse function for reading VIS lists that were downloaded
## as HTML and then converted to actual XLSX
read_vis_xlsx <- function(file, subset = FALSE, ...) {
  ## ensure a non-C locale
  if(identical(Sys.getlocale(), "C")) Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## read .xlsx file from UIBK/VIS
  x <- openxlsx::read.xlsx(file, ...)

  ## fix names
  names(x)[names(x) == "Matrikelnr."] <- "Matrikelnr"
  names(x)[names(x) == "Matrikelnummer"] <- "Matrikelnr"
  names(x)[names(x) == "Kandidat/in"] <- "Name"
  
  ## fix type
  for(i in names(x)) {
    if(i %in% c("Matrikelnr", "SKZ")) {
      x[[i]] <- gsub("'", "", to_char(x[[i]]), fixed = TRUE)
    } else if(i == "Anmeldedatum") {
      d <- try(to_datetime(x[[i]]), silent = TRUE)
      if(!inherits(d, "try-error")) x[[i]] <- d
    } else {
      x[[i]] <- to_char(x[[i]], fixup = rbind(c("\t", " ")))
    }
  }

  ## extract info part
  info <- openxlsx::read.xlsx(file, sheet = 2, ...)
  info <- as.character(rbind(names(info), as.matrix(info)))

  ## LV vs. GP (FIXME: LVP)
  ii <- which(info == "Teilnehmerliste")
  if(grepl("Lehrveranstaltung", info[ii + 1L])) {
    info <- c("LV",
      gsub("\t", "", strsplit(info[ii + 5L], " - ", fixed = TRUE)[[1L]][2L], fixed = TRUE),
      strsplit(info[ii + 6L], "(Ort: )|\n")[[1L]][1L:2L])
    info[3L] <- format(strptime(info[3L], "Datum: %d.%m.%Y, Zeit: %H:%M Uhr, "), "%Y-%m-%d %H:%M")
  } else if(grepl("Gesamtpr.*fungstermin", info[ii + 1L])) {
    start <- strptime(substr(info[ii + 6L], 1L, 16L), "%d.%m.%Y %H:%M")
    start <- format(start, "%Y-%m-%d %H:%M")
    location <- strsplit(info[ii + 6L], "\n")[[1L]][1L]
    location <- strsplit(location, ", Ort: ", fixed = TRUE)[[1L]][2L]
    course <- gsub("\t", "", info[ii + 5L], fixed = TRUE)
    course <- paste(strsplit(course, " ", fixed = TRUE)[[1L]][-1L], collapse = " ")
    info <- c("GP", course, start, location)
  }
  attr(x, "info") <- info

  ## omit empty columns and rows  
  ix <- apply(x, 1L, function(y) all(is.na(y)))
  if(any(ix)) x <- x[1L:(min(which(ix)) - 1L), ]
  if("Matrikelnr" %in% names(x)) rownames(x) <- x$Matrikelnr

  ## drop canceled registrations
  if(is.logical(subset) && isTRUE(subset) && ("Meldestatus" %in% names(x))) {
    x <- x[substr(x$Meldestatus, 1, 14) == "Anmeldung best", , drop = FALSE]
  } else if(is.character(subset)) {
    x <- x[x$Matrikelnr %in% subset, , drop = FALSE]
  }
  
  return(x)
}


## workhorse function for reading VIS lists that were downloaded
## as HTML and then converted to actual XLS
read_vis_xls <- function(file, ...) {

  ## ensure a non-C locale
  if(identical(Sys.getlocale(), "C")) Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## read .xls file from UIBK/VIS (has some UTF-8 non-blanks)
  x <- xlsx::read.xlsx(file, sheetIndex = 1L, header = FALSE,
    colClasses = "character", encoding = "UTF-8", ...)
  for(i in 1L:ncol(x)) x[[i]] <- to_char(x[[i]])

  ## store information from first row
  info <- x[1L, 1L]
  info <- to_char(strsplit(info, "\n")[[1L]])

  ## extract start/location (FIXME: currently only GP, not LV or LVP)
  start <- strptime(substr(info[3L], 1L, 14L), "%d%m%Y %H:%M")
  start <- format(start, "%Y-%m-%d %H:%M")
  location <- info[5L]
  location <- gsub(" ", "", location)
  location <- substr(location, 5L, nchar(location))
  info <- c("GP", info[1L], start, location, info[2L], info[4L])

  ## extract actual column names and omit first two rows
  names(x) <- as.character(x[2L,])
  ok <- which(!is.na(x[2L,]))
  x <- x[-(1L:2L), ok, drop = FALSE]
  attr(x, "info") <- info

  ## fix names
  names(x)[names(x) == "Matrikelnummer"] <- "Matrikelnr"
  names(x)[names(x) == "Kandidat/in"] <- "Name"

  ## omit trailing rows
  ix <- apply(x, 1L, function(y) all(is.na(y)))
  if(any(ix)) x <- x[1L:(min(which(ix)) - 1L), ]
  if("Matrikelnr" %in% names(x)) {
    x$Matrikelnr <- gsub("'", "", x$Matrikelnr, fixed = TRUE)
    rownames(x) <- x$Matrikelnr
  }
  if("SKZ" %in% names(x)) {
    x$SKZ <- gsub("'", "", x$SKZ, fixed = TRUE)
  }
  
  return(x)
}

## workhorse function for reading VIS lists that were downloaded as HTML
read_vis_html <- function(file, subset = FALSE) {

  stopifnot(requireNamespace("XML"))
  x <- XML::xmlRoot(XML::htmlTreeParse(file))

  ## extract module nr/type
  nr <- x[["body"]][[2L]]
  tbody <- "tbody" %in% names(nr) 
  nr <- if(tbody) nr[[2L]][[1L]] else nr[[2L]]  
  if(grepl("Lehrveranstaltung", XML::xmlValue(nr[[1L]]))) {
    nr <- strsplit(XML::xmlValue(nr[[2L]]), " ")[[1L]]
    nr <- c("LV", nr[5L], nr[1L], paste(nr[-(1L:8L)], collapse = " "))
    info <- if(tbody) x[["body"]][[2L]][[2L]][[2L]] else x[["body"]][[2L]][[3L]]
    if(grepl("Pr.*fung", XML::xmlValue(info[[1L]][[1L]]))) {
      nr[1L] <- "LVP"
      info <- XML::xmlValue(info[[2L]][[1L]])
      info <- strsplit(info, ", Ort: ", fixed = TRUE)[[1L]]
      start <- strptime(info[1L], "Datum: %d.%m.%Y, Zeit: %H:%M Uhr")
      if(is.na(start)) start <- strptime(info[1L], "Datum: %d.%m.%Y, Zeit: %H.%M")
      start <- format(start, "%Y-%m-%d %H:%M")
      location <- info[2L]
      info <- c(start, location)  
    } else {
      info <- NULL
    }
    info <- c(nr, info)
  } else if(grepl("Gesamtpr.*fungstermin", XML::xmlValue(nr[[1L]]))) {
    info <- if(tbody) x[["body"]][[2L]][[2L]][[2L]] else x[["body"]][[2L]][[3L]]
    info <- XML::xmlValue(info[[2L]][[1L]])
    start <- strptime(substr(info, 1L, 16L), "%d.%m.%Y %H:%M")
    start <- format(start, "%Y-%m-%d %H:%M")
    location <- strsplit(info, ", Ort: ", fixed = TRUE)[[1L]][2L]
    info <- strsplit(info, 1L, 16L)
    info <- c("GP",
      paste(strsplit(XML::xmlValue(nr[[2L]]), " ")[[1L]][-1L], collapse = " "),
      start, location)
  } else {
    info <- ""
  }
  
  ## extract participant information
  ## available variable names
  var <- unlist(XML::xmlApply(x[["body"]][[4]][["thead"]][[1]], XML::xmlValue))
  var[var == "Matrikelnr."] <- "Matrikelnr"
  var[var == "email-Adresse"] <- "Email"

  ## all participant information
  part <- x[["body"]][[4]][["tbody"]]
  part <- XML::xmlApply(part, function(p) as.vector(XML::xmlApply(p, XML::xmlValue)))
  part <- part[-length(part)]
  part <- do.call("rbind", part)
  colnames(part) <- var
  rownames(part) <- unlist(part[, "Matrikelnr"])
  
  ## to data frame
  ## part <- part[, -grep("Anmerkung", var), drop = FALSE]
  part <- data.frame(part, stringsAsFactors = FALSE)
  attr(part, "info") <- info
  
  ## replace length 0 values with NA
  for(i in seq_along(part)) {
    if(is.list(part[[i]])) {
      na <- sapply(part[[i]], length) < 1
      if(any(na)) part[[i]][na] <- rep(list(NA_character_), sum(na))
      part[[i]] <- unlist(part[[i]])
    }
  }
  
  ## fixup numbers with leading dash
  if("Matrikelnr" %in% names(part)) {
    if(!is.null(part$Matrikelnr)) part$Matrikelnr <- gsub("'", "", part$Matrikelnr)
    if(!is.null(part$Matrikelnr)) part$SKZ <- gsub("'", "", part$SKZ)
    rownames(part) <- part$Matrikelnr
  }
  
  ## format dates
  if("Anmeldedatum" %in% names(part)) {
    d <- try(to_datetime(part$Anmeldedatum), silent = TRUE)
    if(!inherits(d, "try-error")) part$Anmeldedatum <- d
  }

  ## drop canceled registrations
  if(is.logical(subset) && isTRUE(subset) && ("Meldestatus" %in% names(part))) {
    part <- part[substr(part$Meldestatus, 1, 14) == "Anmeldung best", , drop = FALSE]
  } else if(is.character(subset)) {
    part <- part[part$Matrikelnr %in% subset, , drop = FALSE]
  }
  
  return(part)
}


#' @rdname read_vis
#' @export
vis_register <- function(file = Sys.glob("*.xls"), subset = TRUE)
{
  ## all participants
  x <- lapply(file, read_vis, subset = subset)
  if(any(sapply(x, function(y) attr(y, "info")[1L]) != "LV")) stop("'only supported for LV registrations")

  ## only columns that are available for all  
  nam <- names(x[[1L]])
  if(length(x) > 1L) {
    for(i in 2L:length(x)) nam <- intersect(nam, names(x[[i]]))
  }
  k <- length(nam)
  
  ## unique IDs
  id <- unique(unlist(lapply(x, "[[", "Matrikelnr")))
  n <- length(id)

  ## set up return value
  y <- matrix(NA_character_, nrow = n, ncol = k, dimnames = list(id, nam))

  ## process LV info
  update_vector <- function(origin, update) ifelse(
    is.na(origin) | sapply(origin == "", isTRUE), update,
    ifelse(is.na(update) | sapply(update == "", isTRUE), origin, paste(origin, update, sep = "|")))
  for(i in seq_along(x)) {
    ii <- attr(x[[i]], "info")
    if(!(ii[2L] %in% colnames(y))) {
      y <- cbind(y, "")
      colnames(y)[ncol(y)] <- ii[2L]
    }
    y[rownames(x[[i]]), nam] <- as.matrix(x[[i]][, nam])
    y[rownames(x[[i]]), ii[2L]] <- update_vector(y[rownames(x[[i]]), ii[2L]], ii[3L])
  }
  
  ## classing/formatting  
  y <- data.frame(y, stringsAsFactors = FALSE)
  if(ncol(y) > k) {
    for(i in (k + 1L):ncol(y)) {  
      y[[i]][y[[i]] == ""] <- "-"
      y[[i]] <- sapply(strsplit(y[[i]], "|", fixed = TRUE), function(z) if(length(z) < 1L) "" else tail(z, 1L)) ## FIXME: better idea?
      y[[i]] <- factor(y[[i]])
    }
  }
  if(!is.null(y$SKZ)) y$SKZ <- factor(y$SKZ)
  if(!is.null(y$Semester)) y$Semester <- as.numeric(y$Semester)
  
  ## order by name
  y <- y[order(y$Name),]
  
  return(y)
}

