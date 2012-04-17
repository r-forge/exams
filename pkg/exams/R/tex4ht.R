## function to create a html file with tex4ht
## math may be represented with the jsMath functionality
## images are included by Base64 encoding
tex4ht <- function(x, images = NULL, width = 600, jsmath = TRUE,
  body = TRUE, bsname = "tex4ht-Rinternal", template = NULL,
  tdir = NULL, verbose = FALSE, ...)
{
  require("base64")
  if(file.exists(x[1]))
    x <- readLines(x)

  ## setup necessary .tex file for tex4ht conversion
  if(!any(grepl("begin{document}", x, fixed = TRUE))) {
    ## include templates
    if(is.null(template)) {
      template <- c(
      "\\usepackage[ngerman]{babel}",
      "\\usepackage{a4wide, Sweave, verbatim}",
      "\\usepackage[latin1]{inputenc}",
      "\\usepackage[T1]{fontenc}", 
      "\\usepackage{amsmath,amssymb,amsfonts}",
      "\\usepackage{graphicx}",
      "\\usepackage{fancybox}",
      "\\usepackage{slashbox, booktabs}",
      "\\usepackage{array}",
      "\\usepackage{hyperref}",
      "\\pagestyle{empty}",
      "\\usepackage{color}"
      )
    }
    x <- c("\\documentclass{article}", template, "\\begin{document}", x, "\\end{document}")
  }

  x <- gsub("\\\\begin\\{Sinput}", "\\\\begin{verbatim}", x)
  x <- gsub("\\\\end\\{Sinput}", "\\\\end{verbatim}", x)
  x <- gsub("\\\\begin\\{Soutput}", "\\\\begin{verbatim}", x)
  x <- gsub("\\\\end\\{Soutput}", "\\\\end{verbatim}", x)
  x <- gsub("\\\\begin\\{Schunk}", "", x)
  x <- gsub("\\\\end\\{Schunk}", "", x)

  ## remove eqnarray environment
  if(jsmath)
    x <- gsub("eqnarray", "align", x, fixed = TRUE)

  ## create temp dir
  tempf <- if(is.null(tdir)) tempfile() else path.expand(tdir)
  if(!file.exists(tempf))
    dir.create(tempf, showWarnings = FALSE)
  owd <- getwd()
  setwd(tempf)

  ## and copy & resize possible images
  imgnxhtml <- NULL
  if(length(images)) {
    if(is.character(images))
      images <- read_images(images)
    imgn <- names(images)
    for(i in file_path_sans_ext(imgn)) {
      if(length(d <- grep(i, x, fixed = TRUE))) {
        j <- grep(i, imgn, fixed = TRUE)
        x[d] <- gsub(i, imgn[j], x[d], fixed = TRUE)
        writeBin(images[[j]], imgn[j])
        cmd <- paste("convert -resize ", width, "x ", imgn[j], " ", imgn[j], " > ", imgn[j], ".log", sep = "")
        system(cmd)
        imgnxhtml <- c(imgnxhtml, imgn[j])
      }
    }
  }

  ## write .tex file
  writeLines(x, paste(bsname, "tex", sep = "."))

  ## create html with jsMath
  if(verbose)
    cat("***** START COMPILING WITH TEX4HT *****\n")
  if(jsmath)
    cmd <- paste("htlatex", file_path_sans_ext(bsname), "\"html,jsmath\" \" -cmozhtf\"")
  else
    cmd <- paste("htlatex", file_path_sans_ext(bsname), "\"html\" \" -cmozhtf\"")
  if(!verbose)
    cmd <- paste(cmd, "> Rinternal.tex4ht.log")
  log <- system(cmd)
  if(verbose)
    cat("************** END TEX4HT *************\n")
  y <- readLines(file.path(tempf, paste(bsname, "html", sep = ".")))

  ## get ccs file
  css <- if(any(grepl(".css", list.files()))) readLines(file.path(tempf, paste(bsname, "css", sep = "."))) else NULL
  if(length(i <- grep("p.indent{ text-indent: 1.5em }", css, fixed = TRUE)))
    css[i] <- "p.indent{ text-indent: 0em }"

  ## inline css
  if(!is.null(css)) {
    if(length(i <- grep("<link rel=\"stylesheet\" type=\"text/css\" href=\"", y, fixed = TRUE))) {
      a <- y[1:(i - 1)]
      b <- y[(i + 1):length(y)]
      y <- c(a, "<style>", "<!--", css, "-->", "</style>", b)
    }
  }

  ## base64 encoding of images
  if(length(i <- grep("src=\"", y, fixed = TRUE))) {
    fimg <- tempfile()
    for(j in i) {
      for(e in c(".png", ".jpg", ".gif")) {
        if(grepl(e, y[j], ignore.case = TRUE)) {
          file <- alt <- strsplit(y[j], "src=\"")[[1]][2]
          alt <- strsplit(alt, "alt=\"")[[1]][2]
          file <- paste(strsplit(file, e)[[1]][1], e, sep = "")
          ## need to copy image, since long names don't work with img
          file.copy(file.path(getwd(), file), fimg, overwrite = TRUE)
          file <- base64::img(fimg)
          file <- gsub("<img ", "", file, fixed = TRUE)
          file <- gsub("image\" />", alt, file, fixed = TRUE)
          y[j] <- file
        }
      }
    }
    unlink(fimg, force = TRUE)
  }

  #if(!is.null(imgnxhtml)) {
  #  for(i in imgnxhtml) {
  #    j <- grep(i, y, fixed = TRUE)
  #    tf <- tempfile()
  #    on.exit(unlink(tf), add = TRUE)
  #    base64::encode(i, tf)
  #    im64 <- paste("data:image/", file_ext(i), ";base64,\n",
  #      paste(readLines(tf), collapse = "\n"), sep = "")
  #    y[j] <- sub(i, im64, y[j], fixed = TRUE)
  #  }
  #}

  ## get only body context
  if(body) {
    if(length(i <- grep('</noscript>', y))) {
      y <- y[(i + 1):length(y)]
      i <- grep('<script type="text/javascript" >', y)
      y <- y[1:(i - 1)]
    } else {
      i <- grep("<body", y)
      y <- y[(i + 2):length(y)]
      i <- grep("</body>", y)
      y <- y[1:(i - 1)]
    }
  }

  ## remove indent tags
  y <- gsub('<p class="indent" >', '', y)
  y <- gsub('<p class="noindent" >', '', y)

  ## remove blank lines
  y <- y[-grep("^ *$", y)]

  ## remove tmp file
  unlink(tempf, recursive = TRUE, force = TRUE)

  setwd(owd)
  y
}
