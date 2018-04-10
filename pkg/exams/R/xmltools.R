## Valid QTI xml code, uses xmllint
validQTI <- function(file = "~/tmp/qti12.zip", dtd = "~/dtd_v2p1.xsd", tdir = "~/tmp/dtd")
{
  owd <- getwd()
  on.exit(setwd(owd))

  if(is.null(dtd))
    dtd <- "http://www.imsglobal.org/question/qtiv1p2/qtiasifulldtd/ims_qtiasiv1p2.dtd"
  ## "https://github.com/oat-sa/qti-sdk/raw/master/src/qtism/data/storage/xml/schemes/qtiv2p1/imsqti_v2p1.xsd"
  dtd2 <- readLines(dtd)
  if(is.null(tdir))
    tdir <- tempfile()
  if(!file.exists(tdir)) {
    dir.create(tdir)
    on.exit(unlink(tdir), add = TRUE)
  }
  file.copy(file, file.path(tdir, basename(file)))

  setwd(tdir)

  dtd_name <- paste0(file_path_sans_ext(basename(dtd)), ".dtd")
  writeLines(dtd2, file.path(tdir, dtd_name))

  if(file_ext(file) == "zip") {
    unzip(file)
  }
  xml <- grep(".xml", dir(tdir), value = TRUE, fixed = TRUE)
  if(!length(xml)) stop("no xml file found for validation!")
  log <- NULL
  for(j in seq_along(xml)) {
    cmd <- paste('xmllint --schema  ~/Git/qti-sdk/src/qtism/data/storage/xml/schemes/qtiv2p1/imsqti_v2p1.xsd', xml[j], " > log.txt")
    log <- c(log, system(cmd))
  }

  return(log)
}


## Small wrapper to check xml code
vQTI <- function(file = c("boxplots", "tstat", "ttest", "confint",
  "regression", "anova", "scatterplot", "boxhist", "relfreq", "boxhist2",   
  "fourfold2"), dir = "~/tmp", dtd = "~/dtd_v2p1.xsd", ...)
{
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }

  exams2qti21(file, dir = dir, name = "vQTI", ...)

  validQTI(file = file.path(dir, "vQTI.zip"), dtd = dtd)
}

