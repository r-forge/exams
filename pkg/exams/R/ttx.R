## function to create a html file with tth or ttm
## images are included by Base64 encoding
ttx <- function(x, images = NULL, base64 = TRUE, width = 600, body = TRUE,
  verbose = FALSE, template = "html-plain", translator = "ttm",
  inputs = ifelse(body, '-r -u -e2', '-u -r2 -e2'), ...)
{
  if(length(x) == 1L && file.exists(x[1L])) x <- readLines(x)

  ## setup necessary .tex file for tex4ht conversion
  if(!any(grepl("begin{document}", x, fixed = TRUE))) {
    template <- if(is.null(template) || template %in% c("html-plain", "plain")) {
      readLines(file.path(.find.package("exams"), "tex", "html-plain.tex"))
    } else readLines(template)
    i <- grep("%% \\exinput{latex}", template, fixed = TRUE)
    x <- c(template[1:(i - 1)], x, template[(i + 1):length(template)])
  }

  ## replacement of special environments
  environments <- list(Sinput = "verbatim", Soutput = "verbatim", Schunk = NULL, eqnarray = "align")
  for(e in names(environments)) {
    pattern <- paste("\\\\begin{", e, "}", sep = "")
    replacement <- paste("\\\\begin{", environments[[e]], "}", sep = "")
    x <- gsub(pattern, replacement, x, fixed = TRUE)
    pattern <- paste("\\\\end{", e, "}", sep = "")
    replacement <- paste("\\\\end{", environments[[e]], "}", sep = "")
    x <- gsub(pattern, replacement, x, fixed = TRUE)
  }

  ## create temp dir
  tempf <- tempfile()
  dir.create(tempf)
  owd <- getwd()
  setwd(tempf)
  on.exit(unlink(tempf, recursive = TRUE, force = TRUE))
  on.exit(setwd(owd), add = TRUE)

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
  #Z# Why do you do the resize conversion? One has control over the size
  #Z# within the original .Rnw anyway.

  ## create .html
  cmd <- paste(translator, inputs)
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
    require("base64")
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
    files <- list.files(tempf)
    imgs <- NULL
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
  y
}
