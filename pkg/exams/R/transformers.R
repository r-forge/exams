## helper transformator function,
## includes tex2image(), ttx() conversion
make_exercise_transform_x <- function(converter = "ttx", base64 = TRUE, body = TRUE, width = 550, ...)
{
  if(converter %in% c("img", "image", "tex2image"))
    return(function(x) make_exercise_transform_tex2image(x, base64, width, ...))
  else
    return(function(x) make_exercise_transform_ttx(x, base64, body = body, width = width, ...))
}


## transforms the tex parts of exercise to images
## of arbitrary format using function tex2image()
make_exercise_transform_tex2image <- function(x, base64 = TRUE, width = 550, ...)
{
  bsname <- if(is.null(x$metainfo$file)) basename(tempfile()) else x$metainfo$file
  sdir <- attr(x$supplements, "dir")
  if(length(x$supplements))
    x$supplements <- pdf2png4html(x$supplements, ...)
  images <- NULL
  for(i in c("question", "questionlist", "solution", "solutionlist")) {
    imgname <- paste(bsname, i , sep = "-")
    if(grepl("list", i)) {
      imgname <- paste(imgname, 1:length(x[[i]]), sep = "-")
      k <- seq_along(x[[i]])
    } else k <- list(seq_along(x[[i]]))
    if(length(k)) {
      for(j in 1:length(k)) {
        if(!is.null(x[[i]][k[[j]]])) {
          dir <- tex2image(x[[i]][k[[j]]], idir = sdir, show = FALSE, bsname = imgname[j], ...)
          imgpath <- file.path(sdir, basename(dir))
          if(base64) {
            require("base64")
            img <- base64::img(dir)
            alt <- grep('alt="image"', img)
            img[alt] <- gsub('alt="image"', paste('alt="image" width="', width, '"', sep = ''),
              img[alt], fixed = TRUE)
          } else {
            names(imgpath) <- imgname[j]
            file.copy(dir, imgpath)
            img <- paste('<img src="', imgpath, '" alt="', imgname[j], '" width="', width, '" />', sep = '')
          }
          if(grepl("list", i))
            x[[i]][k[[j]]] <- img
          else
            x[[i]] <- img
          if(!base64)
            images <- c(images, imgpath)
        }
      }
    }
  }
  if(!base64) {
    for(i in images) {
      fp <- file.path(sdir, basename(i))
      file.copy(i, fp)
      if(!(fp %in% x$supplements))
        x$supplements <- c(x$supplements, fp)
    }
    attr(x$supplements, "dir") <- sdir
  }
  x
}


## exercise conversion with ttx()
make_exercise_transform_ttx <- function(x, base64 = TRUE, ...)
{
  ## what need to be transormed with ttx()?
  what <- c(
    "question" = list(x$question),
    "questionlist" = as.list(x$questionlist),
    "solution" = list(x$solution),
    "solutionlist" = as.list(x$solutionlist)
  )

  ## guarantee same image widths
  set.img.width(x$supplements, list(...)$width)

  ## transform the .tex chunks
  trex <- ttx(what, images = x$supplements, base64 = base64, ...)
  namtrex <- names(trex)

  ## replace .tex chunks with ttx() output
  x$question <- trex$question
  x$questionlist <- sapply(trex[grep("questionlist", namtrex)], paste, collapse = "\n")
  x$solution <- trex$solution
  x$solutionlist <- sapply(trex[grep("solutionlist", namtrex)], paste, collapse = "\n")

  ## replace/copy possible images to exercise supplement directory
  if(!base64 && !is.null(imgs <- attr(trex, "images"))) {
    sdir <- attr(x$supplements, "dir")
    for(i in imgs) {
      fp <- file.path(sdir, basename(i))
      file.copy(i, fp)
      if(!(fp %in% x$supplements))
        x$supplements <- c(x$supplements, fp)
    }
    attr(x$supplements, "dir") <- sdir
  }

  x
}


## pdf to png conversion
pdf2png4html <- function(x, density = 350, ...)
{
  owd <- getwd()
  nx <- names(x)
  for(i in seq_along(x)) {
    if(file_ext(x[i]) == "pdf") {
      dx <- dirname(x)
      setwd(dx)
      bsx <- basename(x[i])
      to <- paste(file_path_sans_ext(bsx), "png", sep = ".")
      cmd <- paste("convert -density", density, bsx, to)
      system(cmd)
      file.remove(x[i])
      x[i] <- file.path(dx, to)
      nx[i] <- to
      setwd(owd)
    }
  }
  names(x) <- nx
  x
}


## function to set image widths
set.img.width <- function(x, width = 550) {
  if(!is.null(x) && file.exists(x[1])) {
    if(is.null(width))
      width <- 550
    owd <- getwd()
    dir <- dirname(x[1])
    setwd(dir)
    on.exit(setwd(owd))
    for(f in list.files(dir)) {
      if(file_ext(f) %in% c("jpg", "jpeg", "png", "tif")) {
        cmd <- paste("convert -resize ", width, "x ", f, " ", f, " > set.img.width.log", sep = "")
        system(cmd)
      }
    }
    ## remove possible .log files
    if(length(logf <- grep("log", file_ext(f <- list.files(dir)))))
      file.remove(f[logf]) 
  }
  invisible(NULL)
}
