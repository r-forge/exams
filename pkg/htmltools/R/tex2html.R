TTH <- TTM <- ""

.onLoad <- function(libname, pkgname) {
    
    ## command line options should be arguments of tth(), current
    ## version is proof of concept
    if(length(tthpath <- find.package("tth", quiet=TRUE))) {
        if(.Platform$OS.type == "windows") {
            TTH <<- file.path(tthpath, "libs", .Platform$r_arch, "tth.exe")
            TTM <<- file.path(tthpath, "libs", .Platform$r_arch, "ttm.exe")
        } else {
            TTH <<- file.path(tthpath, "libs", .Platform$r_arch, "tth")
            TTM <<- file.path(tthpath, "libs", .Platform$r_arch, "ttm")
        }
    } else {
        if(.Platform$OS.type == "windows") {
            TTH <<- "tth.exe"
            TTM <<- "ttm.exe"
        } else {
            TTH <<- "tth"
            TTM <<- "ttm"
        }
        test <- try(system(htmltools:::TTH, input = "Try running tth!",
                           intern = TRUE, ignore.stderr = TRUE), silent=TRUE)
        if(inherits(test, "try-error"))
           stop("Cannot find R package tth or command line untility tth!\n",
                "Please install suggested R package tth from CRAN.\n")
    }
}

tth <- function(x, ..., fixup = TRUE, Sweave = TRUE)
{
    ## replace/remove Sweave code environments
    if(Sweave) {
        tab <- rbind(
            c("\\\\begin\\{Sinput}",  "\\\\begin{verbatim}"),
            c("\\\\end\\{Sinput}",    "\\\\end{verbatim}"),
            c("\\\\begin\\{Soutput}", "\\\\begin{verbatim}"),
            c("\\\\end\\{Soutput}",   "\\\\end{verbatim}"),
            c("\\\\begin\\{Schunk}",  ""),
            c("\\\\end\\{Schunk}",    "")
	)
        for(i in 1:nrow(tab)) x <- gsub(tab[i,1L], tab[i,2L], x)
    }
    
    ## call tth
    y <- system(paste(shQuote(htmltools:::TTH), tth.control(...)),
      input = x, intern = TRUE, ignore.stderr = TRUE)

    if(fixup) {
        ## delete blanks
        y <- y[-grep("^ *$", y)]
        ## fixup certain math symbols
	## might add further, see e.g., http://www.tlt.psu.edu/suggestions/international/bylanguage/mathchart.html
        tab <- rbind(
            c("\\not =",        "&#8800;"),
            c("\\not &lt;",     "&#8814;"),
            c("\\not  &lt;",    "&#8814;"),
            c("\\not &gt;",     "&#8815;"),
            c("\\not  &gt;",    "&#8815;"),
            c("\\not &#8804;",  "&#8816;"),
            c("\\not  &#8804;", "&#8816;"),
            c("\\nleq;",        "&#8816;"),
            c("\\not &#8805;",  "&#8817;"),
            c("\\not  &#8805;", "&#8817;"),
            c("\\ngeq",         "&#8817;")
        )
        for(i in 1:nrow(tab)) y <- gsub(tab[i,1L], tab[i,2L], y, fixed = TRUE)
    }

    return(y)
}

ttm <- function(x, ..., fixup = TRUE, Sweave = TRUE)
{
    ## replace/remove Sweave code environments
    if(Sweave) {
        tab <- rbind(
            c("\\\\begin\\{Sinput}",  "\\\\begin{verbatim}"),
            c("\\\\end\\{Sinput}",    "\\\\end{verbatim}"),
            c("\\\\begin\\{Soutput}", "\\\\begin{verbatim}"),
            c("\\\\end\\{Soutput}",   "\\\\end{verbatim}"),
            c("\\\\begin\\{Schunk}",  ""),
            c("\\\\end\\{Schunk}",    "")
	)
        for(i in 1:nrow(tab)) x <- gsub(tab[i,1L], tab[i,2L], x)
    }

    ## call tth
    y <- system(paste(shQuote(htmltools:::TTM), tth.control(...)),
      input = x, intern = TRUE, ignore.stderr = TRUE)

    if(fixup) {
        ## delete blanks
        y <- y[-grep("^ *$", y)]
        ## fixup certain math symbols
        tab <- rbind(
            c("\\not<mo>=</mo>",    "<mo>&neq;</mo>"),
            c("\\not<mo>&lt;</mo>", "<mo>&nlt;</mo>"),
            c("\\not<mo>&le;</mo>", "<mo>&nleq;</mo>"),
            c("\\nleq",             "<mo>&nleq;</mo>"),
            c("\\not<mo>&gt;</mo>", "<mo>&ngt;</mo>"),
            c("\\not<mo>&ge;</mo>", "<mo>&ngeq;</mo>"),
            c("\\ngeq",             "<mo>&ngeq;</mo>")
        )
        for(i in 1:nrow(tab)) y <- gsub(tab[i,1L], tab[i,2L], y, fixed = TRUE)
    }

    return(y)
}

tth.control <- function(a = FALSE, c = FALSE, d = FALSE, e = 2, f = NULL, g = FALSE,
  i = FALSE, j = NULL, L = TRUE, n = NULL, p = NULL, r = TRUE, t = FALSE, u = FALSE,
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
  for(i in c("a", "c", "d", "g", "i", "L", "r", "t", "u", "v", "V")) {
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
  for(i in c("p", "xmakeindxcmd")) {
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
