exams2canvas <- function(file, n = 1L, dir = ".", name = "canvasquiz", maxattempts = 1, ...)
{
  ## post-process mathjax output for display in OpenOLAT
  .exams_set_internal(canvas = TRUE)
  on.exit(.exams_set_internal(canvas = FALSE))

  ## call exams2qti12
  rval <- exams2qti12(file = file, n = n, dir = dir, name = name,
    converter = "ttm", maxattempts = maxattempts, base64 = FALSE, ...)

  invisible(rval)
}
