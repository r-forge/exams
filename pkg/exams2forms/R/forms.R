

## Get webex ID for 'ID/solution checking'. If input `x` is a single character,
## it is returned as is. If input `is.null(x)` we return a specific random webex ID
## for checking the webex ID on the javascript side of the game.
get_webex_id <- function(x, algo = "md5") {
  stopifnot("argument `x` must be single logical or character" =
            (is.character(x) && length(x) == 1L) || isTRUE(x) || isFALSE(x))

  ## current time in milliseconds
  curtime <- floor(as.numeric(Sys.time()) * 1e6)

  if (is.character(x)) {
    lab <- x
  } else {
    lab <- if (!is.null(knitr::opts_current$get("label"))) knitr::opts_current$get("label") else "NULL"
  }

  ## creating unique webex ID
  id <- digest(sprintf("%.0f_%s", curtime, lab), algo = algo)

  ## special character injection
  if (isFALSE(x)) {
      idxtime <- max(1L, curtime %% 32)
      id <- paste0(substr(id, 0, idxtime - 1),
                   c(LETTERS[(26+1-16):26], letters[(26+1-16):26])[idxtime],
                   substr(id, idxtime + 1, nchar(id)))
  }

  return(id)
}

forms_string <- function(answer, width = NULL, usecase = TRUE, usespace = FALSE, regex = FALSE, obfuscate = FALSE) {
  ## Sanity checks
  answer <- as.character(unlist(answer))
  stopifnot(
    "argument `answer` must be of length > 0" = length(answer) > 0,
    "missing values in `answer` not allowed" = all(!is.na(answer)),
    "argument `width` must be NULL or numeric" = is.null(width) || is.numeric(width)
  )
  if (!is.null(width))
    stopifnot("argument `width` must be larger or equal to 1" = (width <- as.integer(width[1L])) >= 1L)

  usecase <- as.logical(usecase); usespace <- as.logical(usespace); regex <- as.logical(regex)
  stopifnot(
    "argument `usecase` must be logical" = isTRUE(usecase) || isFALSE(usecase),
    "argument `usespace` must be logical" = isTRUE(usespace) || isFALSE(usespace),
    "argument `regex` must be logical" = isTRUE(regex) || isFALSE(regex),
    "argument `obfuscate` must be single character or logical" =
        (is.character(obfuscate) && length(obfuscate) == 1) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## getting webex id
  webex_id <- get_webex_id(obfuscate)

  ## answer processing
  if(is.null(width)) width <- min(100L, max(nchar(answer)))
  answers <- json_answer(answer, webex_id)

  ## html format
  classes <- c()
  if (!usecase)  classes <- c(classes, "ignorecase")
  if (!usespace) classes <- c(classes, "nospaces")
  if (regex)     classes <- c(classes, "regex")

  ## html format
  html <- sprintf("<input class='webex-solveme%s' id='webex-%s' size='%s' data-answer='%s'/>",
    if (length(classes) == 0) "" else paste0(" ", paste(classes, collapse = " ")),
    webex_id, width, answers)

  ## plain format
  plain <- paste(c("\\", rep.int("_", width)), collapse = "")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_num <- function(answer, tol = 0, width = NULL, usespace = FALSE, regex = FALSE, obfuscate = FALSE) {
  ## Sanity checks
  ###answer <- as.numeric(unlist(answer))
  stopifnot(
    "argument `answer` must be numeric length 1" = is.numeric(answer) && length(answer) == 1,
    "missing values in `answer` not allowed" = !is.na(answer),
    "argument `width` must be NULL or numeric" = is.null(width) || is.numeric(width)
  )
  if (!is.null(width))
    stopifnot("argument `width` must be larger or equal to 1" = (width <- as.integer(width[1L])) >= 1L)

  usespace <- as.logical(usespace); regex <- as.logical(regex)
  stopifnot(
    "argument `usespace` must be logical" = isTRUE(usespace) || isFALSE(usespace),
    "argument `regex` must be logical" = isTRUE(regex) || isFALSE(regex),
    "argument `obfuscate` must be single character or logical" =
        (is.character(obfuscate) && length(obfuscate) == 1) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## getting webex id
  webex_id <- get_webex_id(obfuscate)

  ## answer processing
  if(is.null(width)) width <- min(100L, max(nchar(answer)))
  answers <- json_answer(answer, webex_id)

  ## html format
  html <- sprintf("<input class='webex-solveme%s%s' id='webex-%s' data-tol='%s' size='%s' data-answer='%s'/>",
    if(!usespace) " nospaces" else "", if(regex) " regex" else "", webex_id, tol, width, answers)

  ## plain format
  plain <- paste(c("\\", rep.int("_", width)), collapse = "")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_schoice <- function(answerlist, solution, display = c("buttons", "dropdown"), obfuscate = FALSE) {
  ## sanity checks
  ## solution processing
  solution    <- as.logical(unlist(solution))
  ## answer processing
  answerlist  <- as.character(unlist(answerlist))
  stopifnot(
    "missing values in `solution` not allowed" = all(!is.na(solution)),
    "missing values in `answerlist` not allowed" = all(!is.na(answerlist)),
    "there must be exactly one correct solution" = sum(solution) == 1L,
    "length of answerlist and solution must match" = length(answerlist) == length(solution),
    "argument `obfuscate` must be single character or logical" =
        (is.character(obfuscate) && length(obfuscate) == 1) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## getting webex id
  webex_id <- get_webex_id(obfuscate)

  if (display == "buttons") {
    ## radio buttons interaction (grouped by random label)
    html <- sprintf("<label><input type='radio' autocomplete='off' name='%s'></input><span>%s</span></label>", webex_id, answerlist)
    html <- sprintf("<div class='webex-radiogroup' id='webex-%s' data-answer='%s'>%s</div>\n",
                    webex_id, json_answer(solution, webex_id), paste(html, collapse = ""))
  } else {
    ## dropdown menu interaction
    html <- sprintf("<option>%s</option>", answerlist)
    html <- sprintf("<select class='webex-select' id='webex-%s' data-answer='%s'><option value='blank'></option>%s</select>",
                    webex_id, json_answer(solution, webex_id), paste(html, collapse = ""))
  }

  ## plain format
  plain <- sprintf("* [ ] %s", answerlist)
  plain <- paste0("\n\n", paste(plain, collapse = "\n"), "\n\n")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_mchoice <- function(answerlist, solution, display = c("buttons", "dropdown"), obfuscate = FALSE) {
  ## sanity checks
  ## solution processing
  solution    <- as.logical(unlist(solution))
  ## answer processing
  answerlist  <- as.character(unlist(answerlist))
  stopifnot(
    "missing values in `solution` not allowed" = all(!is.na(solution)),
    "missing values in `answerlist` not allowed" = all(!is.na(answerlist)),
    "length of answerlist and solution must match" = length(answerlist) == length(solution),
    "argument `obfuscate` must be single character or logical" =
        (is.character(obfuscate) && length(obfuscate) == 1) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## getting webex id
  webex_id <- get_webex_id(obfuscate)

  if(display == "buttons") {
    ## checkbox buttons interaction (grouped by random label)
    html <- sprintf("<label><input type='checkbox' autocomplete='off' name='%s'></input><span>%s</span></label>", webex_id, answerlist)
    html <- sprintf("<div class='webex-checkboxgroup' id='webex-%s' data-answer='%s'>%s</div>\n",
                    webex_id, json_answer(solution, webex_id), paste(html, collapse = ""))
  } else {
    ## dropdown menu interaction
    html <- vapply(solution, function(x) {
      forms_schoice(answerlist = c("TRUE", "FALSE"), solution = c(x, !x), display = "dropdown", obfuscate = obfuscate)
    }, "")
    html <- paste("*", html, answerlist, collapse = "\n")
  }

  ## plain format
  plain <- sprintf("* [ ] %s", answerlist)
  plain <- paste0("\n\n", paste(plain, collapse = "\n"), "\n\n")

  ## return appropriate output format
  if (is_html_output()) html else plain
}


## helper function for determining whether HTML is generated
is_html_output <- function() {
  out_format <- opts_knit$get("out.format")
  pandoc_to <- opts_knit$get("rmarkdown.pandoc.to")
  (is.null(out_format) && is.null(pandoc_to)) || isTRUE(out_format == "html") || isTRUE(pandoc_to == "html")
}


## naive JSON encoder for character vectors and logical vectors.
## If `x` is a logical vector, it is encoded as integer 0/1 (e.g., "[0,1,0,0]") for schoice/mchoice
json_string <- function(x) {
    if (is.logical(x)) {
        x <- paste(as.integer(x), collapse = ",")
    } else {
        x <- sapply(x, function(x) sprintf('\"%s\"', gsub('"', '\\"', x, fixed = TRUE)))
    }
    return(sprintf('[%s]', paste(x, collapse = ", ")))
}

## helper function to retrieve the correct answer as JSON string which is embedded in
## the HTML code. If webex_id is character, obfuscation is applied.
json_answer <- function(x, webex_id = NULL) {
    stopifnot(is.null(webex_id) || (is.character(webex_id) && length(webex_id) == 1))
    webex_id <- if (grepl("[g-zG-Z]", webex_id)) NULL else webex_id
    x <- json_string(x)
    x <- gsub("\'", "&apos;", x, fixed = TRUE)
    return(if (is.null(webex_id)) x else obfuscate(x, webex_id))
}


## helper function to lighten colors in CIELUV
lighten_luv <- function(x, amount = 0.3) {
  x <- convertColor(t(col2rgb(x, alpha = FALSE)/255), from = "sRGB", to = "Luv")
  x[, 1L] <- 100 - (100 - x[, 1L]) * amount
  x[, -1L] <- x[, -1L] * (1 - amount)
  rgb(convertColor(x, from = "Luv", to = "sRGB"))
}


## color styling (not yet used)
style_widgets <- function(incorrect = "#AF5A91", correct = "#388740", highlight = "#5078B1", lighten = 0.3) {
  ## dark palette, default: hcl(c(330, 130, 250), 55, 50)
  ## and light version, default tuned to be similar to: hcl(c(330, 130, 250), 35, 85)
  p_dark  <- substr(adjustcolor(c(incorrect, correct, highlight)), 1L, 7L)
  p_light <- lighten_luv(p_dark, amount = lighten)

  style <- c(
    "",
    "<style>",
    ":root {",
    sprintf("    --incorrect: %s;", p_dark[1L]),
    sprintf("    --incorrect_alpha: %s;", p_light[1L]),
    sprintf("    --correct: %s;", p_dark[2L]),
    sprintf("    --correct_alpha: %s;", p_light[2L]),
    sprintf("    --highlight: %s;", p_dark[3L]),
    "}",
    "  .webex-incorrect, input.webex-solveme.webex-incorrect,",
    "  .webex-radiogroup label.webex-incorrect {",
    "    border: 2px dotted var(--incorrect);",
    "    background-color: var(--incorrect_alpha);",
    "  }",
    "  .webex-correct, input.webex-solveme.webex-correct,",
    "  .webex-radiogroup label.webex-correct {",
    "    border: 2px dotted var(--correct);",
    "    background-color: var(--correct_alpha);",
    "  }",
    "  .webex-box, .webex-solution.open {",
    "    border: 2px solid var(--highlight);n",
    "  }",
    "  .webex-solution button, .webex-check-button {",
    "    background-color: var(--highlight);",
    "  }",
    "</style>",
    ""
  )

  writeLines(style)
}
