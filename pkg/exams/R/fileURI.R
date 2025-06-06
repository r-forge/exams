## see mime types at
## https://www.iana.org/assignments/media-types/media-types.xhtml
.fileURI_mime_types <- matrix(c(

  "bmp", "image/bmp",
  "png", "image/png",
  "jpg", "image/jpeg",
  "jpeg","image/jpeg",
  "gif", "image/gif",
  "heic","image/heic",
  "svg", "image/svg+xml",
  "wmf", "image/wmf",

  "doc", "application/msword",
  "docx","application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "css", "text/css",
  "htm", "text/html",
  "html","text/html",
  "pdf", "application/pdf",
  "rtf", "application/rtf",
  "tex", "application/x-tex",
  "txt", "text/plain",
  "xml", "application/xml",

  "c",   "text/plain",
  "js",  "text/javascript",
  "py",  "text/plain",
  "r",   "text/plain",
  "rmd", "text/plain",

  "csv", "text/csv",
  "dta", "application/octet-stream",
  "ods", "application/vnd.oasis.opendocument.spreadsheet",
  "raw", "text/plain",
  "rda", "application/octet-stream",
  "rds", "application/octet-stream",
  "sav", "application/octet-stream",
  "tsv", "text/tab-separated-values",
  "xls", "application/vnd.ms-excel",
  "xlsx","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "zip", "application/zip",

  "3dm", "model/vnd.3dm"
), ncol = 2L, byrow = TRUE, dimnames = list(NULL, c("ext", "mime")))


fileURI <- function(file) {
  f_ext <- tolower(file_ext(file))
  if(any(ix <- f_ext == .fileURI_mime_types[, "ext"])) {
    rval <- base64enc::dataURI(file = file, mime = .fileURI_mime_types[ix, "mime"])
  } else {
    owd <- getwd()
    setwd(dirname(file))
    zip(zipfile = zipname <- paste(file_path_sans_ext(basename(file)), "zip", sep = "."),
      files = basename(file))
    rval <- base64enc::dataURI(file = zipname, mime = "application/zip")
    setwd(owd)
  }
  rval
}
