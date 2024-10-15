exams2learnr <- function(file, 
  output = NULL, show_solution = TRUE, allow_retry = FALSE, random_answer_order = FALSE, 
  correct = "Correct!", incorrect = "Incorrect", try_again = incorrect, caption = "Quiz",
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = TRUE, label = NULL,
  ...) {

  ## determine desired output format:
  ## - a single learnr::question
  ## - a learnr::quiz (containing learnr::questions)
  ## - a list of learnr::questions
  if(is.null(output)) {
    output <- if(length(file) == 1L && n == 1L && (is.null(nsamp) || nsamp == 1L)) {
      "question"
    } else if(n == 1L && (length(file) > 1L || (!is.null(nsamp) && nsamp > 1L))) {
      "quiz"
    } else {
      "list"
    }
  }
  output <- match.arg(output, c("question", "quiz", "list"))

  ## default label
  if(is.null(label)) label <- knitr::opts_current$get("label")

  ## sanity checks
  if(output == "question" && (length(file) > 1L || n > 1L || (!is.null(nsamp) && nsamp > 1L))) {
    warning("more than one random exercise implied by file/n/nsamp, switching output to 'list'")
    output <- "list"
  }
  if(output == "quiz" && n > 1L) {
    warning("more than n > 1 random replication specified, switching output to 'list'")
  }
  if(!missing(dir)) {
    warning("output 'dir' is not relevant for exams2learnr(), ignored")
  }

  ## convert each question to HTML first (to assure this also works for .Rnw)
  ## and then embed in learnr::question
  htmltrafo <- exams::make_exercise_transform_html(converter = converter, base64 = base64)
  learnrtrafo <- function(x, ...) {
    ## cloze questions are currently not supported yet
    if(!(x$metainfo$type %in% c("schoice", "mchoice", "string", "num"))) {
      stop("currently only schoice/mchoice or string/num questions are supported")
    }
  
    x <- htmltrafo(x)
  
    ## set up argument list for learnr question
    args <- list(
      text = x$question,
      type = switch(x$metainfo$type,
        "schoice" = "learnr_radio",
        "mchoice" = "learnr_checkbox",
        "string" = "learnr_text",
        "num" = "learnr_numeric"
      ),
      post_message = if(show_solution && (!is.null(x$solution) || length(x$solutionlist) > 0L)) {
        c(x$solution, "", if(length(x$solutionlist) > 0L) c("<ul>", paste0("<li>", x$solutionlist, "</li>"), "</ul>"))
      } else {
        NULL
      },
      allow_retry = allow_retry,
      random_answer_order = random_answer_order,
      correct = correct,
      incorrect = incorrect,
      try_again = try_again,
      ...
    )
    if(x$metainfo$type == "string") {
      args$options <- list(trim = TRUE)
    }
    if(x$metainfo$type == "num") {
      args$options <- list(
        min = NA,
        max = NA,
        step = NA,
        tolerance = x$metainfo$tolerance
      )
    }

    ## set up answers
    ans <- if(x$metainfo$type %in% c("schoice", "mchoice")) {
      lapply(seq_along(x$questionlist), function(i) learnr::answer(x$questionlist[i], correct = x$metainfo$solution[i]))
    } else if(x$metainfo$type == "string") {
      list(learnr::answer(as.character(x$metainfo$solution), correct = TRUE))
    } else if(x$metainfo$type == "num") {
      list(learnr::answer(as.numeric(x$metainfo$solution), correct = TRUE))
    }

    ## set current label based on exercise file name -> used as learnr question ID
    knitr::opts_current$lock(status = FALSE)
    knitr::opts_current$set(label = label)

    ## return learnr question
    do.call(learnr::question, c(args, ans))
  }

  ## generate xexams
  rval <- exams::xexams(file,
    n = n, dir = dir, nsamp = nsamp, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose,
    driver = list(
      sweave = list(quiet = quiet, pdf = FALSE, png = !svg, svg = svg, resolution = resolution, width = width, height = height, encoding = "UTF-8"),
      read = NULL,
      transform = learnrtrafo,
      write = NULL),
  )

  ## return desired output format
  if(output == "quiz") {
    rval <- do.call(learnr::quiz, c(rval[[1L]], list(caption = caption)))
  } else if(output == "question") {
    rval <- rval[[1L]][[1L]]
  }
  return(rval)  
}
