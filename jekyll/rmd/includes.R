include_rmd <- function(file, ...) {
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = "../../assets/svg/", knitr::render_jekyll("prettify"))
  knitr::knit(input = file, quiet = TRUE, encoding = "UTF-8")
}
