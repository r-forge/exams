webquiz <- function(...) {
  ## include CSS and JavaScript (FIXME: include customization)
  css <- system.file("webex/webex.css", package = "exams2forms")
  js <- system.file("webex/webex.js", package = "exams2forms")

  ## smart quotes changed in rmarkdown 2.2 / pandoc 2.0.6
  pandoc_available(version = "2.0.6", error = TRUE)

  ## set up html_document
  html_document(css = css, includes = includes(after_body = js), md_extensions = "-smart", ...)
}


