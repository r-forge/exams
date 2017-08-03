knit_to_jekyll <- function(file, ...) {
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = "../../assets/svg/", knitr::render_jekyll("prettify"))
  knitr::knit(file, quiet = TRUE, encoding = "UTF-8")
}
