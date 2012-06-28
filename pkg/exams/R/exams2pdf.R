exams2pdf <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  template = "plain", inputs = NULL, header = list(Date = Sys.Date()), name = NULL, control = NULL,
  quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL)
{
  pdfwrite <- make_exams_write_pdf(template = template, inputs = inputs, header = header,
    name = name, quiet = quiet, control = control)
  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL, transform = NULL, write = pdfwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}

make_exams_write_pdf <- function(template = "plain", inputs = NULL,
  header = list(Date = Sys.Date()), name = NULL, quiet = TRUE, control = NULL)
{
  ## template pre-processing
  template_raw <- template
  template_tex <- template_path <- ifelse(
    tolower(substr(template, nchar(template) - 3L, nchar(template))) != ".tex",
    paste(template, ".tex", sep = ""), template)
  template_base <- file_path_sans_ext(template_tex)
  template_path <- ifelse(file.exists(template_tex),
    template_tex, file.path(.find.package("exams"), "tex", template_tex))
  if(!all(file.exists(template_path))) stop(paste("The following files cannot be found: ",
    paste(template_raw[!file.exists(template_path)], collapse = ", "), ".", sep = ""))  

  ## read template
  template <- lapply(template_path, readLines)
  ## which input types in template?
  input_types <- function(x) {
    x <- x[grep("\\exinput", x, fixed = TRUE)]
    if(length(x) < 1L) stop("templates must specify at least one \\exinput{}")
    as.vector(sapply(strsplit(sapply(strsplit(x,
      paste("\\exinput{", sep = ""), fixed = TRUE), tail, 1L), "}"), head, 1L))
  }
  template_it <- lapply(template, input_types)
  template_has_header <- sapply(template_it, function(x) "header" %in% x)
  template_has_questionnaire <- sapply(template_it, function(x) "questionnaire" %in% x)
  template_has_exercises <- sapply(template_it, function(x) "exercises" %in% x)

  ## output name processing
  if(is.null(name)) {
    strip_path <- function(file) sapply(strsplit(file, .Platform$file.sep), tail, 1L)
    name <- strip_path(template_base)
  }

  ## check further inputs (if any)
  if(!is.null(inputs)) {
    if(!all(file.exists(inputs))) stop(paste("The following inputs cannot be found: ",
      paste(inputs[!file.exists(inputs)], collapse = ", "), ".", sep = ""))
  }

  ## convenience functions for writing LaTeX  
  mchoice.symbol <- if(!is.null(control) && !is.null(control$mchoice.symbol)) { ## FIXME: further control options?
    control$mchoice.symbol
  } else {
    c(True = "X", False = " ")
  }
  mchoice2quest <- function(x) paste("  \\item \\exmchoice{",
    paste(ifelse(x, mchoice.symbol[["True"]], mchoice.symbol[["False"]]), collapse = "}{"), "}", sep = "")
  num2quest <- function(x) {
    rval <-  paste("  \\item \\exnum{", 
      paste(strsplit(format(c(100000.000, x), nsmall = 3, scientific = FALSE)[-1], "")[[1]][-7],
      collapse = "}{"), "}", sep = "")
    if(length(x) > 1) rval <- paste(rval, " \\\\\n        \\exnum{",
      paste(strsplit(format(c(100000.000, x), nsmall = 3, scientific = FALSE)[-1], "")[[2]][-7],
      collapse = "}{"), "}", sep = "")
    rval 
  }
  string2quest <- function(x) paste("  \\item \\exstring{", x, "}", sep = "")  
  

  ## set up actual write function
  function(exm, dir, info)
  {
    ## basic indexes
    id <- info$id
    n <- info$n
    m <- length(exm)
  
    ## current directory
    dir_orig <- getwd()
    on.exit(setwd(dir_orig))

    ## temporary in which LaTeX is compiled
    dir_temp <- tempfile()
    if(!file.exists(dir_temp) && !dir.create(dir_temp))
      stop(gettextf("Cannot create temporary work directory '%s'.", dir_temp))
    setwd(dir_temp) 
    on.exit(unlink(dir_temp), add = TRUE)

    ## collect extra inputs
    if(!is.null(inputs)) file.copy(inputs, dir_temp)
    
    ## collect supplementary files
    supps <- unlist(lapply(exm, "[[", "supplements")) ## FIXME: restrict in some way? omit .csv and .rda?
    if(!is.null(supps)) file.copy(supps, dir_temp)
    
    ## extract required metainfo
    fil <- sapply(exm, function(x) x$metainfo$file)
    typ <- sapply(exm, function(x) x$metainfo$type)
    sol <- lapply(exm, function(x) x$metainfo$solution)

    ## write out LaTeX code
    for(j in 1L:m) {
      writeLines(c(
        "",
	"\\begin{question}",
        exm[[j]]$question,
	if(is.null(exm[[j]]$questionlist)) NULL else c(
	  "\\begin{answerlist}",
          paste("  \\item", exm[[j]]$questionlist),
	  "\\end{answerlist}"),
	"\\end{question}",
	"",
	"\\begin{solution}",
        exm[[j]]$solution,
	if(is.null(exm[[j]]$solutionlist)) NULL else c(
	  "\\begin{answerlist}",
          paste("  \\item", exm[[j]]$solutionlist),
	  "\\end{answerlist}"),
	"\\end{solution}",
	""), fil[j])
    }

    ## assign names for output files
    make_full_name <- function(name, id, type = "")
      paste(name, formatC(id, width = floor(log10(n)) + 1L, flag = "0"), ifelse(type == "", "", "."), type, sep = "")
    out_tex <- make_full_name(name, id, type = "tex")
    out_pdf <- make_full_name(name, id, type = "pdf")

    ## compile output files for all templates
    for(j in seq_along(template)) {
      tmpl <- template[[j]]

      ## input header
      if(template_has_header[j]) {
        wi <-  grep("\\exinput{header}", tmpl, fixed = TRUE)
        tmpl[wi] <- if(length(header) < 1) "" else paste("\\", names(header), "{",
 	  sapply(header, function(x) if(is.function(x)) x(i) else as.character(x)), "}", collapse = "\n", sep = "")
      }

      ## input questionnaire
      if(template_has_questionnaire[j]) {
        wi <-  grep("\\exinput{questionnaire}", tmpl, fixed = TRUE)
        tmpl[wi] <- paste(c("\\begin{enumerate}", sapply(seq_along(typ), function(i)
	  switch(typ[i],
	    "mchoice" = mchoice2quest(sol[[i]]),
            "num" =  num2quest(sol[[i]]),
            "string" = string2quest(sol[[i]]))),
 	  "\\end{enumerate}", ""), collapse = "\n")
      }

      ## input exercise tex
      if(template_has_exercises[j]) {
        wi <-  grep("\\exinput{exercises}", tmpl, fixed = TRUE)
        tmpl[wi] <- paste("\\input{", fil, "}", sep = "", collapse = "\n")
      }

      ## create and compile output tex
      writeLines(tmpl, out_tex[j])
      texi2dvi(out_tex[j], pdf = TRUE, clean = TRUE, quiet = quiet)

      ## optionally, copy all files to specified dir for processing with exams2html()
      if(!is.null(xhtmldir <- getOption("xexams.html.directory"))) {
        xhtmlexdir <- file_path_sans_ext(out_tex[j])
        dir.create(file.path(xhtmldir, xhtmlexdir))
        file.copy(list.files(), file.path(xhtmldir, xhtmlexdir, list.files()))
        options("xexams.html.directory.texfiles" = c(
          getOption("xexams.html.directory.texfiles"),
          file.path(xhtmldir, xhtmlexdir, out_tex[j])
        ))
        options("xexams.html.directory.copiedfiles" = c(
          getOption("xexams.html.directory.copiedfiles"),
          file.path(xhtmldir, xhtmlexdir, list.files())
        ))
      }
    }

    ## check output PDF files and copy to output directory
    out_ok <- file.exists(out_pdf)
    if(any(!out_ok)) {
      warning(paste("could not generate the following files:", paste(out_pdf[!out_ok], collapse = ", ")))
      out_pdf <- out_pdf[out_ok]
    }
    if(!is.null(out_pdf)) file.copy(out_pdf, dir)
    invisible(out_pdf)
  }
}

