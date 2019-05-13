nops_zip2tab <- function(file = "nops_eval.zip")
{
  ## input .zip file and output .tab file
  if(tools::file_ext(file) != "zip") stop("'file' must be a .zip file")
  out <- paste0(tools::file_path_sans_ext(file), ".tab")

  ## create temporary directory
  tdir <- tempfile()
  dir.create(tdir)
  
  ## copy zip file and unzip
  file.copy(file, file.path(tdir, file))
  odir <- getwd()
  setwd(tdir)
  utils::unzip(file)

  ## student accounts
  acc <- dir(pattern = "^c")
  
  ## extract relevant HTML table
  html <- function(x) {
    y <- dir(x, pattern = "\\.html$", full.names = TRUE)
    y <- readLines(y)
    y <- y[(grep("<body>", y) + 1):(grep("<h3>Pr&#252;fungsbeleg</h3>", y) - 1)]
    sprintf("%s\t%s", x, paste(y, collapse = ""))
  }
  tab <- sapply(acc, html)
  
  ## create tab file in original directory
  setwd(odir)
  unlink(tdir)
  writeLines(tab, out)
  invisible(tab)
}
