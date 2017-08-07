include_rmd <- function(file, ...) {
  assets <- paste0(tools::file_path_sans_ext(file), "-assets")
  dir.create(assets)
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = assets, knitr::render_jekyll("prettify"))
  knitr::knit(input = file, quiet = TRUE, encoding = "UTF-8")
}

include_pdf_screenshot <- function(file, out = NULL, page = 1, density = 40, square = TRUE) {
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(file), ".png")
  cmd <- sprintf("convert -density %s %s[%s] -extent %sx%s %s",
    density, file, page - 1,
    round(density * 8.268), round(density * if(square) 8.268 else 11.693),
    out)
  system(cmd)
  invisible(out)
}
