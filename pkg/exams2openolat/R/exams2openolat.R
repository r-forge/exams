exams2openolat <- function(file, n = 1L, dir = ".", name = "olattest", adescription = "", ...)
{
  ## call exams::exams2openolat
  rval <- exams::exams2openolat(file, n = n, dir = dir, name = name, adescription = adescription, ...)

  ## save exams list generated
  saveRDS(rval, file = file.path(dir, paste(name, ".rds", sep = "")))
  invisible(rval)
}
