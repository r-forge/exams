exams2webexercises <- function(file,
  write = TRUE, check = TRUE, box = TRUE, markup = "markdown", solution = TRUE, nchar = c(20, 100),
  n = 1L, nsamp = NULL, dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  quiet = TRUE, resolution = 100, width = 4, height = 4, svg = FALSE,
  converter = "pandoc-mathjax", base64 = TRUE, ...) {

  if(!missing(dir)) {
    warning("output 'dir' is not relevant for exams2webexercises(), ignored")
  }

  ## process default arguments
  nchar <- rep_len(nchar, 2L)
  html <- match.arg(tolower(markup), c("html", "markdown")) == "html"
  start_check <- if(check) c(sprintf("::: {.webex-check%s}", if(box) " .webex-box" else ""), "") else NULL
  end_check <- if(check) c("", ":::") else NULL

  ## convert each question to Markdown or HTML first (to assure this also works for .Rnw)
  ## and then combine with webexercises
  trafo <- if(html) {
    make_exercise_transform_html(converter = converter, base64 = base64)
  } else {
    make_exercise_transform_pandoc(to = "markdown", options = "--wrap=none", base64 = base64)
  }
  webexercisestrafo <- function(x, ...) {
    
    ## Need to fix issues that are not handled correctly in LaTeX to Markdown conversion?
    fix_tex2md <- x$metainfo$markup == "latex"

    ## remove leading spaces before \begin{...} and \end{...} in LaTeX input
    if(fix_tex2md) {
      x$question <- gsub("(^[[:space:]]*)(\\\\begin\\{)([^\\}]+)(\\})", "\\\\begin{\\3}", x$question)
      x$question <- gsub("(^[[:space:]]*)(\\\\end\\{)([^\\}]+)(\\})", "\\\\end{\\3}", x$question)
      x$solution <- gsub("(^[[:space:]]*)(\\\\begin\\{)([^\\}]+)(\\})", "\\\\begin{\\3}", x$solution)
      x$solution <- gsub("(^[[:space:]]*)(\\\\end\\{)([^\\}]+)(\\})", "\\\\end{\\3}", x$solution)
    }

    ## unify markup
    x <- trafo(x)

    ## remove default "image" caption in Markdown if original input was LaTeX
    if(fix_tex2md) {
      x$question     <- gsub("![image](", "![](", x$question,     fixed = TRUE)
      x$questionlist <- gsub("![image](", "![](", x$questionlist, fixed = TRUE)
      x$solution     <- gsub("![image](", "![](", x$solution,     fixed = TRUE)
      x$solutionlist <- gsub("![image](", "![](", x$solutionlist, fixed = TRUE)
    }

    ## set up question
    question <- switch(x$metainfo$type,
      "schoice" = {
        c(
          start_check,
          x$question,
          "",
          longmcq(structure(x$questionlist, .Names = ifelse(x$metainfo$solution, "answer", ""))),
          end_check
        )
        ## FIXME: optionally use mcq() instead
      },
      "mchoice" = {
        ## FIXME: currently emulate via torf(), wishlist: propose webexercises::maq()
        c(
          start_check,
          x$question,
          "",
          if(html) "<ul>",
          paste(if(html) "<li>" else "* ", 
            vapply(x$metainfo$solution, torf, ""),
            x$questionlist
          ),
          if(html) "</ul>",
          end_check
        )
      },
      "num" = {
        c(
          start_check,
          x$question,
          "",
          fitb(x$metainfo$solution, tol = x$metainfo$tol,
            width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution)))),
          end_check
        )
      },
      "string" = {
        c(
          start_check,
          x$question,
          "",
          fitb(x$metainfo$solution,
            width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution)))),
          end_check
        )
      },
      "cloze" = {
        g <- rep(seq_along(x$metainfo$solution), sapply(x$metainfo$solution, length))
        x$questionlist <- split(x$questionlist, g)
        if(!is.null(x$solutionlist)) x$solutionlist <- sapply(split(x$solutionlist, g), paste, collapse = " / ")
        for(j in seq_along(x$questionlist)) {
          if(!(x$metainfo$clozetype[j] %in% c("num", "schoice", "mchoice", "string"))) {
            warning(sprintf("cloze type '%s' not supported, rendered as 'string'", x$metainfo$clozetype[j]))
          }
          qj <- switch(x$metainfo$clozetype[j],
            "num" = fitb(x$metainfo$solution[[j]], tol = x$metainfo$tol[j],
              width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution[[j]])))),
            "schoice" = mcq(structure(x$questionlist[[j]], .Names = ifelse(x$metainfo$solution[[j]], "answer", ""))), ## FIXME: longmcq vs. mcq
            "mchoice" = paste(c(
              if(html) "<ul>" else NULL,
              paste(if(html) "<li>" else "* ", 
                vapply(x$metainfo$solution[[j]], torf, ""),
                x$questionlist[[j]]
              ),
              if(html) "</ul>" else NULL
            ), collapse = "\n"),
            fitb(x$metainfo$solution[[j]],
              width = min(nchar[2L], max(nchar[1L], nchar(x$metainfo$solution[[j]]))))
          )
          aj <- paste0("##ANSWER", j, "##")
          if(any(grepl(aj, x$question, fixed = TRUE))) {
            x$question <- gsub(aj, qj, x$question, fixed = TRUE)
          } else {
            x$question <- c(x$question, "",
              if(!identical(x$questionlist[[j]], "") && !(x$metainfo$clozetype[j] %in% c("schoice", "mchoice"))) paste(x$questionlist[[j]], qj) else qj)
          }
          x$questionlist[[j]] <- NA
        }
        c(
          start_check,
          x$question,
          "",
          end_check
        )
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
      prefix <- if(html) c('src="', 'href="') else "]("
      txt <- gsub(paste0(prefix, s1), paste0(prefix, s2), txt, fixed = TRUE)
    }
    
    return(txt)
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
