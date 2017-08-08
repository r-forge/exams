include_rmd <- function(file, ...) {
  assets <- paste0(tools::file_path_sans_ext(file), "-assets")
  if(!file.exists(assets)) dir.create(assets)
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = paste0(assets, "/"), knitr::render_jekyll("prettify"))
  knitr::knit(input = file, quiet = TRUE, encoding = "UTF-8")
  if(length(list.files(assets)) < 1L) unlink(assets)
}

include_pdf_screenshot <- function(file, out = NULL, page = 1, density = 40, square = TRUE) {
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(basename(file)), ".png")
  if(knitr::opts_chunk$get("fig.path") != "figure/") out <- paste0(knitr::opts_chunk$get("fig.path"), out)
  for(i in seq_along(file)) {
    cmd <- sprintf("convert -density %s %s[%s] -extent %sx%s %s",
      density, file[i], page - 1,
      round(density * 8.268), round(density * if(square) 8.268 else 11.693),
      out[i])
    system(cmd)
  }
  invisible(out)
}

include_file <- function(file) {
  file.copy(file, knitr::opts_chunk$get("fig.path"))
  invisible(file.path(knitr::opts_chunk$get("fig.path"), file))
}
