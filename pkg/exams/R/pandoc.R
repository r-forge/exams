## helper transformator function (FIXME: which output formats can handle base64?)
make_exercise_transform_pandoc <- function(to = "latex", base64 = to != "latex", ...)
{
  ## base64 checks
  if(is.null(base64)) base64 <- TRUE
  base64 <- if(is.logical(base64) && base64) {
    c("bmp", "gif", "jpeg", "jpg", "png")
  } else {
    if(is.logical(base64)) NA  else tolower(base64)
  }
  if(b64 <- !all(is.na(base64))) stopifnot(requireNamespace("base64enc"))

  ## function to apply ttx() on every
  ## element of a list in a fast way
  apply_pandoc_on_list <- function(object, from = "markdown",
    sep = "\007\007\007\007\007", ...)
  {
    ## add seperator as last line to each chunk
    object <- lapply(object, c, c("", sep, ""))

    ## call ttx() on collapsed chunks
    infile <- tempfile()
    outfile <- tempfile()
    writeLines(unlist(object), infile)
    rmarkdown::pandoc_convert(input = infile, output = outfile,
      from = from, to = to, ...)
    rval <- readLines(outfile)

    ## split chunks again on sep
    ix <- grepl(sep, rval, fixed = TRUE)
    rval <- split(rval, c(0, head(cumsum(ix), -1L)))
    names(rval) <- rep(names(object), length.out = length(rval))

    ## omit sep from last line in each chunk
    cleansep <- function(x) {
      n <- length(x)
      if(n < 1L) return(x)
      del <- c(
        if(x[1L] == "") 1L else NULL,
        if(x[n] == sep && x[n - 1L] == "") n - 1L else NULL,
	if(x[n] == sep) n else NULL
      )
      if(length(del) > 0L) return(x[-del]) else return(x)
    }
    rval <- lapply(rval, cleansep)

    rval
  }

  ## exercise conversion with pandoc
  function(x)
  {
    owd <- getwd()
    setwd(sdir <- attr(x$supplements, "dir"))

    ## what need to be transormed with pandoc?
    what <- c(
      "question" = list(x$question),
      "questionlist" = as.list(x$questionlist),
      "solution" = list(x$solution),
      "solutionlist" = as.list(x$solutionlist)
    )

    ## transform the .tex chunks
    trex <- if(x$metainfo$markup != to) {
      apply_pandoc_on_list(what, from = x$metainfo$markup, ...)
    } else {
      what
    }
    namtrex <- names(trex)

    ## base64 image/supplements handling
    if(b64 && length(sfiles <- dir(sdir))) {
      for(sf in sfiles) {
  	for(i in seq_along(trex)) {
  	  if(length(j <- grep(sf, trex[[i]], fixed = TRUE)) && file_ext(sf) %in% base64) {
  	    base64i <- fileURI(file = sf)
  	    trex[[i]][j] <- gsub(paste(sf, '"', sep = ''),
  	      paste(base64i, '"', sep = ""), trex[[i]][j], fixed = TRUE)
  	    file.remove(file.path(sdir, sf))
  	    x$supplements <- x$supplements[!grepl(sf, x$supplements)]
  	  }
  	}
      }
      attr(x$supplements, "dir") <- sdir
    }

    ## replace .tex chunks with tth(), ttm() output
    x$question <- trex$question
    x$questionlist <- unname(sapply(trex[grep("questionlist", namtrex)], paste, collapse = "\n"))
    x$solution <- trex$solution
    x$solutionlist <- unname(sapply(trex[grep("solutionlist", namtrex)], paste, collapse = "\n"))

    for(j in c("question", "questionlist", "solution", "solutionlist")) {
      if(length(x[[j]]) < 1L) x[j] <- structure(list(NULL), .Names = j)
    }

    setwd(owd)

    x$metainfo$markup <- to
    return(x)
  }
}
