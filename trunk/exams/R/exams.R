exam_boxplot <- function(quantiles, unit = NULL)
{
  ## x-axis ticks
  if(is.null(unit)) unit <- min(diff(quantiles))
  ax <- c(quantiles[1] - unit, quantiles, quantiles[5] + unit)

  ## graphical parameters
  opar <- par()[c("las", "cex", "mai", "mar")]
  on.exit(par(opar))
  par(las = 2, cex = 1.2, mai = c(1, 1, 0.5, 0.5), mar = c(3, 1, 0, 1))

  ## draw box and whiskers  
  plot(quantiles[c(2, 4, 4, 2, 2)], 0.25 * c(-1, -1, 1, 1, -1),
    type = "l", xlim = range(ax), ylim = c(-0.5, 0.5), ylab = "", xlab = "", axes = FALSE)
  lines(quantiles[1:2], c(0, 0))
  lines(quantiles[4:5], c(0, 0))
  lines(quantiles[c(1, 1)], c(-0.125, 0.125))
  lines(quantiles[c(5, 5)], c(-0.125, 0.125))
  lines(quantiles[c(3, 3)],c(-0.25, 0.25))
  axis(1, ax, as.character(ax))

  invisible(quantiles)
}

mchoice2string <- function(x)
  paste(as.numeric(x), collapse = "")

num2string <- function(x, digits = 3)
  format(round(x, digits = digits), nsmall = digits)

string2mchoice <- function(x)
 strsplit(x, "")[[1]] == "1"

mchoice2summary <- function(x)
  paste("Mehrfachantworten:", paste(letters[which(x)], collapse = ""))

mchoice2tex <- function(x)
  ifelse(x, "\\\\textbf{richtig}", "\\\\textbf{falsch}")

exam_metainfo <- function(file) {
  x <- readLines(file)
  get_command <- function(command) strsplit(strsplit(x[grep(command, x, fixed = TRUE)],
    paste(command, "{", sep = ""), fixed = TRUE)[[1]][2], "}")[[1]][1]
  mchoice <- get_command("\\extype") == "mchoice"
  sol <- get_command("\\exsolution")
  slength <- nchar(sol)
  sol <- if(mchoice) string2mchoice(sol) else as.numeric(sol)  
  list(mchoice = mchoice,
       length = slength,
       solution = sol,
       string = get_command("\\exstring"))
}


exams <- function(file, name = "exercise", dir = NULL, n = 1,
  template = "collection.tex")
{
  ## manage directories
  if(!is.null(dir) && !file.exists(dir)) {
    if(!dir.create(dir)) {
      stop(gettextf("Cannot create output directory '%s'.", dir))
      dir <- NULL
    }
  }
  odir <- getwd()
  on.exit(setwd(odir))
  tdir <- tempfile()
  if(!dir.create(tdir)) stop(gettextf("Cannot create temporary work directory '%s'.", tdir))
  edir <- .find.package("exams")
  
  ## use local files if they exist, otherwise take from package
  ofile <- file
  file <- ifelse(tolower(substr(file, nchar(file)-3, nchar(file))) != ".rnw",
    paste(file, ".Rnw", sep = ""), file)
  file[!file.exists(file)] <- file.path(edir, "exercises", file[!file.exists(file)])
  if(!all(file.exists(file))) stop(paste("The following files cannot be found: ",
    paste(ofile[!file.exists(file)], collapse = ", "), ".", sep = ""))

  otemplate <- template
  if(tolower(substr(template, nchar(template)-3, nchar(template))) != ".tex")
    template <- paste(template, ".tex", sep = "")
  if(!file.exists(template)) template <- file.path(edir, "tex", template)
  if(!file.exists(template)) stop(gettextf("The template '%s' cannot be found.", otemplate))

  ## read template
  templ <- readLines(template)

  ## copy exercise and run Sweave on it
  file.copy(file, tdir)
  setwd(tdir) 
  file_tex <- rep("", length(file)) 
  file_meta <- list()
  for(i in seq_along(file)) file_tex[i] <- Sweave(file[i])
  for(i in seq_along(file)) file_meta[[i]] <- exam_metainfo(file_tex[i])
  
  ## input exercise in template
  wi <-  grep("\\exquestions{}", templ, fixed = TRUE)
  templ[wi] <- paste("\\input{", file_tex, "}", sep = "", collapse = "\n")
  out_tex <- paste(name, ".tex", sep = "")
  out_pdf <- paste(name, ".pdf", sep = "")
  writeLines(templ, out_tex)
  texi2dvi(out_tex, pdf = TRUE, clean = TRUE)

  ## show or copy
  if(is.null(dir)) {
    if(.Platform$OS.type == "windows") shell.exec(out_pdf)
      else system(paste(shQuote(getOption("pdfviewer")), shQuote(out_pdf)), wait = FALSE)
  } else {
    file.copy(file.path(tdir, out_pdf), dir, overwrite = TRUE)
  } 
  unlink(tdir)

  invisible(file_meta)
}
