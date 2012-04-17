## reads images as binary
read_images <- function(x)
{
  if(!is.null(x)) {
    if(!is.character(x))
      stop("x must be a character including the path(s) to the image(s)!")
    rval <- list()
    for(i in x) {
      N <- 1e7
      repeat {
        img <- readBin(i, "raw", n = N)
        if(length(img) == N) N <- 5 * N else break
      }
      rval[[basename(i)]] <- img
    }
  } else rval <- NULL
  rval
}
