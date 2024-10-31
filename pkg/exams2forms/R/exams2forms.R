exams2forms <- function(file,
  write = TRUE, check = TRUE, box = TRUE, solution = TRUE, nchar = c(20, 100),
  schoice_display = "buttons", mchoice_display = "buttons", cloze_schoice_display = "dropdown", cloze_mchoice_display = mchoice_display,
  usecase = TRUE, usespace = TRUE,
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = NULL, ...) {

  if (!isTRUE(usecase) || isFALSE(usecase)) usecase <- as.logical(usecase[1L])
  if (!isTRUE(usespace) || isFALSE(usespace)) usespace <- as.logical(usespace[1L])

  ## TODO: Removed `regex` option from official arguments list but can
  ##       be specified for testing purposes.
  args <- list(...)
  regex <- if ("regex" %in% names(args)) as.logical(args$regex)[1L] else FALSE
  if (!isTRUE(regex) || isFALSE(regex)) regex <- as.logical(regex[1])
  stopifnot("argument `regex` must be logical TRUE or FALSE" = isTRUE(regex) || isFALSE(regex))

  if(!missing(dir)) {
    warning("output 'dir' is not relevant for exams2forms(), ignored")
  }

  ## process default arguments
  nchar <- rep_len(nchar, 2L)
  start_check <- if(check) c(sprintf("::: {.webex-check%s}", if(box) " .webex-box" else ""), "") else NULL
  end_check <- if(check) c("", ":::") else NULL

  ## convert each question to Markdown first (to assure this also works for .Rnw)
  ## and then combine with forms
  if (is.null(base64)) base64 <- is_html_output()
  mdtrafo <- make_exercise_transform_pandoc(to = "markdown", options = "--wrap=none", base64 = base64)
  formstrafo <- function(x, ...) {
    
    ## Need to fix issues that are not handled correctly in LaTeX to Markdown conversion?
    fix_tex2md <- x$metainfo$markup == "latex"

    ## remove leading spaces before \begin{...} and \end{...} in LaTeX input
    if(fix_tex2md) {
      x$question <- xsub("(^[[:space:]]*)(\\\\begin\\{)([^\\}]+)(\\})", "\\\\begin{\\3}", x$question)
      x$question <- xsub("(^[[:space:]]*)(\\\\end\\{)([^\\}]+)(\\})", "\\\\end{\\3}", x$question)
      x$solution <- xsub("(^[[:space:]]*)(\\\\begin\\{)([^\\}]+)(\\})", "\\\\begin{\\3}", x$solution)
      x$solution <- xsub("(^[[:space:]]*)(\\\\end\\{)([^\\}]+)(\\})", "\\\\end{\\3}", x$solution)
    }

    ## unify markup
    x <- mdtrafo(x)

    ## remove default "image" caption in Markdown if original input was LaTeX
    if(fix_tex2md) {
      if(!is.null(x$question))     x$question     <- xsub("![image](", "![](", x$question,     fixed = TRUE)
      if(!is.null(x$questionlist)) x$questionlist <- xsub("![image](", "![](", x$questionlist, fixed = TRUE)
      if(!is.null(x$solution))     x$solution     <- xsub("![image](", "![](", x$solution,     fixed = TRUE)
      if(!is.null(x$solutionlist)) x$solutionlist <- xsub("![image](", "![](", x$solutionlist, fixed = TRUE)
    }

    ## set up forms for question
    forms <- switch(x$metainfo$type,
      "schoice" = forms_schoice(x$questionlist, x$metainfo$solution, display = schoice_display),
      "mchoice" = forms_mchoice(x$questionlist, x$metainfo$solution, display = mchoice_display),
      "num"     = forms_num(x$metainfo$solution, tol = x$metainfo$tol, width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution)))),
      "string"  = forms_string(x$metainfo$solution, width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution))),
                    usecase = usecase, usespace = usespace, regex = regex, ...),
      character(0))
    
    ## for cloze: embed forms directly
    if (x$metainfo$type == "cloze") {
      g <- rep(seq_along(x$metainfo$solution), sapply(x$metainfo$solution, length))
      x$questionlist <- split(x$questionlist, g)
      if(!is.null(x$solutionlist)) x$solutionlist <- sapply(split(x$solutionlist, g), paste, collapse = " / ")
      for(j in seq_along(x$questionlist)) {
        if(!(x$metainfo$clozetype[j] %in% c("num", "schoice", "mchoice", "string"))) {
          warning(sprintf("cloze type '%s' not supported, rendered as 'string'", x$metainfo$clozetype[j]))
        }
        qj <- switch(x$metainfo$clozetype[j],
          "schoice" = forms_schoice(x$questionlist[[j]], x$metainfo$solution[[j]], display = cloze_schoice_display),
          "mchoice" = forms_mchoice(x$questionlist[[j]], x$metainfo$solution[[j]], display = cloze_mchoice_display),
          "num" = forms_num(x$metainfo$solution[[j]], tol = x$metainfo$tol[j], width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution[[j]])))),
          forms_string(x$metainfo$solution[[j]], width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution[[j]]))),
                       ..., usespace = usespace, usecase = usecase, regex = regex)
        )
        aj <- paste0("##ANSWER", j, "##")
        if(any(grepl(aj, x$question, fixed = TRUE))) {
          x$question <- xsub(aj, qj, x$question, fixed = TRUE)
        } else {
          x$question <- c(x$question, "",
            if(!identical(x$questionlist[[j]], "") && !(x$metainfo$clozetype[j] %in% c("schoice", "mchoice"))) paste(x$questionlist[[j]], qj) else qj)
        }
        x$questionlist[[j]] <- NA
      }
    }

    ## question including forms
    question <- c(start_check, x$question, "", forms, end_check)
      
    ## set up solution (if desired and available)
    try_solution <- !is.null(solution) && !identical(solution, FALSE) && !is.na(solution)
    solution_title <- if(identical(solution, TRUE)) "" else as.character(solution)
    solution <- if(try_solution && (!is.null(x$solution) || !is.null(x$solutionlist))) {
      c(solutionbox_start(solution_title),
        "",
        x$solution,
        if(!is.null(x$solutionlist)) c(
          "",
          paste("*", x$solutionlist)
        ),
        "",
        solutionbox_end()
      )
    } else {
      NULL
    }

    txt <- c(question, solution, "")
    
    ## fix paths to supplements (if any) and try to make them local to be portable in rmarkdown/quarto output
    if(!is.null(sdir)) sdir <- paste0(sdir, if(substr(sdir, nchar(sdir), nchar(sdir)) == "/") "" else "/", "exam")
    for(sup in x$supplements) {
      s1 <- basename(sup)
      s2 <- sup
      if(!is.null(sdir)) {
        s2 <- strsplit(s2, sdir, fixed = TRUE)[[1L]]
        s2 <- if(length(s2) < 2L) s2 else paste0(sdir, s2[-1L], collapse = "")
      }
      prefix <- "]("
      txt <- xsub(paste0(prefix, s1), paste0(prefix, s2), txt, fixed = TRUE)
    }
    
    return(txt)
  }
  
  ## generate xexams
  rval <- xexams(file,
    n = n, dir = dir, nsamp = nsamp, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose,
    driver = list(
      sweave = list(quiet = quiet, pdf = FALSE, png = !svg, svg = svg, resolution = resolution, width = width, height = height, encoding = "UTF-8"),
      read = NULL,
      transform = formstrafo,
      write = NULL),
  )

  ## Wishlist:
  ## - For multiple exercises in the same exam: Optionally include enumerated list?
  if(write) {
    n_exams <- length(rval)
    n_exercises <- length(rval[[1L]])
    for(i in 1L:n_exercises) {
      if(n_exams > 1L) writeLines("::: {.webex-group}")
      for(j in 1L:n_exams) {
        writeLines("::: {.webex-question}")
        writeLines(rval[[j]][[i]])
        writeLines(":::")
      }
      if(n_exams > 1L) writeLines(":::")
    }
  }

  ## return list of lists invisibly
  invisible(rval)
}

xsub <- function(pattern, replacement, x, ...) {
  if(is.null(x)) {
    return(NULL)
  } else {
    gsub(pattern, replacement, x, ...)
  }
}
