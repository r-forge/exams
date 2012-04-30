## function to create a html file with tex4ht
## math may be represented with the jsMath functionality
## images are included by Base64 encoding
tex4ht <- function(x, images = NULL, width = 600, jsmath = TRUE,
  body = TRUE, bsname = "tex4ht-Rinternal", template = "html-plain",
  tdir = NULL, verbose = FALSE, base64 = TRUE, ...)
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
  tempf <- if(is.null(tdir)) tempfile() else path.expand(tdir)
  if(!file.exists(tempf))
    dir.create(tempf, showWarnings = FALSE)
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

  ## write .tex file
  writeLines(x, paste(bsname, "tex", sep = "."))

  ## create html with jsMath
  if(verbose) cat("***** START COMPILING WITH TEX4HT *****\n")
  cmd <- paste("htlatex", file_path_sans_ext(bsname),
    if(jsmath) "\"html,jsmath\" \" -cmozhtf\"" else "\"html\" \" -cmozhtf\"")
  if(!verbose) cmd <- paste(cmd, "> Rinternal.tex4ht.log")
  log <- system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
  if(verbose) cat("************** END TEX4HT *************\n")
  y <- readLines(file.path(tempf, paste(bsname, "html", sep = ".")))
  #Z# Code above slightly streamlined

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

  ## further image handling
  if(base64 && length(i <- grep("src=\"", y, fixed = TRUE))) {
    fimg <- tempfile()
    for(j in i) {
      for(e in c(".png", ".jpg", ".gif")) {
        if(grepl(e, y[j], ignore.case = TRUE)) {
          file <- alt <- strsplit(y[j], "src=\"")[[1]][2]
          alt <- strsplit(alt, "alt=\"")[[1]][2]
          file <- paste(strsplit(file, e)[[1]][1], e, sep = "")
          ## need to copy image, since long names don't work with img
          file.copy(file.path(tempf, file), fimg, overwrite = TRUE)
          file <- base64::img(fimg)
          file <- gsub("<img ", "", file, fixed = TRUE)
          file <- gsub("image\" />", alt, file, fixed = TRUE)
          y[j] <- file
        }
      }
    }
    unlink(fimg, force = TRUE)
  }
  #Z# Why is the extra file.copy() necessary above but not in tth()?

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
  ## y <- gsub('<p class="indent" >', '', y)
  ## y <- gsub('<p class="noindent" >', '', y)
  #Z# Can these be avoided by changing the template to something else?
  #Z# Some users may like the indentation and use a corresponding template...

  ## copy images to directory for further processing
  if(!base64) {
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
