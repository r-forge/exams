## Valid QTI xml code, uses xmllint
validQTI <- function(file = "~/tmp/qti12.zip", dtd = NULL, tdir = "~/tmp/dtd")
{
  owd <- getwd()
  on.exit(setwd(owd))

  if(is.null(dtd))
    dtd <- "http://www.imsglobal.org/question/qtiv1p2/qtiasifulldtd/ims_qtiasiv1p2.dtd"
  dtd2 <- readLines(dtd)
  if(is.null(tdir))
    tdir <- tempfile()
  if(!file.exists(tdir)) {
    dir.create(tdir)
    on.exit(unlink(tdir), add = TRUE)
  }
  file.copy(file, file.path(tdir, basename(file)))

  setwd(tdir)

  if(file_ext(file) == "zip") {
    unzip(file)
  }
  xml <- grep(".xml", dir(tdir), value = TRUE)
  if(!length(xml)) stop("no xml file found for validation!")
  xml2 <- readLines(xml)
  i <- grep(".dtd", xml2, fixed = TRUE)
  dtd_name <- strsplit(xml2[i], '"', fixed = TRUE)[[1]][2]
  writeLines(dtd2, file.path(tdir, dtd_name))

  cmd <- paste('xmllint --valid', xml, " > /dev/null")
  system(cmd)

  invisible(NULL)
}


## Small wrapper to check xml code
vQTI <- function(file = c("boxplots", "tstat", "boxhist", "superheroes"),
  dir = "~/tmp", dtd = NULL, ...)
{
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }

  exams2qti12(file, dir = dir, name = "vQTI", ...)

  validQTI(file = file.path(dir, "vQTI.zip"), dtd = dtd)
}
