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
  list(mchoice = mchoice,
       length = as.numeric(get_command("\\exlength")),
       solution = if(mchoice) string2mchoice(sol) else as.numeric(sol),
       string = get_command("\\exstring"))
}


show_exercise <- function(file, name = "exercise", dir = NULL,
  template = "~/svn/teaching/exams/inst/tex/collection.tex")
{
  ## read template
  templ <- readLines(template)

  ## manage directories
  if(!is.null(dir) && !file.exists(dir)) {
    if(!dir.create(dir)) {
      stop(gettextf("Cannot create output directory '%s'.", dir))  
      dir <- NULL
    }
  }
  odir <- getwd()
  tdir <- tempfile()
  if(!dir.create(tdir)) stop(gettextf("Cannot create temporary work directory '%s'.", tdir))

  ## copy exercise and run Sweave on it
  file.copy(file, tdir)
  setwd(tdir)  
  file_tex <- Sweave(file)
  file_meta <- exam_metainfo(file_tex)
  
  ## input exercise in template
  wi <-  grep("\\exquestions{}", templ, fixed = TRUE)
  templ[wi] <- paste("\\input{", file_tex, "}", sep = "")
  out_tex <- paste(name, ".tex", sep = "")
  out_pdf <- paste(name, ".pdf", sep = "")
  writeLines(templ, out_tex)
  texi2dvi(out_tex, pdf = TRUE, clean = TRUE)

  ## show or copy
  if(is.null(dir)) {
    if(.Platform$OS.type == "windows") shell.exec(out_pdf)
      else system(paste(shQuote(getOption("pdfviewer")), shQuote(out_pdf)), wait = FALSE)
    setwd(odir)
  } else {
    setwd(odir)
    file.copy(file.path(tdir, out_pdf), dir, overwrite = TRUE)
  } 
  unlink(tdir)

  invisible(file_meta)
}
