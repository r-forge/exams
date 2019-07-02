exams2canvas <- function(file, n = 1L, dir = ".", name = "canvasquiz",
  maxattempts = 1, converter = NULL, ...)
{
  ## default converter is "ttm" if all exercises are Rnw, otherwise "pandoc"
  if(is.null(converter)) {
    converter <- if(any(tolower(tools::file_ext(unlist(file))) == "rmd")) "pandoc" else "ttm"
  }

  ## post-process mathjax output for display in OpenOLAT
  .exams_set_internal(canvas = TRUE)
  on.exit(.exams_set_internal(canvas = FALSE))

  ## call exams2qti12
  rval <- exams2qti12(file = file, n = n, dir = dir, name = name,
    converter = converter, maxattempts = maxattempts, base64 = FALSE, ...)

  invisible(rval)
}
