nops_eval <- function(
  register = dir(pattern = "\\.csv$"),
  solutions = dir(pattern = "\\.rds$"),
  scans = dir(pattern = "^nops_scan_[[:digit:]]*\\.zip$"),
  points = NULL, eval = exams_eval(partial = TRUE, negative = FALSE, rule = "false2"),
  mark = c(0.5, 0.6, 0.75, 0.85), labels = NULL,
  dir = ".", results = "nops_eval", file = NULL, flavor = NULL,
  language = "en", interactive = TRUE,
  string_scans = dir(pattern = "^nops_string_scan_[[:digit:]]*\\.zip$"), string_points = seq(0, 1, 0.25),
  ...)
{
  ## ensure a non-C locale
  if(identical(Sys.getlocale(), "C")) {
    Sys.setlocale("LC_ALL", "en_US.UTF-8")
  }

  ## directories
  dir <- tools::file_path_as_absolute(dir)
  odir <- getwd()
  dir.create(tdir <- tempfile())
  on.exit(unlink(tdir))

  ## output file names
  if(is.null(file)) {
    file <- if(is.character(register)) tools::file_path_sans_ext(basename(register)) else "exam_eval"
  }
  ## results CSV file
  results_csv <- if(tools::file_ext(results) != "csv") paste0(results, ".csv") else results

  ## language file
  if(tools::file_ext(language) == "dcf") language <- tools::file_path_as_absolute(language)

  ## read registration information
  register <- read.csv2(register, colClasses = "character")
  
  ## check field names (de version supported for backward compatibility)
  if(!all(c("registration", "name", "id") %in% tolower(names(register)))) {
    if(!all(c("matrikel", "name", "account") %in% substr(tolower(names(register)), 1L, 8L))) {
      stop("'register' does not contain all columns registration/name/id")    
    } else {
      nam <- match(c("matrikel", "name", "account"), substr(tolower(names(register)), 1L, 8L))      
    }
  } else {
    nam <- match(c("registration", "name", "id"), tolower(names(register)))
  }
  register <- register[, c(nam, (1L:ncol(register))[-nam])]
  nam <- names(register)[1L:3L]
  names(register)[1L:3L] <- c("registration", "name", "id")

  ## extract registration number and fix-up if necessary
  reglength <- pmax(max(nchar(register$registration)), 7L)
  if(any(nchar(register$registration) < reglength)) {
    register$registration <- formatC(as.integer(register$registration), width = reglength, flag = "0")
  }
  rownames(register) <- register$registration

  ## read correct solutions
  solutions <- readRDS(solutions)

  ## any non-schoice/mchoice exercises?
  string <- any(!sapply(solutions[[1L]], function(y) y$metainfo$type %in% c("mchoice", "schoice")))

  ## copy scan results
  oscans <- file_path_as_absolute(scans)
  file.copy(scans, file.path(tdir, scans <- basename(scans)))
  if(string) {
    ostring_scans <- if(length(string_scans) > 0L) file_path_as_absolute(string_scans) else string_scans
    file.copy(string_scans, file.path(tdir, string_scans <- basename(string_scans)))
  }
  setwd(tdir)
  on.exit(setwd(odir), add = TRUE)

  ## unzip scan results (and clean up file names)
  scan_zip <- scans
  scan_fil <- unzip(scan_zip)
  scan_fil <- gsub(normalizePath(file.path(tdir, ""), winslash = "/"), "", normalizePath(scan_fil, winslash = "/"), fixed = TRUE)
  scan_fil <- gsub("/", "", scan_fil, fixed = TRUE)
  if(!("Daten.txt" %in% scan_fil)) {
    file.remove(scan_fil)
    stop(sprintf("'%s' does not contain a 'Daten.txt' file", scan_zip))
  }

  ## unzip scan results
  if(string) {
    string_scan_zip <- string_scans
    if(length(string_scan_zip) < 1L || !file.exists(string_scan_zip)) stop("'string_scans' need to be provided for open-ended exercises")
    string_scan_fil <- unzip(string_scan_zip)
    string_scan_fil <- gsub(normalizePath(file.path(tdir, ""), winslash = "/"), "", normalizePath(string_scan_fil, winslash = "/"), fixed = TRUE)
    string_scan_fil <- gsub("/", "", string_scan_fil, fixed = TRUE)
    if(!("Daten2.txt" %in% string_scan_fil)) {
      file.remove(string_scan_fil)
      stop(sprintf("'%s' does not contain a 'Daten2.txt' file", string_scan_zip))
    }
  } else {
    string_scans <- NULL
  }

  ## read and check scans
  scans <- nops_eval_check("Daten.txt", register = register, solutions = solutions, interactive = interactive)
  if(length(attr(scans, "check")) != 0L) stop("Some IDs of exams/students could not be matched to solutions/registrations.")
  if(string) {
    string_scans <- nops_eval_check2("Daten2.txt", solutions = solutions, interactive = interactive)
    if(length(attr(string_scans, "check")) != 0L) stop("Some IDs of exams/students in the string scans could not be matched to solutions/registrations.")
  }

  ## evaluate exam results
  results <- nops_eval_results(scans = scans, solutions = solutions,
    points = points, eval = eval, mark = mark, labels = labels,
    string_scans = string_scans, string_points = string_points)
  if(interactive) tab <- nops_eval_results_table(results, solutions)

  ## match with registration data
  register <- register[results$registration, ]
  results$registration <- NULL
  results <- cbind(register, results)

  ## save results (preserving original column names, potentially de or upper case)
  names(results)[1L:3L] <- nam
  write.table(results, file = results_csv,
    row.names = FALSE, col.names = TRUE, quote = FALSE, sep = ";")
  names(results)[1L:3L] <- c("registration", "name", "id")

  ## write scan results
  if(is.null(flavor)) flavor <- ""
  flavor <- tolower(flavor)
  if(flavor %in% c("default", "openolat")) flavor <- ""
  flavor <- if(flavor == "") "nops_eval_write" else paste("nops_eval_write", flavor, sep = "_")
  do.call(flavor, c(
    list(results = results_csv, file = file, dir = dir, language = language),
    list(...)
  ))

  ## update zip (in case of corrections to Daten.txt), clean up, and copy back 
  if(isTRUE(attr(scans, "update"))) {
    file.remove(scan_zip)
    zip(scan_zip, scan_fil)
    file.copy(scan_zip, oscans, overwrite = TRUE)
  }
  
  ## update string zip (in case of corrections to Daten2.txt), clean up, copy back  
  if(string && isTRUE(attr(string_scans, "update"))) {
    file.remove(string_scan_zip)
    zip(string_scan_zip, string_scan_fil)
    file.copy(string_scan_zip, ostring_scans, overwrite = TRUE)
  }

  ## copy result files back to original directoy
  file.copy(results_csv, file.path(dir, results_csv), overwrite = TRUE)

  ## return results (with original column names, if different from standard)
  names(results)[1L:3L] <- nam
  invisible(results)
}

nops_eval_check <- function(scans = "Daten.txt", register = dir(pattern = "\\.csv$"),
  solutions = dir(pattern = "\\.rds$"), interactive = TRUE)
{
  ## check for errors in scanned data
  if(any(grepl("ERROR", readLines("Daten.txt"), fixed = TRUE))) stop("ERRORs in 'Daten.txt' file, please run nops_fix() on the 'nops_scan_*.zip' file")

  ## read scans
  d <- read.table(scans, colClasses = "character")
  ## check if replacement sheets were used
  if(any(d[, 5L] == "1")) {
    omit <- NULL
    for(i in which(d[, 5L] == "1")) {
      omit_i <- (d[, 2L] == d[i, 2L]) & (d[, 5L] == "0") & (d[, 6L] == d[i, 6L]) & d[i, 6L] != paste(rep.int("0", nchar(d[i, 6L])), collapse = "")
      if(any(omit_i)) omit <- c(omit, which(omit_i))
    }
    if(length(omit) > 0L) d <- d[-omit, , drop = FALSE]
  }

  ## read participants
  if(is.character(register)) {
    register <- read.csv2(register, colClasses = "character")
    rownames(register) <- register$registration
  }
  
  ## read solutions
  if(is.character(solutions)) solutions <- readRDS(solutions)
  
  ## missing student or exam IDs  
  id1 <- which(!(d[, 6L] %in% rownames(register)))
  id2 <- which(!(d[, 2L] %in% names(solutions)))
  id <- d[sort(unique(c(id1, id2))), 6L]
  attr(d, "check") <- id
  attr(d, "update") <- FALSE

  ## handle missing IDs (if any) interactively or issue warning
  if(length(id) > 0L) {
    if(length(id1) > 0L) message(paste(
      "The following students were not registered or incorrectly filled in their registration numbers:",
      paste(id1, collapse = ", "), sep = "\n"))
    if(length(id2) > 0L) message(paste(
      "For the following students the exam IDs are not available or were incorrectly scanned:",
      paste(id2, collapse = ", "), sep = "\n"))
    if(interactive) {
      for(i in id1) {
        if(requireNamespace("png")) {
          png_i <- trim_nops_scan(d[i, 1L])
	  png_i <- subimage(png_i, center = c(0.25, 0.87 - 0.04 * as.numeric(substr(d[i, 4L], 1L, 1L))), prop = 0.35)
          imageplot(png_i, main = d[i, 1L])
	}
	d[i, 6L] <- readline(prompt = sprintf("Correct registration number (for %s, %s): ", d[i, 6L], d[i, 1L]))
      }
      for(i in id2) {
        if(requireNamespace("png")) {
          png_i <- trim_nops_scan(d[i, 1L])
	  png_i <- subimage(png_i, center = c(0.4, 0.28), prop = 0.18)
          imageplot(png_i, main = d[i, 1L])
	}
	d[i, 2L] <- readline(prompt = sprintf("Correct exam ID (for %s, %s): ", d[i, 2L], d[i, 1L]))
      }
      write.table(d, file = scans, quote = FALSE, row.names = FALSE, col.names = FALSE)
      d <- nops_eval_check(scans = scans, register = register, solutions = solutions, interactive = FALSE)
      attr(d, "update") <- TRUE
    }
  }

  ## return with row names (if possible)
  if(!any(duplicated(d[, 6L]))) rownames(d) <- d[, 6L]
  return(d)
}

nops_eval_check2 <- function(scans = "Daten2.txt", solutions = dir(pattern = "\\.rds$"), interactive = TRUE)
{
  ## read scans
  d <- read.table(scans, colClasses = "character")

  ## read solutions
  if(is.character(solutions)) solutions <- readRDS(solutions)
  
  ## missing exam IDs  
  id <- which(!(d[, 2L] %in% names(solutions)))
  attr(d, "check") <- id
  attr(d, "update") <- FALSE

  ## handle missing IDs (if any) interactively or issue warning
  if(length(id) > 0L) {
    if(!interactive) { 
      warning(paste(
        "For the following students the exam IDs are not available or were incorrectly scanned:",
        paste(id, collapse = ", "), sep = "\n"))
    } else {
      for(i in id) {
        if(requireNamespace("png")) {
          png_i <- trim_nops_scan(d[i, 1L])
	  png_i <- subimage(png_i, center = c(0.4 - 0.2065, 0.28), prop = 0.18)
          imageplot(png_i, main = d[i, 1L])
	}
	d[i, 2L] <- readline(prompt = sprintf("Correct exam ID (for %s, %s): ", d[i, 2L], d[i, 1L]))
      }
      write.table(d, file = scans, quote = FALSE, row.names = FALSE, col.names = FALSE)
      d <- nops_eval_check2(scans = scans, solutions = solutions, interactive = FALSE)
      attr(d, "update") <- TRUE
    }
  }

  ## return with row names (if possible)
  if(!any(duplicated(d[, 2L]))) rownames(d) <- d[, 2L]
  return(d)
}

nops_eval_results <- function(scans = "Daten.txt", solutions = dir(pattern = "\\.rds$"),
  points = NULL, eval = exams_eval(partial = TRUE, negative = FALSE, rule = "false2"),
  mark = c(0.5, 0.6, 0.75, 0.85), labels = NULL,
  string_scans = "Daten2.txt", string_points = seq(0, 1, 0.25))
{
  ## read correct solutions
  x <- if(is.character(solutions)) readRDS(solutions) else solutions
  n1 <- sapply(x, length)
  n <- as.integer(n1[1L])
  stopifnot(all(n1 == n))

  ## any non-schoice/mchoice exercises?
  string_ids <- which(!sapply(x[[1L]], function(y) y$metainfo$type %in% c("mchoice", "schoice")))
  string <- length(string_ids) > 0L
  
  ## read scan results
  if(is.character(scans)) {
    d <- read.table(scans, colClasses = "character")
    if(!any(duplicated(d[, 6L]))) rownames(d) <- d[, 6L]
  } else {
    d <- scans
  }
  d <- d[, c(1L:3L, 6L:(n + 6L))]
  colnames(d) <- c("scan", "exam", "scrambling", "registration", paste("answer", 1L:n, sep = "."))
  stopifnot(all(d$exam %in% names(x)))
  x <- x[d$exam]
  m <- length(x)
  ## string answers (if any) forced to 00000
  if(string) {
    for(i in string_ids) {
      d[[paste("answer", i, sep = ".")]] <- "00000"
    }
  }

  ## read string scan results (if any)
  string_points <- c(c(string_points, rep(0, 5L))[1L:5L], 0)
  if(string) {
    if(is.character(string_scans)) {
      d2 <- read.table(string_scans, colClasses = "character")
      if(!any(duplicated(d2[, 2L]))) rownames(d2) <- d2[, 2L]
    } else {
      d2 <- string_scans
    }
    d2 <- d2[, -3L]
    mchoice_to_points <- function(mchoice) {
      p <- do.call("rbind", strsplit(mchoice, ""))
      p <- matrix(as.numeric(p), nrow = NROW(p), ncol = NCOL(p))
      p <- apply(p, 1, function(x) {
        if(all(x < 1L)) 6L else max(which(x > 0L))
      })
      string_points[p]
    }
    for(i in 3L:5L) d2[[i]] <- mchoice_to_points(d2[[i]])
    colnames(d2) <- c("scan", "exam", paste("answer", 1L:3L, sep = "."))
    if(!all(d2$exam %in% d$exam)) {
      warning(paste(
        "For the following string IDs there are no main exam IDs:",
        paste(d2$exam[!(d2$exam %in% d$exam)], collapse = ", ")))
    }
    if(!all(d$exam %in% d2$exam)) {
      warning(paste(
        "For the following main exam IDs there are no string IDs:",
        paste(d$exam[!(d$exam %in% d2$exam)], collapse = ", ")))
    }
    d2 <- d2[d$exam, ]
    if(any(nok <- is.na(d2$scan))) {
      rownames(d2) <- d2$exam <- d$exam
      nok <- which(nok)
      d2$scan[nok] <- ""
      d2[nok, 3L:5L] <- 0
    }
  }

  ## points
  if(is.null(points)) {
    get_points <- function(i, j) {
      pij <- x[[i]][[j]]$metainfo$points
      if(is.null(pij)) 1 else as.numeric(pij)
    }
    points <- sapply(1L:n, get_points, i = 1)
    points_check <- sapply(1L:m, function(i) sapply(1L:n, function(j) get_points(i, j)))
    if(max(abs(points_check - points)) > 0) points <- points_check
  } else {
    if(length(points) == 1L) points <- rep(points, n)
    if(NROW(points) != n) stop("length of 'points' does not match number of exercises")  
  }
  ## varying point patterns across exams?
  p1dim <- NCOL(points) == 1L
 
  for(i in 1L:n) {
    if(i %in% string_ids) {
      d[[paste("solution", i, sep = ".")]] <- "00000"
      d[[paste("check", i, sep = ".")]] <- d2[[which(string_ids == i) + 2L]]
      d[[paste("points", i, sep = ".")]] <- d[[paste("check", i, sep = ".")]] * if(p1dim) points[i] else points[i, ]
    } else {
      typ <- sapply(x, function(ex) ex[[i]]$metainfo$type)
      cor <- sapply(x, function(ex) paste(as.integer(ex[[i]]$metainfo$solution), collapse = ""))
      ans <- d[[paste("answer", i, sep = ".")]]
      d[[paste("solution", i, sep = ".")]] <- cor
      d[[paste("check", i, sep = ".")]] <- sapply(seq_along(ans),
        function(j) eval$pointsum(cor[j], substr(ans[j], 1L, nchar(cor[j])), type = typ[j]))
      d[[paste("points", i, sep = ".")]] <- d[[paste("check", i, sep = ".")]] * if(p1dim) points[i] else points[i, ]
    }
  }

  p <- rowSums(as.matrix(d[, paste("points", 1L:n, sep = ".")]))
  d$points <- p

  if(!identical(mark, FALSE)) {
    ref <- if(all(mark >= 1)) {
      1
    } else if(p1dim) {
      sum(points)
    } else {
      colSums(points)
    }
    if(is.null(labels)) labels <- (length(mark) + 1L):1L
    d$mark <- as.character(cut(p/ref, breaks = c(-Inf, mark, Inf), right = FALSE, labels = labels))
  }
  
  d <- d[, c(colnames(d)[c(4, 2, 3, 1)], "points", if(!identical(mark, FALSE)) "mark" else NULL,
    as.vector(outer(c("answer", "solution", "check", "points"), 1L:n, paste, sep = ".")))]

  if(string) {
    d$scan2 <- d2$scan
    d <- d[, c(1L:4L, ncol(d), 5L:(ncol(d) - 1L))]
  }

  return(d)
}

nops_eval_results_table <- function(results = "nops_eval.csv", solutions = dir(pattern = "\\.rds$"),
  by = c("exercise", "person"), plot = TRUE)
{
  ## extract check data
  x <- if(is.character(results)) read.csv2(results, colClasses = "character") else results
  tab <- as.matrix(x[, grep("check.", names(x), fixed = TRUE)])

  ## determine type of aggregation
  by <- match.arg(by)
  margin <- if(by == "exercise") 2L else 1L
  
  ## aggregate
  tab <- t(apply(tab, margin, function(x) table(cut(as.numeric(x), breaks = c(-Inf, -0.00001, 0.00001, Inf), levels = -1L:1L))))
  
  ## nice labels for exercises
  if(by == "exercise" & length(solutions) > 0L) {
    sol <- if(is.character(solutions)) readRDS(solutions) else solutions
    nam <- sapply(sol[[1L]], function(obj) obj$metainfo$file)
    if(all(grepl("k[1-9]-schoice-", nam))) { ## FIXME: UIBK-specific heuristic, probably better omit?
      nam <- sapply(strsplit(nam, "-", fixed = TRUE), "[[", 3L)
      nam <- sapply(strsplit(nam, "_", fixed = TRUE), "[[", 1L)
    }
    rownames(tab) <- as.vector(nam)
  }
  
  if(by == "exercise" & plot) {
    negpoints <- sum(tab[, 1L]) > 0L
    if(negpoints) {
      par(mar = c(4, 10, 4, 1), mfrow = c(1, 2))
    } else {
      par(mar = c(4, 10, 4, 1))
    }
    barplot(1 - prop.table(tab, 1L)[nrow(tab):1L, 2L], xlim = c(0, 1),
      horiz = TRUE, las = 1, main = expression(P(pts != 0)))
    abline(v = 0.5, lty = 2)
    if(negpoints) {
      barplot(prop.table(tab[, -2L], 1L)[nrow(tab):1L, 2L], xlim = c(0, 1),
        horiz = TRUE, las = 1, main = expression(P(paste(group("", pts > 0 ~ phantom(), "|"), phantom() ~ pts != 0))))
      abline(v = 0.5, lty = 2)
    }
  }
  
  return(tab)
}

nops_eval_write <- function(results = "nops_eval.csv", file = "exam_eval",
  dir = ".", language = "en", converter = NULL,
  col = hcl(c(0, 0, 60, 120), c(70, 0, 70, 70), 90), encoding = "UTF-8", html = NULL)
{
  ## output file names
  out_zip <- paste0(tools::file_path_sans_ext(basename(results)), ".zip")
  out_html <- if(!is.null(html)) html else file
  if(tools::file_ext(out_html) != "html") out_html <- paste0(out_html, ".html")

  ## user lists
  results <- if(is.character(results)) read.csv2(results, colClasses = "character") else results
  names(results)[1L:3L] <- c("registration", "name", "id")
  rownames(results) <- results$registration
  mark <- "mark" %in% names(results)

  ## dimensions
  m <- length(grep("answer.", colnames(results), fixed = TRUE))
  n <- nrow(results)

  ## format multiple choice solutions
  format_mchoice <- function(x) {
    mchoice2print <- function(x) paste(ifelse(x, letters[1L:5L], rep("_", 5L)), collapse = "")
    sapply(strsplit(x, ""), function(z) mchoice2print(as.logical(as.numeric(z))))
  }
  for(i in as.vector(outer(c("answer", "solution"), 1L:m, paste, sep = "."))) {
    results[[i]] <- format_mchoice(results[[i]])
  }

  ## number of scanned images
  nscans <- 1L + as.integer("scan2" %in% names(results))

  ## read language specification
  if(is.null(converter)) converter <- "pandoc" ## if(language %in% c("cz", "hr", "ro", "sk", "tr")) "pandoc" else "tth"
  language <- nops_language(language, converter = converter)
  substr(language$Points, 1L, 1L) <- toupper(substr(language$Points, 1L, 1L))
  if(!is.null(language$PointSum)) language$Points <- language$PointSum ## currently only for ko

  ## HTML template
  html <- paste(
  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"',
  '"http://www.w3.org/TR/html4/strict.dtd">',
  sprintf('<meta http-equiv="content-type" content="text/html; charset=%s">', encoding),
  '<html>',
  '',
  '<head>',
  paste0('<title>', language$ExamResults, '</title>'),
  '<style type="text/css">',
  'body{font-family: Arial, Helvetica, Sans;}',
  '</style>',
  '</head>',
  '',
  '<body>',
  paste0('<h3>', language$ExamResults, '</h3>'),
  '<table>',
  '<tr>',
  paste0('  <td>', language$Name, ':</td><td>%s</td>'),
  '</tr>',
  '<tr>',
  paste0('  <td>', language$RegistrationNumber, ':</td><td>%s</td>'),
  '</tr>',
  '<tr>',
  paste0('  <td>', language$DocumentID, ':</td><td>%s</td>'),
  '</tr>',
  if(mark) '<tr>',
  if(mark) paste0('  <td>', language$Mark, ':</td><td>%s</td>'),
  if(mark) '</tr>',
  '<tr>',
  paste0('  <td>', language$Points, ':</td><td>%s</td>'),
  '</tr>',
  '</table>',
  '',
  paste0('<h3>', language$Evaluation, '</h3>'),
  '<table border="1" bgcolor="#000000" cellspacing="1" cellpadding="5">',
  paste0('<tr valign="top" bgcolor="#FFFFFF"><td align="right">',
    language$Question, '</td><td align="right">', 
    language$Points, '</td><td>',
    language$GivenAnswer, '</td><td>',
    language$CorrectAnswer, '</td></tr>'),
  '%s',
  '</table>',
  '',
  sprintf('<h3>%s</h3>', language$ExamSheet),
  '<img src="%s" width=1000/>',
  '',
  '%s',
  '',
  '</body>',
  '</html>', sep = "\n")
  
  ## directories
  odir <- getwd()
  dir.create(tdir <- tempfile())
  setwd(tdir)
  on.exit(setwd(odir))

  for(i in 1L:nrow(results)) {
    ## create directory and write html
    id <- rownames(results)[i]
    ac <- results[id, "id"]
    dir.create(file.path(tdir, ac))

    ## extract information
    chk <- as.numeric(results[id, paste("check", 1L:m, sep = ".")])
    ans <- as.character(results[id, paste("answer", 1L:m, sep = ".")])
    sol <- as.character(results[id, paste("solution", 1L:m, sep = ".")])    
    pts <- format(as.numeric(results[id, paste("points", 1L:m, sep = ".")]))

    ## collect results
    res <- paste(sprintf(
      '<tr valign="top" bgcolor="%s"><td align="right">%s</td><td align="right">%s</td><td>%s</td><td>%s</td></tr>',
      col[cut(chk, breaks = c(-Inf, -0.00001, 0.00001, 0.99999, Inf))],
      1L:m,
      pts,
      ans,
      sol
    ), collapse = "\n")
    
    if(mark) {
      html_i <- sprintf(html, results[id, "name"], id, results[id, "exam"], results[id, "mark"], round(as.numeric(results[id, "points"]), digits = 4), 
        res, base64enc::dataURI(file = file.path(odir, results[id, "scan"]), mime = "image/png"),
	if(nscans == 1L) "" else sprintf('<img src="%s" width=1000/>',
	  if(results[id, "scan2"] != "") base64enc::dataURI(file = file.path(odir, results[id, "scan2"]), mime = "image/png") else ""))
    } else {    
      html_i <- sprintf(html, results[id, "name"], id, results[id, "exam"], round(as.numeric(results[id, "points"]), digits = 4), res,
        base64enc::dataURI(file = file.path(odir, results[id, "scan"]), mime = "image/png"),
	if(nscans == 1L) "" else sprintf('<img src="%s" width=1000/>',
	  if(results[id, "scan2"] != "") base64enc::dataURI(file = file.path(odir, results[id, "scan2"]), mime = "image/png") else ""))
    }
    writeLines(html_i, file.path(tdir, ac, out_html))
  }

  setwd(tdir)
  invisible(zip(file.path(dir, out_zip), results[, "id"]))
}
