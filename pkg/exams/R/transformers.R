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
  x <- make_ex2html(x, converter = "tex4ht", base64 = FALSE, ...)
  x
}


## transforms the tex parts of exercise to html using tth()
make_exercise_transform_html_tth <- function(x, ...)
{
  x <- make_ex2html(x, converter = "tth", ...)
  x
}


## html converter helper function
make_ex2html <- function(x, converter = "tex4ht", ...)
{
  args <- list(...)
  if(length(x$supplements))
    args$images <- x$supplements
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
        args$x <- x[[i]][k[[j]]]
        args$bsname <- texname[j]
        html <- do.call(converter, args)
        if(grepl("list", i))
          x[[i]][k[[j]]] <- html
        else 
          x[[i]] <- html
        if(!is.null(attr(html, "images"))) {
          for(i in attr(html, "images")) {
            if(length(grep(basename(i), list.files(sdir))) < 1) {
              file.copy(i, file.path(sdir, basename(i)))
              x$supplements <- c(x$supplements, i)
            }
          }
        }
      }
    }
  }
  x
}
