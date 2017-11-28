exams2olat <- function(file, n = 1L, dir = ".", name = "olattest", maxattempts = 1,
  cutvalue = 1000, solutionswitch = FALSE, 
  stitle = "Aufgabe", ititle = "Frage",
  adescription = "Bitte bearbeiten Sie folgende Aufgaben.",
  sdescription = "Bitte beantworten Sie folgende Frage.",
  eval = list(partial = FALSE, negative = FALSE),
  ...)
{
  ## enable OLAT fixups
  olat <- getOption("olat_fix")
  options(olat_fix = TRUE)
  on.exit(options(olat_fix = olat))

  ## call exams2qti12
  rval <- exams::exams2qti12(file, n = n, dir = dir, name = name, maxattempts = maxattempts,
    cutvalue = cutvalue, solutionswitch = solutionswitch,
    stitle = stitle, ititle = ititle, adescription = adescription,
    sdescription = sdescription, eval = eval, ...)

  ## save exams list generated
  saveRDS(rval, file = file.path(dir, paste(name, ".rds", sep = "")))
  invisible(rval)
}
