exams2inspera <- function(file, n = 1L, dir = ".", name = "inspera", template = "inspera", converter = "pandoc-mathml", base64 = FALSE, ...)
{
  rval <- exams2qti21(file = file, n = n, dir = dir, name = name, template = template, converter = converter, base64 = base64, ...)
  invisible(rval)
}
