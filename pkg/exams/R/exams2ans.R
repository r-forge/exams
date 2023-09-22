exams2ans <- function(file, n = 1L, dir = ".", name = "anstest",
  converter = "pandoc-mathjax", table = TRUE,
  maxattempts = 1, cutvalue = NULL, ...)
{
  ## post-process mathjax output for display in OpenOlat
  .exams_set_internal(pandoc_mathjax_fixup = "openolat")
  on.exit(.exams_set_internal(pandoc_mathjax_fixup = FALSE))
  .exams_set_internal(pandoc_table_class_fixup = table)
  on.exit(.exams_set_internal(pandoc_table_class_fixup = FALSE))

  ## call exams2qti12 or exams2qti21
  rval <- exams2qti21(file = file, n = n, dir = dir, name = name,
      converter = converter, maxattempts = maxattempts, cutvalue = cutvalue, base64 = FALSE,
      flavor = "ans", ...)
  
  invisible(rval)
}
