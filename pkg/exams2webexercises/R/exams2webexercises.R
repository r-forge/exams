exams2webexercises <- function(file,
  write = TRUE, markup = "markdown", solution = TRUE, nchar = c(20, 100),
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", ...) {

  if(!missing(dir)) {
    warning("output 'dir' is not relevant for exams2webexercises(), ignored")
  }

  ## process default arguments
  nchar <- rep_len(nchar, 2L)
  html <- match.arg(tolower(markup), c("html", "markdown")) == "html"

  ## convert each question to Markdown or HTML first (to assure this also works for .Rnw)
  ## and then combine with webexercises
  trafo <- if(html) {
    make_exercise_transform_html(converter = converter, base64 = TRUE)
  } else {
    make_exercise_transform_pandoc(to = "markdown", options = "--wrap=none", base64 = TRUE)
  }
  webexercisestrafo <- function(x, ...) {
    ## unify markup
    x <- trafo(x)

    ## set up question
    question <- switch(x$metainfo$type,
      "schoice" = {
        c(
          x$question,
          "",
          longmcq(structure(x$questionlist, .Names = ifelse(x$metainfo$solution, "answer", "")))
        )
        ## FIXME: optionall use mcq() instead
      },
      "mchoice" = {
        ## FIXME: currently emulate via torf(), wishlist: propose webexercises::maq()
        c(
          x$question,
          "",
          if(html) "<ul>",
          paste(if(html) "<li>" else "* ", 
            vapply(x$metainfo$solution, torf, ""),
            x$questionlist
          ),
          if(html) "</ul>"
        )
      },
      "num" = {
        c(
          x$question,
          "",
          fitb(x$metainfo$solution, tol = x$metainfo$tol,
            width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution))))
        )
      },
      "string" = {
        c(
          x$question,
          "",
          fitb(x$metainfo$solution,
            width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution))))
        )
      },
      "cloze" = {
        stop("not supported yet")
        ## FIXME: insert individual interactions into x$question
      }
    )
      
    ## set up solution (if desired and available)
    try_solution <- !is.null(solution) && !identical(solution, FALSE) && !is.na(solution)
    solution <- if(identical(solution, TRUE)) "Correct solution" else as.character(solution)
    solution <- if(try_solution && (!is.null(x$solution) || !is.null(x$solutionlist))) {
      c("",
        hide(solution),
        "",
        x$solution,
        if(!is.null(x$solutionlist)) c(
          "",
          if(html) "<ul>",
          paste0(if(html) "<li>" else "* ", x$solutionlist, if(html) "</li>"),
          if(html) "</ul>"
        ),
        "",
        unhide()
      )
    } else {
      NULL
    }

    c(question, solution, "")
  }
  
  ## generate xexams
  rval <- exams::xexams(file,
    n = n, dir = dir, nsamp = nsamp, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose,
    driver = list(
      sweave = list(quiet = quiet, pdf = FALSE, png = !svg, svg = svg, resolution = resolution, width = width, height = height, encoding = "UTF-8"),
      read = NULL,
      transform = webexercisestrafo,
      write = NULL),
  )

  ## FIXME: currently this just writes all exercises sequentially
  ## Wishlist:
  ## - For multiple exercises in the same exam: Optionally include enumerated list?
  ## - For multiple exams: Propose randomization Javascript class for webexercises?
  if(write) lapply(do.call("c", rval), writeLines)

  ## return list of lists invisibly
  invisible(rval)
}
