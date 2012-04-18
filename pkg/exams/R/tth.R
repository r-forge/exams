## function to create a html file with tth
## images are included by Base64 encoding
tth <- function(x, images = NULL, base64 = TRUE, width = 600, body = TRUE, verbose = FALSE, ...)
{
  require("base64")

  if(file.exists(x[1]))
    x <- readLines(x)

  ## setup necessary .tex file for tex4ht conversion
  if(!any(grepl("documentclass", x)))
    x <- c("\\documentclass{article}\n", x)
  if(!any(grepl("begin{document}", x, fixed = TRUE)))
    x <- c("\\begin{document}\n", x)
  if(!any(grepl("end{document}", x, fixed = TRUE)))
    x <- c(x, "\\end{document}\n")

  x <- gsub("\\\\begin\\{Sinput}", "\\\\begin{verbatim}", x)
  x <- gsub("\\\\end\\{Sinput}", "\\\\end{verbatim}", x)
  x <- gsub("\\\\begin\\{Soutput}", "\\\\begin{verbatim}", x)
  x <- gsub("\\\\end\\{Soutput}", "\\\\end{verbatim}", x)
  x <- gsub("\\\\begin\\{Schunk}", "", x)
  x <- gsub("\\\\end\\{Schunk}", "", x)

  ## create temp dir
  tempf <- tempfile()
  dir.create(tempf)
  owd <- getwd()
  setwd(tempf)

  ## and copy & resize possible images
  if(length(images)) {
    images <- path.expand(images)
    bsimg <- basename(images)
    file.copy(images, file.path(tempf, bsimg)) 
    cmd <- paste("convert -resize ", width, "x ", bsimg, " ", bsimg, " > Rinternal.im.log", sep = "")
    check <- system(cmd)
    for(i in dirname(images))
      x <- gsub(i, "", x, fixed = TRUE)
    for(i in seq_along(bsimg))
      x <- gsub(file_path_sans_ext(bsimg[i]), bsimg[i], x, fixed = TRUE)
  }

  ## create .html
  cmd <- if(body) "tth -r -u -e2" else "tth -u -r2 -e2"
  if(!verbose)
    cmd <- paste(cmd, "2>/dev/null")
  y <- system(cmd, intern = TRUE, input = x)
  if(length(i <- grep("<br /><br /><hr /><small>File translated from", y, fixed = TRUE)))
    y <- c(y[1:(i - 1)], "</html>")

  y <- gsub('<div class="p"><!----></div>', "", y, fixed = TRUE)
  y <- y[-grep("^ *$", y)]    
  
  ## further image handling
  y <- paste(y, "\n", sep = "")
  if(base64) {
    irx <- '<img src="(.*.png)" alt=".*.png" />'
    iry <- paste(".*", irx, ".*", sep = "")
    imgs <-  grep(irx, y)
    for(i in imgs) {
      file <- sub(iry, "\\1", y[i])
      im64 <- base64::img(file)
      y[i] <- sub(irx, im64, y[i])
    }
  } else {
    ## copy images to directory for further processing
    imgdir <- tempfile()
    dir.create(imgdir)
    files <- list.files(tempf); imgs <- NULL
    for(i in files) {
      for(e in c(".png", ".jpg", ".gif")) {
        if(grepl(e, i, ignore.case = TRUE)) {
          file.copy(i, file.path(imgdir, i))
          imgs <- c(imgs, file.path(imgdir, i))
        }
      }
    }
    attr(y, "images") <- imgs
  }

  ## remove tmp file
  unlink(tempf, recursive = TRUE, force = TRUE)

  setwd(owd)
  y
}
