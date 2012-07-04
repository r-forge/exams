## function to apply ttx() on every
## element of a list in a fast way
apply_ttx_on_list <- function(object,
  sep = "\\007\\007\\007\\007\\007", ...)
{
  ## add seperator as last line to each chunk
  object <- lapply(object, "c", sep)

  ## call ttx() on collapsed chunks
  rval <- tmp <- ttx(unlist(object), ...)

  ## split chunks again on sep
  ix <- substr(rval, 1, nchar(sep)) == sep
  rval <- split(rval, c(0, head(cumsum(ix), -1L)))
  names(rval) <- names(object)

  ## omit last line in each chunk (containing sep) again
  rval <- lapply(rval, head, -1L)

  ## store ttx images
  attr(rval, "images") <- attr(tmp, "images")

  rval
}


## function to create a html file with tth or ttm
## images are included by Base64 encoding
ttx <- function(tex, images = NULL, base64 = TRUE, width = 600, body = TRUE,
  verbose = FALSE, template = "html-plain", tdir = NULL, translator = "ttm",
  opts = ifelse(body, '-r -u -e2', '-u -r2 -e2'), ...)
{
  if(is.list(tex)) {
    return(apply_ttx_on_list(tex, images = images, base64 = base64, width = width,
      body = body, verbose = verbose, template = template, tdir = tdir,
      translator = translator, opts = opts, ...))
  }

  if(length(tex) == 1L && file.exists(tex[1L])) {
    tdir <- dirname(tex)
    tex <- readLines(tex)
  }

  ## setup necessary .tex file for tex4ht conversion
  if(!any(grepl("begin{document}", tex, fixed = TRUE))) {
    template <- if(is.null(template) || template %in% c("html-plain", "plain")) {
      readLines(file.path(.find.package("exams"), "tex", "html-plain.tex"))
    } else readLines(template)
    i <- grep("%% \\exinput{latex}", template, fixed = TRUE)
    tex <- c(template[1:(i - 1)], tex, template[(i + 1):length(template)])
  }

  ## replacement of special environments
  environments <- list(Sinput = "verbatim", Soutput = "verbatim", Schunk = NULL, eqnarray = "align")
  for(e in names(environments)) {
    pattern <- paste("\\\\begin{", e, "}", sep = "")
    replacement <- paste("\\\\begin{", environments[[e]], "}", sep = "")
    tex <- gsub(pattern, replacement, tex, fixed = TRUE)
    pattern <- paste("\\\\end{", e, "}", sep = "")
    replacement <- paste("\\\\end{", environments[[e]], "}", sep = "")
    tex <- gsub(pattern, replacement, tex, fixed = TRUE)
  }

  ## create temp dir
  if(is.null(tdir)) {
    dir.create(tempf <- tempfile())
    on.exit(unlink(tempf, recursive = TRUE, force = TRUE))
  } else tempf <- path.expand(tdir)
  if(!file.exists(tempf))
    dir.create(tempf, showWarnings = FALSE)
  owd <- getwd()
  setwd(tempf)
  on.exit(setwd(owd), add = TRUE)

  ## and copy & resize possible images
  if(length(images)) {
    images <- path.expand(images)
    bsimg <- basename(images)
    file.copy(images, file.path(tempf, bsimg)) 
    cmd <- paste("convert -resize ", width, "x ", bsimg, " ", bsimg, " > Rinternal.im.log", sep = "")
    system(cmd)
    for(i in dirname(images))
      tex <- gsub(i, "", tex, fixed = TRUE)
    for(i in seq_along(bsimg))
      tex <- gsub(file_path_sans_ext(bsimg[i]), bsimg[i], tex, fixed = TRUE)
  }
  #Z# Why do you do the resize conversion? One has control over the size
  #Z# within the original .Rnw anyway.

  ## create .html
  cmd <- paste(translator, opts)
  if(!verbose)
    cmd <- paste(cmd, "2>/dev/null")
  y <- system(cmd, intern = TRUE, input = tex)

  if(length(i <- grep("<br /><br /><hr /><small>File translated from", y, fixed = TRUE)))
    y <- c(y[1:(i - 1)], "</html>")

  y <- gsub('<div class="p"><!----></div>', "", y, fixed = TRUE)
  y <- y[-grep("^ *$", y)]    
  
  ## further image handling
  y <- paste(y, "\n", sep = "")
  if(!is.null(opts) && grepl("-e2", opts, fixed = TRUE) && base64) {
    require("base64")
    irx <- '<img src="(.*.png)" alt=".*.png" />'
    iry <- paste(".*", irx, ".*", sep = "")
    imgs <- grep(irx, y)
    for(i in imgs) {
      file <- sub(iry, "\\1", y[i])
      cmd <- paste("convert -resize ", width, "x ", file, " ", file, " > Rinternal.im.log", sep = "")
      system(cmd)
      im64 <- base64::img(file)
      y[i] <- sub(irx, im64, y[i])
    }

    ## remove all other files than .html
    for(e in c("pdf", "png", "gif", "tif", "jpg", "jpeg"))
      if(length(logf <- grep(e, file_ext(list.files(tempf)))))
        file.remove(list.files(tempf)[logf])  
  } else {
    ## FIXME problem with file endings, since latex may supress them
    ## converting other possible images stored as .pdf,
    ## caused if option -e2 is turned off in argument opts
    if(is.null(opts)) {
      if(length(pdfs <- grep("pdf", file_ext(lf <- list.files(tempf))))) {
        pngs <- paste(file_path_sans_ext(pdfs <- lf[pdfs]), "png", sep = ".")
        for(i in seq_along(pdfs)) {
          cmd <- paste("convert -resize ", width, "x ", pdfs[i], " ",
            pngs[i], " > Rinternal.im.log", sep = "")
          system(cmd)
        }
        file.copy(pngs, file_path_sans_ext(pngs))
      }
    }

    ## copy images to directory for further processing
    imgdir <- tempfile()
    dir.create(imgdir)
    files <- list.files(tempf)
    imgs <- NULL
    for(i in files) {
      for(e in c("png", "jpg", "gif")) {
        if(grepl(e, file_ext(i), ignore.case = TRUE)) {
          cmd <- paste("convert -resize ", width, "x ", i, " ", i, " > Rinternal.im.log", sep = "")
          system(cmd)
          file.copy(i, file.path(imgdir, i))
          imgs <- c(imgs, file.path(imgdir, i))
        }
      }
    }
    attr(y, "images") <- imgs
  }

  ## remove possible .log files
  if(length(logf <- grep("log", file_ext(list.files(tempf)))))
    file.remove(list.files(tempf)[logf])  

  y
}
