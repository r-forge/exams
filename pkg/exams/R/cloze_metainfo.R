add_cloze <- function(solution, choices = NULL, type = NULL, tolerance = NULL, answertag = TRUE, ...) {
  ## get meta-information so far
  info <- .exams_get_internal("exercise_metainfo")

  ## process choices list, if any
  if (!is.null(choices)) {
    if (length(solution) == 0L) {
      solution <- setNames(rep.int(FALSE, length(choices)), choices)
    } else {
      if (!all(solution %in% choices)) stop("all elements of 'solution' must be in 'choices'")
      solution <- setNames(choices %in% solution, choices)
    }
  }

  ## process type, if specified
  if (!is.null(type)) {
    ## match type
    if (length(type) > 1L) {
      warning("only one 'type' must be specified, using the first")
      type <- type[1L]
    }
    type <- match.arg(type, c("num", "schoice", "mchoice", "string", "essay", "file", "verbatim"))

    ## sanity checks
    if (type == "num") {
      if (is.data.frame(solution)) solution <- as.matrix(solution)
      if (!is.numeric(solution)) stop("'solution' must be numeric")
    } else if (type == "string") {
      if (is.data.frame(solution)) solution <- as.matrix(solution)
      if (!is.character(solution)) stop("'solution' must be character")
    } else if (type == "schoice") {
      if (!is.logical(solution) || is.null(names(solution)) || length(solution) < 2L || sum(solution) != 1L) stop("'solution' must be a named logical vector with exactly one TRUE element for type 'schoice'")
    } else if (type == "mchoice") {
      if (!is.logical(solution) || is.null(names(solution)) || length(solution) < 1L) stop("'solution' must be a named logical vector for type 'mchoice'")
    } else if (type == "essay" || type == "file") {
      if (missing(solution) || length(solution) < 1L) solution <- "nil"
      solution <- paste(solution, collapse = " ")
    } else if (type == "verbatim") {
      solution <- as.character(solution)
      if (length(solution) > 1L) warning("only one 'solution' must be specified for 'verbatim' types, using the first")      
      solution <- solution[1L]
    }
  }

  ## handle num/string matrices/data.frames
  if (!is.null(dim(solution))) {
    tab <- as.matrix(solution)
    solution <- as.vector(t(tab))
  } else {
    tab <- NULL
  }
  
  ## process solution and type as well as tolerance and answerlist, if needed
  if (is.numeric(solution)) {
    type <- rep.int("num", length(solution))
    if (is.null(tolerance)) tolerance <- num_to_tol(solution)
    tolerance <- rep_len(tolerance, length(solution))
    solution <- if (length(list(...)) < 1L) {
      vapply(solution, as.character, "")
    } else {
      vapply(solution, fmt, "", ...)
    }
    answerlist <- NULL
  } else if (is.character(solution)) {
    if (is.null(type) || type == "string") type <- rep.int("string", length(solution))
    tolerance <- rep.int(0, length(solution))   
    answerlist <- NULL
  } else if (is.logical(solution)) {
    if (is.null(type)) type <- if (sum(solution) == 1L) "schoice" else "mchoice"
    tolerance <- 0
    answerlist <- names(solution)
    if (is.null(answerlist)) stop("a 'solution' must be named for schoice/mchoice elements")
    solution <- mchoice2string(solution, single = type == "schoice")
  } else {
    stop("unknown type of solution")
  }

  ## update meta-information
  info$type <- c(info$type, type)
  info$solution <- c(info$solution, solution)
  info$tolerance <- c(info$tolerance, tolerance)
  info$answerlist <- c(info$answerlist, answerlist)
  .exams_set_internal(exercise_metainfo = info)

  ## add ##ANSWERi## tags (unless disabled)
  if (!answertag) return("")
  
  ## number of cloze types added
  m <- length(type)
  n <- length(info$type) - m

  ## format ##ANSWERi## tags
  a <- sprintf("##ANSWER%i##", n + seq_len(m))
  if (!is.null(tab)) {
    tab <- matrix(a, byrow = TRUE,
      nrow = nrow(tab), ncol = ncol(tab), dimnames = dimnames(tab))
    markup <- match_exams_markup()
    if (is.null(markup)) markup <- "markdown"
    tab <- kable(tab, format = markup)
    if (markup == "latex") {
      tab <- gsub("\\", "\\\\", tab, fixed = TRUE)
      tab <- gsub("\\#", "#", tab, fixed = TRUE)
    }
    return(tab)
  } else {
    return(paste(a, collapse = " "))
  }
}

format_metainfo <- function(field) {
  info <- .exams_get_internal("exercise_metainfo")
  field <- match.arg(field, names(info))
  if (field == "answerlist") {
    if (length(info[["answerlist"]]) == 0L) return(character(0))
    markup <- match_exams_markup()
    if (is.null(markup)) markup <- "markdown"
    ans <- paste(answerlist(info[["answerlist"]], markup = markup, write = FALSE), collapse = "\n")
    if (markup == "markdown") ans else gsub("\\", "\\\\", ans, fixed = TRUE)
  } else {
    paste(info[[field]], collapse = "|")
  }
}
