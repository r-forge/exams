forms_string <- function(answer, width = NULL, usecase = TRUE, usespace = FALSE, regex = FALSE, obfuscate = TRUE) {
  ## sanity checks
  answer <- as.character(unlist(answer))
  stopifnot(
    "'answer' must be of length > 0" = length(answer) > 0,
    "missing values in 'answer' not allowed" = all(!is.na(answer)),
    "'width' must be NULL or numeric" = is.null(width) || is.numeric(width)
  )
  if (!is.null(width))
    stopifnot("'width' must be larger or equal to 1" = (width <- as.integer(width[1L])) >= 1L)

  usecase <- as.logical(usecase)
  usespace <- as.logical(usespace)
  regex <- as.logical(regex)
  if (is.null(obfuscate)) obfuscate <- TRUE
  stopifnot(
    "'usecase' must be logical" = isTRUE(usecase) || isFALSE(usecase),
    "'usespace' must be logical" = isTRUE(usespace) || isFALSE(usespace),
    "'regex' must be logical" = isTRUE(regex) || isFALSE(regex),
    "'obfuscate' must be logical (or character)" =
        (is.character(obfuscate) && length(obfuscate) == 1L) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## getting webex id
  webex_id <- make_webex_id(obfuscate)

  ## answer processing
  if(is.null(width)) width <- min(100L, max(nchar(answer)))
  if (!usecase) answer <- tolower(answer)
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

forms_num <- function(answer, tol = 0, width = NULL, usespace = FALSE, regex = FALSE, obfuscate = TRUE) {
  ## sanity checks
  stopifnot(
    "'answer' must be numeric length 1" = is.numeric(answer) && length(answer) == 1,
    "missing values in 'answer' not allowed" = !is.na(answer),
    "'width' must be NULL or numeric" = is.null(width) || is.numeric(width)
  )
  if (!is.null(width))
    stopifnot("'width' must be larger or equal to 1" = (width <- as.integer(width[1L])) >= 1L)

  usespace <- as.logical(usespace)
  regex <- as.logical(regex)
  if (is.null(obfuscate)) obfuscate <- TRUE
  stopifnot(
    "'usespace' must be logical" = isTRUE(usespace) || isFALSE(usespace),
    "'regex' must be logical" = isTRUE(regex) || isFALSE(regex),
    "'obfuscate' must be logical (or character)" =
        (is.character(obfuscate) && length(obfuscate) == 1L) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## getting webex id
  webex_id <- make_webex_id(obfuscate)

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

forms_schoice <- function(answerlist, solution, display = c("buttons", "dropdown"), obfuscate = TRUE) {
  ## sanity checks
  ## solution processing
  solution    <- as.logical(unlist(solution))
  ## answer processing
  answerlist  <- as.character(unlist(answerlist))
  if (is.null(obfuscate)) obfuscate <- TRUE
  stopifnot(
    "missing values in 'solution' not allowed" = all(!is.na(solution)),
    "missing values in 'answerlist' not allowed" = all(!is.na(answerlist)),
    "there must be exactly one correct solution" = sum(solution) == 1L,
    "length of answerlist and solution must match" = length(answerlist) == length(solution),
    "'obfuscate' must be logical (or character)" =
        (is.character(obfuscate) && length(obfuscate) == 1L) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## getting webex id
  webex_id <- make_webex_id(obfuscate)

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

forms_mchoice <- function(answerlist, solution, display = c("buttons", "dropdown"), obfuscate = TRUE) {
  ## sanity checks
  ## solution processing
  solution    <- as.logical(unlist(solution))
  ## answer processing
  answerlist  <- as.character(unlist(answerlist))
  if (is.null(obfuscate)) obfuscate <- TRUE
  stopifnot(
    "missing values in 'solution' not allowed" = all(!is.na(solution)),
    "missing values in 'answerlist' not allowed" = all(!is.na(answerlist)),
    "length of answerlist and solution must match" = length(answerlist) == length(solution),
    "'obfuscate' must be logical (or character)" =
        (is.character(obfuscate) && length(obfuscate) == 1L) || isTRUE(obfuscate) || isFALSE(obfuscate)
  )

  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## getting webex id
  webex_id <- make_webex_id(obfuscate)

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


## FIXME: helper function for determining whether HTML is generated, should be improved
is_html_output <- function() {
  out_format <- opts_knit$get("out.format")
  pandoc_to <- opts_knit$get("rmarkdown.pandoc.to")
  (is.null(out_format) && is.null(pandoc_to)) || isTRUE(out_format == "html") || isTRUE(pandoc_to == "html")
}
