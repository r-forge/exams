exams2canvas <- function(file, n = 1L, dir = ".", name = "canvasquiz",
  maxattempts = 1, converter = NULL, ...)
{
  ## call exams2qti12
  rval <- exams2qti12(file = file, n = n, dir = dir, name = name,
    converter = converter, maxattempts = maxattempts, flavor = "canvas", ...)

  invisible(rval)
}
