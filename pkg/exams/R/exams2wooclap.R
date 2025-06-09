## https://docs.wooclap.com/en/articles/1980934-can-i-move-questions-from-wooclap-to-moodle
exams2wooclap <- function(file, n = 1L, dir = ".", name = "moodletowooclap",
  converter = "pandoc-mathjax", table = "table_shade", ...)
{

  ## call exams2moodle
  rval <- exams2moodle(file = file, n = n, dir = dir, name = name,
      converter = converter, table= table, flavor = "wooclap", ...)

  invisible(rval)
}
