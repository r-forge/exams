exams2nops <- function(file, n = 1L, dir = NULL, name = NULL,
  language = "de", title = "Klausur", course = "",
  institution = "Universit\\\"at Innsbruck", logo = "uibk-logo-bw.png", date = Sys.Date(), 
  replacement = TRUE, intro = NULL, blank = NULL, duplex = TRUE, pages = NULL,
  usepackage = NULL, encoding = "", startid = 1L, points = NULL, showpoints = FALSE, reglength = 8L, ...)
{
  if(is.null(blank) && duplex && !is.null(pages)) {
    blank <- c(1L, ceiling(length(file)/2L))
  }
  exams::exams2nops(file = file, n = n, dir = dir, name = name,
    language = language, title = title, course = course,
    institution = institution, logo = logo, date = date,
    replacement = replacement, intro = intro, blank = blank, duplex = duplex, pages = pages,
    usepackage = usepackage, encoding = encoding, startid = startid,
    points = points, showpoints = showpoints, reglength = reglength, ...)
}
