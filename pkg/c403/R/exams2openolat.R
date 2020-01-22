
#' Exams to OpenOlat
#'
#' Interfaces \code{\link[exams]{exams2openolat}} with
#' slightly different default values.
#' TODO: Finish docstring
#'
#' @export
exams2openolat <- function(file, n = 1L, dir = ".", name = "olattest", maxattempts = 1,
  cutvalue = 1000, solutionswitch = FALSE, qti = "2.1",
  stitle = "Aufgabe", ititle = "Frage",
  adescription = "Bitte bearbeiten Sie folgende Aufgaben.",
  sdescription = "Bitte beantworten Sie folgende Frage.",
  eval = list(partial = FALSE, negative = FALSE),
  ...)
{
  ## use simple ASCII quotes
  quot <- getOption("useFancyQuotes")
  options(useFancyQuotes = FALSE)
  on.exit(options(useFancyQuotes = quot))

  ## call exams::exams2openolat
  rval <- exams::exams2openolat(file, n = n, dir = dir, name = name, maxattempts = maxattempts,
    cutvalue = cutvalue, solutionswitch = solutionswitch, qti = qti,
    stitle = stitle, ititle = ititle, adescription = adescription,
    sdescription = sdescription, eval = eval, ...)

  ## save exams list generated
  saveRDS(rval, file = file.path(dir, paste(name, ".rds", sep = "")))
  invisible(rval)
}
