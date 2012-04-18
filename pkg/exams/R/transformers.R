## transforms the tex parts of exercise to images
## of arbitrary format using function tex2image()
make_exercise_transform_html_img <- function(x, base64 = TRUE, width = 550, ...)
{
  bsname <- if(is.null(x$metainfo$file)) basename(tempfile()) else x$metainfo$file
  sdir <- attr(x$supplements, "dir")
  images <- NULL
  for(i in c("question", "questionlist", "solution", "solutionlist")) {
    imgname <- paste(bsname, i , sep = "-")
    if(grepl("list", i)) {
      imgname <- paste(imgname, 1:length(x[[i]]), sep = "-")
      k <- seq_along(x[[i]])
    } else k <- list(seq_along(x[[i]]))
    if(length(k)) {
      for(j in 1:length(k)) {
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
  if(!base64)
    x$supplements <- images
  x
}


## transforms the tex parts of exercise to html using tex4ht()
make_exercise_transform_html_tex4ht <- function(x, ...)
{
  x <- make_ex2html(x, converter = "tex4ht", ...)
  x
}


## transforms the tex parts of exercise to html using tth()
make_exercise_transform_html_tth <- function(x, ...)
{
  x <- make_ex2html(x, converter = "tth", ...)
  x
}


## helper functions for exams2html
## includes tex2image, tex4ht and tth conversion
make_exercise_transform_html <- function(converter = "img", base64 = TRUE, body = TRUE, width = 550, ...)
{
  if(converter %in% c("img", "image", "tex2image")) {
    foo <- function(x) {
      make_exercise_transform_html_img(x, base64, width, ...)
    }
  } else {
    foo <- function(x) {
      make_ex2html(x, converter, base64 = base64, body = body, width = width, ...)
    }
  }
  foo
}


## html converter helper function
## for tex4ht and tth conversion
make_ex2html <- function(x, converter = "tex4ht", ...)
{
  args <- list(...)
  if(length(x$supplements))
    args$images <- pdf2png4html(x$supplements, ...)
  bsname <- if(is.null(x$metainfo$file)) basename(tempfile()) else x$metainfo$file
  sdir <- attr(x$supplements, "dir")
  for(i in c("question", "questionlist", "solution", "solutionlist")) {
    texname <- paste(bsname, i , sep = "-")
    if(grepl("list", i)) {
      texname <- paste(texname, 1:length(x[[i]]), sep = "-")
      k <- seq_along(x[[i]])
    } else k <- list(seq_along(x[[i]]))
    if(length(k)) {
      for(j in 1:length(k)) {
        if(!is.null(x[[i]][k[[j]]])) {
          args$x <- x[[i]][k[[j]]]
          args$bsname <- texname[j]
          html <- do.call(converter, args)
          imgs <- attr(html, "images")
          attr(html, "images") <- NULL
          if(grepl("list", i))
            x[[i]][k[[j]]] <- paste(html, collapse = "\n", sep = "")
          else 
            x[[i]] <- html
          if(!is.null(imgs)) {
            file.copy(imgs, file.path(sdir, basename(imgs)), overwrite = TRUE)
            for(jj in imgs)
              if(!any(grepl(basename(jj), x$supplements)))
                x$supplements <- c(x$supplements, file.path(sdir, basename(jj)))
          }
        }
      }
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
