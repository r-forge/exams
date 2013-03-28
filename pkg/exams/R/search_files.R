search_files <- function(files, dir = NULL)
{
  files <- unlist(files)

  stopifnot(is.character(files))
  dir <- if(is.null(dir)) getwd() else path.expand(dir)

  fpaths <- NULL

  for(f in list.files(dir)) {
    fp <- file.path(dir, f)
    if(!file.info(fp)$isdir) {
      for(j in files) {
        if(length(fs <- grep(j, fp, fixed = TRUE, value = TRUE))) {
          fpaths <- c(fpaths, fs)
        }
      }
    } else {
      fpaths <- c(fpaths, search_files(files, dir = fp))
    }
  }

  fpaths
}
