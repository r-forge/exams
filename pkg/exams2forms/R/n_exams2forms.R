n_exams2forms <- function(file, n, ...) {
  library("exams2forms")
  cat("::: {.webex-group}\n")
  
  for (i in 0:(n-1)) {
    cat("::: {.webex-question}\n")
    exams2forms(file,  ...)
    cat(":::\n")
  }
  
  cat(":::\n")
}
