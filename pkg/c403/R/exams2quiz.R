exams2quiz <- function(file, n = 1L, dir = ".", name = "VU", solution = FALSE,
  quiet = TRUE, encoding = "", ...)
{
  ## output directory or display on the fly
  display <- missing(dir)
  if(missing(dir) & n == 1L & length(solution) == 1L) {
    display <- TRUE
    dir.create(dir <- tempfile())
  } else {
    display <- FALSE
    if(is.null(dir)) stop("Please specify an output 'dir'.")
  }

  ## create PDF write with custom options
  quizwrite <- make_exams_quizwrite(name = name, quiet = quiet, solution = solution)

  ## generate xexams
  rval <- exams::xexams(file, n = n, dir = dir,
    driver = list(sweave = list(quiet = quiet, encoding = encoding),
                  read = NULL, transform = NULL, write = quizwrite),
    ...)

  ## display single .pdf on the fly
  if(display) {
    out <- normalizePath(file.path(dir, paste0(name, "-", if(solution) "solution" else "quiz", ".pdf")))
    if(.Platform$OS.type == "windows") shell.exec(out)
      else system(paste(shQuote(getOption("pdfviewer")), shQuote(out)), wait = FALSE)
  }
  
  ## return xexams object invisibly
  invisible(rval)
}

make_exams_quizwrite <- function(name = "VU", quiet = TRUE, solution = FALSE)
{

unit <- gsub("[A-Z,a-z]", "", strsplit(name, "-", fixed = TRUE)[[1L]][1L])
if(unit == "") unit <- "0"

header <- sprintf(
"\\documentclass[11pt,compress,t,usepdftitle=false,aspectratio=43]{beamer}
\\usetheme[foot]{uibk}
\\usepackage{uibkteaching}
\\usepackage{multicol}
\\title[VU Mathematik]{VU Mathematik}
\\chaptername{VU}
\\setkeys{Gin}{width=0.35\\textwidth}
\\date{%s}
\\chapter{%s}{Quiz}
\\subtitle{}
\\begin{document}

", as.POSIXlt(Sys.Date())$year + 1900, unit)

footer <- "\\end{document}"

  # This function will implicitly be returned - as defined here
  # it uses the variables above (scoping).
  function(exm, dir, info)
  {
    ## basic indexes
    id <- info$id
    n <- info$n
    m <- length(exm)

    ## determine number of alternative choices for each exercise
    ufile <- sapply(1L:m, function(n) exm[[n]]$metainfo$file)
    wrong_type <- ufile[!sapply(1L:m, function(n) exm[[n]]$metainfo$type == "schoice")]
    if(length(wrong_type) > 0) {
      stop(paste("the following exercises are not single-choice exercises:",
        paste(wrong_type, collapse = ", ")))
    }
    exl <- sapply(1L:m, function(n) exm[[n]]$metainfo$length)
    if(any(exl != 5L)) {
      stop(paste("the following exercises have length != 5:",
        paste(ufile[exl != 5L], collapse = ", ")))
    }
  
    ## current directory
    dir_orig <- getwd()
    on.exit(setwd(dir_orig))

    ## temporary in which LaTeX is compiled
    dir_temp <- tempfile()
    if(!file.exists(dir_temp) && !dir.create(dir_temp))
      stop(gettextf("Cannot create temporary work directory '%s'.", dir_temp))
    setwd(dir_temp) 
    on.exit(unlink(dir_temp), add = TRUE)

    ## collect supplementary files
    supps <- unlist(lapply(exm, "[[", "supplements"))
    if(!is.null(supps)) file.copy(supps, dir_temp)

    ## write out LaTeX code
    for(sol in solution) {
      tex <- header
      for(j in 1L:m) {
    
        ## combine question+questionlist and solution+solutionlist
        tex <- c(tex,
          "",
	  "\\begin{frame}",
  	  sprintf("\\begin{exampleblock}{Quiz-Aufgabe %s}", j),
          exm[[j]]$question,
          "\\begin{enumerate}[a]",
          paste0("  \\item \\only<",
	    if(sol) 1 else 2,
	    ">{\\TC{",
	    c("mgray", "dgreen")[exm[[j]]$metainfo$solution + 1L],
	    "}}{",
	    exm[[j]]$questionlist, "}"),
          "\\end{enumerate}",
	  "\\end{exampleblock}",
	  "\\end{frame}",
	  "",
	  if(!sol) NULL else c(
	  "\\begin{frame}",
	  if(length(exm[[j]]$solution) > 22) "\\begin{multicols}{2}",
	  "\\fontsize{4}{3}\\selectfont",
          exm[[j]]$solution,
	  if(length(exm[[j]]$solution) > 22) "\\end{multicols}",
	  "\\end{frame}"),
	  "")
      }
      tex <- c(tex, footer)

      ## assign names for output files
      make_full_name <- function(name, id, type = "")
        paste0(name, "-", if(sol) "solution" else "quiz",
	  if(n > 1) "-" else "",
	  if(n > 1) formatC(id, width = floor(log10(n)) + 1L, flag = "0") else "",
	  ifelse(type == "", "", "."), type)
      out_tex <- make_full_name(name, id, type = "tex")
      out_pdf <- make_full_name(name, id, type = "pdf")

      ## create and compile output tex
      writeLines(tex, out_tex)
      texi2dvi(out_tex, pdf = TRUE, clean = TRUE, quiet = quiet)

      ## check output PDF files and copy to output directory
      out_ok <- file.exists(out_pdf)
      if(any(!out_ok)) {
        warning(paste("could not generate the following files:", paste(out_pdf[!out_ok], collapse = ", ")))
        out_pdf <- out_pdf[out_ok]
      }
      if(!is.null(out_pdf)) file.copy(out_pdf, dir, overwrite = TRUE)
      invisible(out_pdf)
    }
  }
}
