initialize_cloze <- function() {
  ## initialize empty meta-information in internal exams environment
  .exams_set_internal(cloze_metainfo = list(
    type = character(0L),
    solution = character(0L),
    tolerance = numeric(0L),
    answerlist = character(0L)
  ))
}

add_cloze <- function(solution, single = NULL, tolerance = NULL, answertag = TRUE, ...) {
  ## get meta-information so far
  info <- .exams_get_internal("cloze_metainfo")

  ## process solution and type as well as tolerance and answerlist, if needed
  if (!is.null(dim(solution))) {
    tab <- as.matrix(solution)
    solution <- as.vector(t(tab))
  } else {
    tab <- NULL
  }
  if (is.numeric(solution)) {
    type <- rep.int("num", length(solution))
    if (is.null(tolerance)) tolerance <- num_to_tol(solution)
    tolerance <- rep_len(tolerance, length(solution))
    solution <- vapply(solution, fmt, "", ...)
    answerlist <- NULL
  } else if (is.character(solution)) {
    type <- rep.int("string", length(solution))
    tolerance <- rep.int(0, length(solution))   
    answerlist <- NULL
  } else if (is.logical(solution)) {
    if (is.null(single)) single <- sum(solution) == 1L
    type <- if (single) "schoice" else "mchoice"
    tolerance <- 0
    answerlist <- names(solution)
    if (is.null(answerlist)) stop("a 'solution' must be named for schoice/mchoice elements")
    solution <- mchoice2string(solution, single = single)
  } else {
    stop("unknown type of solution")
  }

  ## update meta-information
  info$type <- c(info$type, type)
  info$solution <- c(info$solution, solution)
  info$tolerance <- c(info$tolerance, tolerance)
  info$answerlist <- c(info$answerlist, answerlist)
  .exams_set_internal(cloze_metainfo = info)

  ## add ##ANSWERi## tags (unless disabled)
  if (!answertag) return("")
  
  ## number of cloze types added
  m <- length(type)
  n <- length(info$type) - m

  ## format ##ANSWERi## tags
  a <- sprintf("##ANSWER%i##", n + seq_len(m))
  if (!is.null(tab)) {
    tab[] <- a
    markup <- match_exams_markup()
    if(is.null(markup)) markup <- "markdown"
    tab <- knitr::kable(tab, format = markup)
    if(markup == "latex") {
      tab <- gsub("\\", "\\\\", tab, fixed = TRUE)
      tab <- gsub("\\#", "#", tab, fixed = TRUE)
    }
    return(tab)
  } else {
    return(paste(a, collapse = " "))
  }
}

format_cloze <- function(field) {
  info <- .exams_get_internal("cloze_metainfo")
  field <- match.arg(field, names(info))
  if (field == "answerlist") {
    markup <- match_exams_markup()
    if(is.null(markup)) markup <- "markdown"
    ans <- paste(answerlist(info[["answerlist"]], markup = markup, write = FALSE), collapse = "\n")
    if(markup == "markdown") ans else gsub("\\", "\\\\", ans, fixed = TRUE)
  } else {
    paste(info[[field]], collapse = "|")
  }
}
