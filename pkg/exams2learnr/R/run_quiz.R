run_quiz <- function(file,
  name = "quiz", title = "R/exams quiz", dir = NULL, ...,
  default_file = NULL, auto_reload = TRUE, shiny_args = NULL, render_args = NULL) {

  ## sanity check for pandoc
  stopifnot(rmarkdown::pandoc_available())

  ## directory handling
  if(is.null(dir)) dir <- tempfile()
  if(!file.exists(dir) && !dir.create(dir))
    stop(gettextf("Cannot create output directory '%s'.", dir))

  ## simple learnr quiz template
  template <- c(
    '---',
    'title: "%s"',
    'output: learnr::tutorial',
    'runtime: shiny_prerendered',
    '---',
    '',
    '```{r setup, include = FALSE}',
    '## package and exercises',
    'library("exams2learnr")',
    'exm <- %s',
    '```',
    '',
    '```{r %s, echo = FALSE, message = FALSE}',
    'exams2learnr(%s)',
    '```'
  )

  ## exams2learnr arguments
  args <- list(...)
  if(length(args) >= 1L) {
    args <- lapply(args, deparse)    
    args <- lapply(args, paste, collapse = "\n")
    if("output" %in% names(args)) args$output <- NULL
    args <- paste(names(args), "=", unlist(args), collapse = ", ")
    args <- paste('exm, output = "quiz",', args)
  } else {
    args <- 'exm, output = "quiz"'
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
  name <- paste0(name, ".Rmd")
  name <- file.path(dir, name)
  writeLines(template, name)
  
  ## run quiz
  rmarkdown::run(name,
    default_file = default_file,
    auto_reload = auto_reload,
    shiny_args = shiny_args,
    render_args = render_args
  )
}
