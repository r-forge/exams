search_files <- function(file, dir = ".")
{
  lf <- list.files(dir, full.names = TRUE, recursive = TRUE)
  gr <- lapply(file, grep, lf, fixed = TRUE)
  ix <- rep(seq_along(file), sapply(gr, length))
  gr <- unlist(gr)
  fp <- file.path(dirname(lf[gr]), file[ix])
  fe <- file.exists(fp)
  fm <- match(ix[fe], seq_along(file))
  return(if(length(fm)) fp[fm] else NA)
}
