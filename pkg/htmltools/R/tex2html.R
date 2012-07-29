TTH <- TTM <- ""

.onLoad <- function(libname, pkgname) {
    
    ## command line options should be arguments of tth(), current
    ## version is proof of concept
    if(length(tthpath <- find.package("tth", quiet=TRUE))) {
        if(.Platform$OS.type == "windows") {
            TTH <<- file.path(tthpath, "libs", .Platform$r_arch, "tth.exe -r -u -e2 -y0")
            TTM <<- file.path(tthpath, "libs", .Platform$r_arch, "ttm.exe -r -u -e2 -y0")
        } else {
            TTH <<- file.path(tthpath, "libs", .Platform$r_arch, "tth -r -u -e2 -y0")
            TTM <<- file.path(tthpath, "libs", .Platform$r_arch, "ttm -r -u -e2 -y0")
        }
    } else {
        if(.Platform$OS.type == "windows") {
            TTH <<- "tth.exe -r -u -e2 -y0"
            TTM <<- "ttm.exe -r -u -e2 -y0"
        } else {
            TTH <<- "tth -r -u -e2 -y0"
            TTM <<- "ttm -r -u -e2 -y0"
        }
        test <- try(system(htmltools:::TTH, input = "Try running tth!",
                           intern = TRUE, ignore.stderr = TRUE), silent=TRUE)
        if(inherits(test, "try-error"))
           stop("Cannot find R package tth or command line untility tth!\n",
                "Please install suggested R package tth from CRAN.\n")
    }
}

tth <- function(x, ..., delblanks = TRUE)
{
    y <- system(paste(htmltools:::TTH, tth.control(...)),
      input = x, intern = TRUE, ignore.stderr = TRUE)
    if(delblanks) y <- y[-grep("^ *$", y)]
    return(y)
}

ttm <- function(x, ..., delblanks = TRUE)
{
    y <- system(paste(htmltools:::TTM, tth.control(...)),
      input = x, intern = TRUE, ignore.stderr = TRUE)
    if(delblanks) y <- y[-grep("^ *$", y)]    
    return(y)
}

tth.control <- function(a = FALSE, c = FALSE, d = FALSE, e = 2, f = NULL, g = FALSE,
  i = FALSE, j = NULL, L = NULL, n = NULL, p = NULL, r = TRUE, t = FALSE, u = FALSE,
  w = NULL, y = 2, xmakeindxcmd = NULL, v = FALSE)
{
  ## collect all arguments
  rval <- list(a = a, c = c, d = d, e = e, f = f, g = g, i = i, j = j, L = L,
    n = n, p = p, r = r, t = t, u = u, w = w, y = y, xmakeindxcmd = xmakeindxcmd, v = v)

  ## sanity checking depending on type
  if(!is.null(rval[["v"]])) {
    if(is.numeric(rval[["v"]])) {
      if(rval[["v"]] > 1L) {
        rval[["V"]] <- TRUE
	rval[["v"]] <- NULL
      } else {
        rval[["v"]] <- as.logical(rval[["v"]])
	rval[["V"]] <- NULL
      }
    }
  }
  for(i in c("a", "c", "d", "g", "i", "r", "t", "u", "v", "V")) {
    if(!is.null(rval[[i]])) {
      if(!is.logical(rval[[i]]) | length(rval[[i]]) != 1L) {
        warning(sprintf("argument %s needs to be a single logical, changed to default", i))
	rval[[i]] <- NULL
      }
    }
  }
  for(i in c("e", "f", "j", "n", "w", "y")) {
    if(!is.null(rval[[i]])) {
      if(!(is.numeric(rval[[i]]) | is.logical(rval[[i]])) | length(rval[[i]]) != 1L) {
        warning(sprintf("argument %s needs to be a single numeric, changed to default", i))
	rval[[i]] <- NULL
      }
    }
  }
  for(i in c("L", "p", "xmakeindxcmd")) {
    if(!is.null(rval[[i]])) {
      if(!is.character(rval[[i]]) | length(rval[[i]]) != 1L) {
        warning(sprintf("argument %s needs to be a single character, changed to default", i))
	rval[[i]] <- NULL
      }
    }
  }
  
  ## select only non-NULL/FALSE elements
  rval <- rval[!sapply(rval, is.null)]
  rval <- rval[!sapply(rval, identical, FALSE)]

  ## collapse to character vector
  rval <- paste("-", names(rval), ifelse(sapply(rval, isTRUE), "", unlist(rval)),
    sep = "", collapse = " ")
  return(rval)
}
