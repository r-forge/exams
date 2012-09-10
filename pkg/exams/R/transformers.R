## helper transformator function,
## includes tex2image(), tth() and ttm() .html conversion
make_exercise_transform_html <- function(converter = c("ttm", "tth", "tex2image"), base64 = TRUE, ...)
{
  converter <- match.arg(converter)
  if(base64) stopifnot(require("base64enc"))
  if(converter %in% c("tth", "ttm")) stopifnot(require("tth"))

  if(converter == "tex2image") {
    ## transforms the tex parts of exercise to images
    ## of arbitrary format using function tex2image()
    function(x)
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
            if(!is.null(x[[i]][k[[j]]])) {
              dir <- tex2image(x[[i]][k[[j]]], idir = sdir, show = FALSE, bsname = imgname[j], ...)
              imgpath <- file.path(sdir, basename(dir))
              if(base64) {
                img <- sprintf('<img src="%s" alt="%s" />', dataURI(file = dir, mime = "image/png"), dir)
                for(sf in dir(sdir)) {
                  if(length(grep(file_ext(sf), c("png", "jpg", "jpeg", "gif"), ignore.case = TRUE))) {
                    if(length(grep(file_path_sans_ext(sf), x[[i]][k[[j]]], fixed = TRUE))) {
                      file.remove(file.path(sdir, sf))
                      x$supplements <- x$supplements[!grepl(sf, x$supplements)]
                      attr(x$supplements, "dir") <- sdir        
                    }
                  }
                }
              } else {
                names(imgpath) <- imgname[j]
                file.copy(dir, imgpath)
                img <- paste('<img src="', imgpath, '" alt="', imgname[j], '" />', sep = '')
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
  } else {
    ## function to apply ttx() on every
    ## element of a list in a fast way
    apply_ttx_on_list <- function(object, converter = "ttm",
      sep = "\\007\\007\\007\\007\\007", ...)
    {
      ## add seperator as last line to each chunk
      object <- lapply(object, "c", sep)

      ## call ttx() on collapsed chunks
      rval <- tmp <- do.call(converter, list("x" = unlist(object), ...))

      ## split chunks again on sep
      ix <- substr(rval, 1, nchar(sep)) == sep
      rval <- split(rval, c(0, head(cumsum(ix), -1L)))

      ## FIXME: length of rval may be smaller than the length of object?
      names(rval) <- rep(names(object), length.out = length(rval))

      ## omit last line in each chunk (containing sep) again
      rval <- lapply(rval, head, -1L)

      ## store ttx images
      attr(rval, "images") <- attr(tmp, "images")

      rval
    }

    ## exercise conversion with ttx()
    function(x)
    {
      owd <- getwd()
      setwd(sdir <- attr(x$supplements, "dir"))

      ## what need to be transormed with ttx()?
      what <- c(
        "question" = list(x$question),
        "questionlist" = as.list(x$questionlist),
        "solution" = list(x$solution),
        "solutionlist" = as.list(x$solutionlist)
      )

      ## transform the .tex chunks
      args <- list("x" = what, ...)
      trex <- apply_ttx_on_list(what, converter, ...)
      namtrex <- names(trex)

      ## base64 image handling
      if(base64 && length(sfiles <- dir(sdir))) {
        for(sf in sfiles) {
          if(length(grep(file_ext(sf), c("png", "jpg", "jpeg", "gif"), ignore.case = TRUE))) {
            for(i in seq_along(trex)) {
              if(length(j <- grep(sf, trex[[i]], fixed = TRUE))) {
                base64i <- dataURI(file = sf, mime = "image/png")
                trex[[i]][j] <- gsub(paste('src="', sf, '"', sep = ''),
                  paste('src="', base64i, '"', sep = ""), trex[[i]][j], fixed = TRUE)
                file.remove(file.path(sdir, sf))
                x$supplements <- x$supplements[!grepl(sf, x$supplements)]
              }
            }
          }
        }
        attr(x$supplements, "dir") <- sdir
      }

      ## replace .tex chunks with tth(), ttm() output
      x$question <- trex$question
      x$questionlist <- sapply(trex[grep("questionlist", namtrex)], paste, collapse = "\n")
      x$solution <- trex$solution
      x$solutionlist <- sapply(trex[grep("solutionlist", namtrex)], paste, collapse = "\n")

      setwd(owd)

      x
    }
  }
}

