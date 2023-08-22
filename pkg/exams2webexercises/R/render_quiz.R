render_quiz <- function(file,
  name = "quiz", title = "R/exams quiz", show = TRUE, dir = NULL, edir = NULL, ...,
  clean = TRUE, quiet = TRUE, envir = parent.frame()) {

  ## sanity check for pandoc
  stopifnot(rmarkdown::pandoc_available())

  ## directory handling
  if(is.null(dir)) {
    dir <- tempfile()
    if(is.null(edir)) edir <- getwd()
  }
  if(!file.exists(dir) && !dir.create(dir))
    stop(gettextf("Cannot create output directory '%s'.", dir))

  ## simple webexercises quiz template
  template <- c(
    '---',
    'title: "%s"',
    'output: webexercises::webexercises_default',
    '---',
    '',
    '```{r setup, include = FALSE}',
    '## package and exercises',
    'library("exams2webexercises")',
    'exm <- %s',
    '```',
    '',
    '```{r %s, echo = FALSE, message = FALSE, results="asis"}',
    'exams2webexercises(%s)',
    '```'
  )

  ## exams2webexercises arguments
  args <- list(...)
  if(!is.null(edir)) args <- c(list(edir = edir), args)
  if(length(args) >= 1L) {
    args <- lapply(args, deparse)    
    args <- lapply(args, paste, collapse = "\n")
    if("output" %in% names(args)) args$output <- NULL
    args <- paste(names(args), "=", unlist(args), collapse = ", ")
    args <- paste('exm, ', args)
  } else {
    args <- 'exm'
  }

  ## insert arguments into template
  template <- sprintf(
    paste(template, collapse = "\n"),
    title,
    paste(deparse(file), collapse = "\n"),
    name,
    args
  )

  ## write tutorial .Rmd
  name <- file.path(dir, paste0(name, c(".Rmd", ".html")))
  writeLines(template, name[1L])
  
  ## render quiz
  rmarkdown::render(name[1L],
    clean = clean, quiet = quiet, envir = envir)
  name <- normalizePath(name)
  if(show) browseURL(name[2L])
  invisible(name)
}
