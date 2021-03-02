## format multiple choice solutions
## I want this function in exams_eval.R.
## format_mchoice(c("11100",  "11110")) -> c("abc__", "abcd_")
format_mchoice <- function(x) {
  mchoice2print <- function(x) {
    paste(ifelse(x, letters[1L:5L], rep("_", 5L)),  collapse = "")
  }
  sapply(strsplit(x, ""),
         function(z) mchoice2print(as.logical(as.numeric(z))))
}


.nops_eval_choose_template <- function(template = NULL, file) {
  
  if (!is.null(template)) {
    ext <- tools::file_ext(template)
    template <- tools::file_path_as_absolute(template)
  } else {
    ext <- tools::file_ext(file)
    ext <- if (nchar(ext) > 0L) ext else "html"
    basename <- paste0("eval.", ext)
    template <- system.file(file.path("nops", basename), package = "exams")
    if (nchar(template) == 0L) {
      stop("No default tamplate with extension, ", ext, ".")
    }
  }
  list(template = readLines(template),
       report_name = paste0(tools::file_path_sans_ext(basename(file)), ".", ext))
}


nops_eval_write_template <- function(results = "nops_eval.csv",
                                     file = "exam_eval",
                                     dir = ".", language = "en",
                                     template = NULL, encoding = "UTF-8", 
                                     converter = "pandoc", zip = TRUE, 
                                     return_scan = FALSE, 
                                     convert_dcf_to = "markdown_strict", 
                                     post_process = NULL, ...) {

  if (!return_scan) stopifnot(requireNamespace("base64enc"))
  stopifnot(requireNamespace("whisker"))

  ## output file
  out_name <- tools::file_path_sans_ext(basename(results))
  
  #' Reading template
  #' If `file` argument has an extension, ext, and `template` argument is NULL,  
  #' then the corresponding "/nops/eval.ext" will be searched for. If `file` 
  #' argument does not have an extension and `template` is NULL, then the 
  #' default HTML template, "/nops/eval.html", is used. If `template` is 
  #' specified, the extension of `file` argument is ignored and the extension 
  #' of the template is used.
  tmpl <- .nops_eval_choose_template(template, file)
  template <- tmpl$template
  report_name <- tmpl$report_name
  
  ## Read results
  results <- if(is.character(results)) 
    utils::read.csv2(results, colClasses = "character") else results
  names(results)[1:3] <- c("registration", "name", "id")
  rownames(results) <- results$registration
  has_mark <- "mark" %in% names(results)
  
  ### Dimensions
  m <- length(grep("answer.", colnames(results), fixed = TRUE))
  n <- nrow(results)
  
  for (i in as.vector(outer(c("answer", "solution"), 1L:m, paste, sep = "."))) {
    results[[i]] <- format_mchoice(results[[i]])
  }
  
  ## number of scanned images
  nscans <- 1L + as.integer("scan2" %in% names(results))
  
  ## read language specification
  if (!file.exists(language)) {
    language <- system.file(file.path("nops", paste0(language, ".dcf")),
                            package = "exams")
  }
  if (language == "") {
    language <- system.file(file.path("nops", "en.dcf"), package = "exams")
  }
  DCF <- if (converter == "pandoc") {
    nops_language(language, converter = converter, to = convert_dcf_to)
  } else {
    nops_language(language, converter = converter)
  }
  substr(DCF$Points, 1L, 1L) <- toupper(substr(DCF$Points, 1L, 1L))
  if (!is.null(DCF$PointSum)) {
    DCF$Points <- DCF$PointSum
  }
  
  commonData <- list(
    language = basename(tools::file_path_sans_ext(language)),
    encoding = encoding,
    has_mark = has_mark,
    DCF = DCF
  )
  checkClasses <- c("negative", "neutral", "positive", "full")

  ## directories
  work_dir <- getwd()
  dir.create(temp_dir <- tempfile())

  ## Write out exam reports.
  for (i in 1L:nrow(results)) {
    ## Copy information common to all students.
    dat <- commonData

    id <- rownames(results)[i]
    ac <- results[id, "id"]
    
    dat$tempdir <- file.path(temp_dir, ac)
    dir.create(dat$tempdir)

    ## Exam Information
    dat$name <- results[id, "name"]
    dat$registration <- results[id, "registration"]
    dat$exam <- results[id, "exam"]
    dat$mark <- if (has_mark) results[id, "mark"] else ""
    dat$points <- round(as.numeric(results[id, "points"]), digits = 4)

    ## Evaluation for Each Questions
    res <- data.frame(
      question = 1L:m,
      check = as.numeric(results[id, paste("check", 1L:m, sep = ".")]),
      answer = as.character(results[id, paste("answer", 1L:m, sep = ".")]),
      solution = as.character(results[id, paste("solution", 1L:m, sep = ".")]),
      points = format(as.numeric(results[id, paste("points", 1L:m, sep = ".")]))
    )
    res$check = checkClasses[cut(res$check,
                             breaks = c(-Inf, -1e-05, 1e-05, 0.99999, Inf))]
    dat$results <- unname(whisker::rowSplit(res))

    ## Images
    if (return_scan) {
      dat$scan1 <- "scan1.png"
      file.copy(file.path(work_dir, results[id, "scan"]), 
                file.path(temp_dir, ac, "scan1.png"))
    } else {
      dat$scan1 <- base64enc::dataURI(file = file.path(work_dir, results[id, "scan"]),
                                      mime = "image/png")
    }
    
    if (nscans > 1L && results[id, "scan2"] != "") {
      if (return_scan) {
        dat$scan2 <- "scan2.png"
        file.copy(file.path(work_dir, results[id, "scan2"]), 
                  file.path(temp_dir, ac, "scan2.png"))
      } else {
        dat$image2 <- base64enc::dataURI(file = file.path(work_dir, results[id, "scan2"]),
                                         mime = "image/png")
      }
    }

    template_i <- whisker::whisker.render(template, dat)
    report_file_path <- file.path(temp_dir, ac, report_name)
    writeLines(template_i, report_file_path)
    
    if (!is.null(post_process)) post_process(report_file_path)
  }

  if (isTRUE(zip)) {
    out_zip <- paste0(out_name, ".zip")
    setwd(temp_dir); on.exit(setwd(work_dir))
    invisible(zip(file.path(dir, out_zip), results[, "id"]))
  } else {
    out_dir <- file.path(dir,  out_name)
    dir.create(out_dir)
    invisible(file.copy(file.path(temp_dir, results[, "id"]), 
                        out_dir, recursive = TRUE))
  }
  
  unlink(temp_dir, recursive = TRUE)
}


# PDF Writer (LaTeX to PDF) ----

nops_eval_write_pdf <- function(results = "nops_eval.csv",
                                file = "exam_eval",
                                dir = ".", language = "en",
                                template = NULL, encoding = "UTF-8",
                                converter = "none", zip = TRUE,
                                return_scan = TRUE,
                                keep_tex = TRUE,
                                post_process = NULL, ...) {
  
  if (is.null(post_process)) {
    post_process <- function(x) {
      tinytex::pdflatex(x)
      delete_files <- setdiff(list.files(dirname(x)),
                              list.files(dirname(x), pattern = "\\.pdf$"))
      if (keep_tex) {
        delete_files <- list.files(delete_files, pattern = "(\\.tex$|\\.png$)")
      }
      unlink(delete_files)
    }
  }
  
  if (is.null(template)) {
    template <- system.file(file.path("nops", "eval.tex"), package = "exams")
  }
  exams:::nops_eval_write_template(results, file, dir, language, template, encoding,
                                   converter, zip, return_scan, post_process = post_process, ...)
}


#---- HTML Writer (HTML to HTML)

nops_eval_write_html <- function(results = "nops_eval.csv",
                                 file = "exam_eval",
                                 dir = ".", language = "en",
                                 template = NULL, encoding = "UTF-8",
                                 converter = "pandoc", zip = TRUE,
                                 return_scan = FALSE,
                                 convert_dcf_to = "html",
                                 post_process = NULL, ...) {
  
  if (is.null(template)) {
    template <- system.file(file.path("nops", "eval.html"), package = "exams")
  }
  exams:::nops_eval_write_template(results, file, dir, language, template, encoding,
                                   converter, zip, return_scan, convert_dcf_to,
                                   post_process = post_process, ...)
}


#---- Plain text Writer (TXT to TXT)

nops_eval_write_txt <- function(results = "nops_eval.csv",
                                file = "exam_eval",
                                dir = ".", language = "en",
                                template = NULL, encoding = "UTF-8",
                                converter = "pandoc", zip = TRUE,
                                return_scan = TRUE,
                                convert_dcf_to = "markdown_strict",
                                post_process = NULL, ...) {
  
  if (is.null(template)) {
    template <- system.file(file.path("nops", "eval.txt"), package = "exams")
  }
  exams:::nops_eval_write_template(results, file, dir, language, template, encoding,
                                   converter, zip, return_scan, convert_dcf_to,
                                   post_process = post_process, ...)
}


#---- Pandoc Writer

nops_eval_write_pandoc <- function(results = "nops_eval.csv",
                                   file = "exam_eval",
                                   dir = ".", language = "en",
                                   template = NULL, encoding = "UTF-8",
                                   zip = TRUE, return_scan = TRUE,
                                   convert_dcf_to = "markdown_strict",
                                   post_process = NULL,
                                   pandoc_to = NULL, pandoc_options = NULL, 
                                   keep_source = FALSE, ...) {
  
  if (is.null(template)) {
    template <- system.file(file.path("nops", "eval.md"), package = "exams")
  }
  if (is.null(pandoc_to)) {
    stop("Output format (pandoc_to) must be specified.")
  }
  
  post_process <- function(x) {
    output <- paste0(tools::file_path_sans_ext(x), ".", pandoc_to)
    invisible(rmarkdown::pandoc_convert(x, to = pandoc_to,
                                        options = c(pandoc_options, "--standalone"),
                                        output = output))
    if (!keep_source) {
      unlink(x)
    }
  }
  
  exams:::nops_eval_write_template(results, file, dir, language, template, encoding,
                                   converter = "pandoc", zip, return_scan,
                                   convert_dcf_to = "markdown_strict",
                                   post_process = post_process, ...)
}

