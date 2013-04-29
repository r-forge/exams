search_files <- function(file, dir = ".")
{
  lf <- list.files(dir, full.names = TRUE, recursive = TRUE)
  bn <- basename(lf)
  gr <- lapply(file, function(f) which(bn == f))
  ix <- rep(seq_along(file), sapply(gr, length))
  gr <- unlist(gr)
  fp <- file.path(dirname(lf[gr]), file[ix])
  fe <- file.exists(fp)
  fp[match(seq_along(file), ix[fe])]
}
