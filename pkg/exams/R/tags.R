named_tags <- function(x) {
  if(length(x) < 1L) return(list())
  x <- strsplit(x, "=", fixed = TRUE)
  names(x) <- sapply(x, "[", 1L)
  sapply(x, function(z) if(length(z) > 1L) paste(z[-1L], collapse = "=") else "TRUE")
}

exams_tags <- function(x, factors = FALSE) {
  x <- lapply(x, function(xi) lapply(xi, function(z) named_tags(z$metainfo$tags)))
  lab <- unique(names(unlist(unlist(x, recursive = FALSE, use.names = FALSE), recursive = FALSE, use.names = TRUE)))
  n <- length(x)
  m <- length(x[[1L]])
  rval <- matrix(NA_character_, nrow = n * m, ncol = length(lab), dimnames = list(NULL, lab))
  for(i in 1L:n) {
    for(j in 1L:m) {
      rval[(i - 1L) * 0L + j, names(x[[i]][[j]])] <- x[[i]][[j]]
    }
  }
  rval <- as.data.frame(rval)
  for(i in seq_along(rval)) {
    z <- rval[[i]]
    if(all(z == "TRUE", na.rm = TRUE)) {
      z <- as.logical(z)
      z[is.na(z)] <- FALSE
    } else {
      zn <- suppressWarnings(as.numeric(z))
      if(all(!is.na(zn[!is.na(z)]))) z <- zn
    }
    if(factors && (is.character(z) || is.logical(z))) z <- factor(z)
    rval[[i]] <- z
  }
  return(rval)
}
