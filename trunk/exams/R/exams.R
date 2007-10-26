## workhorse function for compiling (collections of) exercises
exams <- function(file, n = 1, dir = NULL, template = "plain",
  name = NULL, quiet = TRUE, header = list(date = Sys.Date()))
{
  ## manage directories: 
  ##   - for producing several files an output directory is required
  if((n > 1 | length(template) > 1) & is.null(dir)) stop("Please specify an output 'dir'.")
  if(!is.null(dir) && !file.exists(dir) && !dir.create(dir))
    stop(gettextf("Cannot create output directory '%s'.", dir))
  ##   - further: dir (output), dir_orig (original), dir_temp (temp), dir_pkg (package)
  if(!is.null(dir)) dir <- file_path_as_absolute(dir)
  dir_orig <- getwd()
  on.exit(setwd(dir_orig))
  dir_temp <- tempfile()
  if(!dir.create(dir_temp)) stop(gettextf("Cannot create temporary work directory '%s'.", dir_temp))
  dir_pkg <- .find.package("exams")
  
  ## file pre-processing:
  ##   - transform to vector (remember grouping IDs)
  ##   - add paths (generate "foo", "foo.Rnw", "foo.tex", and "path/to/foo.Rnw")
  ##   - check existence (use local files if they exist, otherwise take from package)
  ##   - setup sampling (draw random configuration)
  file_id <- rep(seq_along(file), sapply(file, length))
  file_raw <- unlist(file)
  file_Rnw <- ifelse(
    tolower(substr(file_raw, nchar(file_raw)-3, nchar(file_raw))) != ".rnw",
    paste(file_raw, ".Rnw", sep = ""), file_raw)
  file_base <- substr(file_Rnw, 1, nchar(file_Rnw)-4)
  file_tex <- paste(file_base, ".tex", sep = "")
  file_path <- ifelse(file.exists(file_Rnw),
    file_Rnw, file.path(dir_pkg, "exercises", file_Rnw))
  if(!all(file.exists(file_path))) stop(paste("The following files cannot be found: ",
    paste(file_raw[!file.exists(file_path)], collapse = ", "), ".", sep = ""))  
  sample_id <- function() sapply(unique(file_id),
    function(i) if(sum(file_id == i) > 1) sample(which(file_id == i), 1) else which(file_id == i))

  ## similarly: template pre-processing
  template_raw <- template
  template_tex <- template_path <- ifelse(
    tolower(substr(template, nchar(template)-3, nchar(template))) != ".tex",
    paste(template, ".tex", sep = ""), template)
  template_base <- substr(template_tex, 1, nchar(template_tex)-4)
  template_path <- ifelse(file.exists(template_tex),
    template_tex, file.path(dir_pkg, "tex", template_tex))
  if(!all(file.exists(template_path))) stop(paste("The following files cannot be found: ",
    paste(template_raw[!file.exists(template_path)], collapse = ", "), ".", sep = ""))  

  ## read template
  template <- lapply(template_path, readLines)
  ## which input types in template?
  input_types <- function(x) {
    x <- x[grep("\\exinput", x, fixed = TRUE)]
    if(length(x) < 1) stop("templates must specify at least one \\exinput{}")
    as.vector(sapply(strsplit(sapply(strsplit(x,
      paste("\\exinput{", sep = ""), fixed = TRUE), tail, 1), "}"), head, 1))
  }
  template_it <- lapply(template, input_types)
  template_has_header <- sapply(template_it, function(x) "header" %in% x)
  template_has_questionnaire <- sapply(template_it, function(x) "questionnaire" %in% x)
  template_has_exercises <- sapply(template_it, function(x) "exercises" %in% x)

  ## output name processing
  if(is.null(name)) name <- template_base
  make_full_name <- function(name, id, type = "")
    paste(name, gsub(" ", "0", format(c(n, id)))[-1], ifelse(type == "", "", "."), type, sep = "")

  ## convenience function for reading metainfo from compiled exercise
  read_metainfo <- function(file) {
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

  ## convenience functions for writing LaTeX  
  mchoice2quest <- function(x) paste("  \\item \\exmchoice{",
    paste(ifelse(x, "X", " "), collapse = "}{"), "}", sep = "")
  num2quest <- function(x) paste("  \\item \\exnum{", 
    paste(strsplit(format(c(100000.000, x), nsmall = 3, scientific = FALSE)[-1], "")[[1]][-7],
    collapse = "}{"), "}", sep = "")
  
  ## take everything to temp dir
  file.copy(file_path, dir_temp)
  setwd(dir_temp) 
  on.exit(unlink(dir_temp), add = TRUE)
  
  ## call Sweave and LaTeX, copy and collect results
  metainfo <- list()  
  for(i in 1:n) {
  
    ## select exercise files, run Sweave, collect results
    id <- sample_id()
    for(j in id) Sweave(file_Rnw[j], quiet = quiet) ## FIXME: need envir argument
    metainfo1 <- list()
    for(j in seq_along(id)) metainfo1[[j]] <- read_metainfo(file_tex[id[j]])
    names(metainfo1) <- file_base[id]
    metainfo[[i]] <- metainfo1

    ## assign names
    names(metainfo)[i] <- make_full_name(name[1], i)
    out_tex <- make_full_name(name, i, type = "tex")
    out_pdf <- make_full_name(name, i, type = "pdf")

    ## compile output files for all templates
    for(j in seq_along(template)) {
      tmpl <- template[[j]]

      ## input header
      if(template_has_header[j]) {
        wi <-  grep("\\exinput{header}", tmpl, fixed = TRUE)
        tmpl[wi] <- if(length(header) < 1) "" else paste("\\", names(header), "{",
          sapply(header, function(x) if(is.function(x)) x(i) else as.character(x)), "}", 
	  collapse = "\n", sep = "")
      }

      ## input questionnaire
      if(template_has_questionnaire[j]) {
	mc1 <- sapply(metainfo1, function(x) x[["mchoice"]])
	sol1 <- lapply(metainfo1, function(x) x[["solution"]])
        wi <-  grep("\\exinput{questionnaire}", tmpl, fixed = TRUE)
	tmpl[wi] <- paste(c("\\begin{enumerate}", sapply(seq_along(mc1),
	  function(i) if(mc1[i]) mchoice2quest(sol1[[i]]) else num2quest(sol1[[i]])),
	  "\\end{enumerate}", ""), collapse = "\n")
      }

      ## input exercise tex
      if(template_has_exercises[j]) {
        wi <-  grep("\\exinput{exercises}", tmpl, fixed = TRUE)
        tmpl[wi] <- paste("\\input{", file_tex[id], "}", sep = "", collapse = "\n")
      }

      ## create and compile output tex
      writeLines(tmpl, out_tex[j])
      texi2dvi(out_tex[j], pdf = TRUE, clean = TRUE, quiet = quiet)
    }

    ## copy to output directory (or show)
    if(!is.null(dir)) {
      file.copy(out_pdf, dir, overwrite = TRUE)
    } else {
      if(.Platform$OS.type == "windows") shell.exec(out_pdf)
        else system(paste(shQuote(getOption("pdfviewer")), shQuote(out_pdf)), wait = FALSE)
    } 
  }

  ## collect and store meta information
  class(metainfo) <- "exams_metainfo"  
  if(!is.null(dir)) {
    save(metainfo, file = file.path(dir, "metainfo.rda"))
    metainfo_df <- as.data.frame(t(sapply(metainfo,
      function(x) as.vector(sapply(x, function(y) y$string)))))
    colnames(metainfo_df) <- paste("exercise", gsub(" ", "0", format(1:ncol(metainfo_df))), sep = "")
    write.table(metainfo_df, file = file.path(dir, "metainfo.csv"), sep = ",")
  }

  ## return meta information invisibly
  invisible(metainfo)
}

## print exams_metainfo objects
print.exams_metainfo <- function(x, which = NULL, ...) {
  which <- if(is.null(which)) names(x) else {
    if(is.numeric(which)) names(x)[which] else which
  }
  n <- length(x[[1]])
  for(i in which) {
    cat("\n", i, "\n", sep = "")
    for(j in 1:n) {
      cat("    ", format(c(n, j))[-1], ". ", x[[i]][[j]]$string, "\n", sep = "")
    }
  }
  cat("\n")
  invisible(x)
}


## convenience functions
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
