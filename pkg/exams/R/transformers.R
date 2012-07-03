## transforms the tex parts of exercise to images
## of arbitrary format using function tex2image()
make_exercise_transform_htmlimg <- function(x, base64 = TRUE, width = 550, ...)
{
  bsname <- if(is.null(x$metainfo$file)) basename(tempfile()) else x$metainfo$file
  sdir <- dirname(x$supplements[1])
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
  }
  x
}


## helper functions for exams2x()
## includes tex2image, tex4ht and tth conversion
make_exercise_transform_x <- function(converter = "img", base64 = TRUE, body = TRUE, width = 550, ...)
{
  if(converter %in% c("img", "image", "tex2image")) {
    foo <- function(x) {
      make_exercise_transform_htmlimg(x, base64, width, ...)
    }
  } else {
    foo <- function(x) {
      make_ex2x(x, converter, base64, body = body, width = width, ...)
    }
  }
  foo
}


## converter helper function
make_ex2x <- function(x, converter = "ttx", base64 = TRUE, ...)
{
  which <- list()
  for(i in c("question", "questionlist", "solution", "solutionlist"))
    if(!is.null(x[[i]]))
      which[[i]] <- x[[i]]
  x[names(which)] <- tmp <- ttx(which, images = x$supplements, ...)
  if(!base64 && !is.null(imgs <- attr(tmp, "images"))) {
    sdir <- dirname(x$supplements[1])
    for(i in imgs) {
      fp <- file.path(sdir, basename(i))
      file.copy(i, fp)
      if(!(fp %in% x$supplements))
        x$supplements <- c(x$supplements, fp)
    } 
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
