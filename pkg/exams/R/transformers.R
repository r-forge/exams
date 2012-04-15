## transforms the tex parts of exercise to images
## of arbitrary format using function tex2image()
ex2image <- function(x, ...)
{
  ## data handling
  images <- NULL
  bsname <- if(is.null(x$metainfo$name)) basename(tempfile()) else gsub("\\s", "-", x$metainfo$name)
  if(!length(x$supplements)) {
    sdir <- tempfile()
    dir.create(sdir)
  } else sdir <- dirname(x$supplements)

  ## transform question
  if(length(x$question)) {
    imgname <- paste(bsname, "question", sep = "-")
    dir <- tex2image(x$question, idir = sdir, show = FALSE, bsname = imgname, ...)
    imgpath <- file.path(sdir, imgname)
    names(imgpath) <- imgname
    file.copy(dir, imgpath)
    x$question <- imgpath
    images <- c(images, imgpath)
  }

  ## transform questionlist
  if(length(x$questionlist)) {
    for(k in seq_along(x$questionlist)) {
      imgname <- paste(bsname, "questionlist", k, sep = "-")
      dir <- tex2image(x$questionlist[k], idir = sdir, show = FALSE, bsname = imgname, ...)
      imgpath <- file.path(sdir, imgname)
      names(imgpath) <- imgname
      file.copy(dir, imgpath)
      x$questionlist[k] <- imgpath
      images <- c(images, imgpath)
    }
  }

  ## transform solution
  if(length(x$solution)) {
    imgname <- paste(bsname, "solution", sep = "-")
    dir <- tex2image(x$solution, idir = sdir, show = FALSE, bsname = imgname, ...)
    imgpath <- file.path(sdir, imgname)
    names(imgpath) <- imgname
    file.copy(dir, imgpath)
    x$solution <- imgpath
    images <- c(images, imgpath)
  }

  ## transform solutionlist
  if(length(x$solutionlist)) {
    for(k in seq_along(x$solutionlist)) {
      imgname <- paste(bsname, "solutionlist", k, sep = "-")
      dir <- tex2image(x$solutionlist[k], idir = sdir, show = FALSE, bsname = imgname, ...)
      imgpath <- file.path(sdir, imgname)
      names(imgpath) <- imgname
      file.copy(dir, imgpath)
      x$solutionlist[k] <- imgpath
      images <- c(images, imgpath)
    }
  }

  ## overwrite supplements
  x$supplements <- images

  class(x) <- c("img", "list")
  x
}


## transforms the tex parts of exercise to html
## using tex4ht() or tth(), images are included
## using base64 encoding
ex2html <- function(x, converter = "tex4ht", ...)
{
  args <- list(...)
  args$images <- x$supplements

  ## data handling
  images <- NULL
  bsname <- if(is.null(x$metainfo$name)) basename(tempfile()) else gsub("\\s", "-", x$metainfo$name)
  if(!length(x$supplements)) {
    sdir <- tempfile()
    dir.create(sdir)
  } else sdir <- dirname(x$supplements)

  ## transform question
  if(length(x$question)) {
    args$x <- x$question
    args$bsname <- paste(bsname, "question", sep = "-")
    x$question <- do.call(converter, args)
  }

  ## transform questionlist
  if(length(x$questionlist)) {
    for(k in seq_along(x$questionlist)) {
      args$x <- x$questionlist[k]
      args$bsname <- paste(bsname, "questionlist", k, sep = "-")
      x$questionlist[k] <- do.call(converter, args)
    }
  }

  ## transform solution
  if(length(x$solution)) {
    args$x <- x$solution
    args$bsname <- paste(bsname, "solution", sep = "-")
    x$solution <- do.call(converter, args)
  }

  ## transform solutionlist
  if(length(x$solutionlist)) {
    for(k in seq_along(x$solutionlist)) {
      args$x <- x$solutionlist[k]
      args$bsname <- paste(bsname, "solutionlist", k, sep = "-")
      x$solutionlist[k] <- do.call(converter, args)
    }
  }

  ## overwrite supplements
  x$supplements <- character(0)

  class(x) <- c("html", "list")
  x
}
