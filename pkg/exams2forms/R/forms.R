forms_string <- function(answer, width = NULL, usecase = TRUE, usespace = FALSE, regex = FALSE) {
  ## answer processing
  answer <- as.character(unlist(answer))
  if(is.null(width)) width <- min(100L, max(nchar(answer)))
  answers <- json_string(answer)
  answers <- gsub("\'", "&apos;", answers, fixed = TRUE)

  ## html format
  html <- sprintf("<input class='webex-solveme%s%s%s' size='%s' data-answer='%s'/>",
    if(!usespace) " nospaces" else "", if(!usecase) " ignorecase" else "", if(regex) " regex" else "", width, answers)

  ## plain format
  plain <- paste(c("\\", rep.int("_", width)), collapse = "")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_num <- function(answer, tol = 0, width = NULL, usespace = FALSE, regex = FALSE) {
  ## answer processing
  answer <- unlist(answer)
  if(is.null(width)) width <- min(100L, max(nchar(answer)))
  answers <- json_string(as.character(answer))
  answers <- gsub("\'", "&apos;", answers, fixed = TRUE)

  ## html format
  html <- sprintf("<input class='webex-solveme%s%s' data-tol='%s' size='%s' data-answer='%s'/>",
    if(!usespace) " nospaces" else "", if(regex) " regex" else "", tol, width, answers)

  ## plain format
  plain <- paste(c("\\", rep.int("_", width)), collapse = "")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_schoice <- function(answerlist, solution, display = c("buttons", "dropdown")) {
  ## sanity checks
  stopifnot(
    "there must be exactly one correct solution" = sum(solution) == 1L,
    "length of answerlist and solution must match" = length(answerlist) == length(solution)
  )
  
  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## answer processing
  answerlist <- as.character(unlist(answerlist))
  answerlist2 <- gsub("\'", "&apos;", answerlist, fixed = TRUE)

  if(display == "buttons") {
    ## radio buttons interaction (grouped by random label)
    lab <- paste0("radio_group_", paste(sample(letters, 10, replace = TRUE), collapse = ""))
    html <- sprintf("<label><input type='radio' autocomplete='off' name='%s' value='%s'></input><span>%s</span></label>",
      lab, ifelse(solution, "answer", ""), answerlist2)
    html <- sprintf("<div class='webex-radiogroup' id='%s'>%s</div>\n", lab, paste(html, collapse = ""))
  } else {
    ## dropdown menu interaction
    html <- sprintf("<option value='%s'>%s</option>", ifelse(solution, "answer", ""), answerlist2)
    html <- sprintf("<select class='webex-select'><option value='blank'></option>%s</select>", paste(html, collapse = ""))
  }

  ## plain format
  plain <- sprintf("* [ ] %s", answerlist)
  plain <- paste0("\n\n", paste(plain, collapse = "\n"), "\n\n")

  ## return appropriate output format
  if (is_html_output()) html else plain
}

forms_mchoice <- function(answerlist, solution, display = c("buttons", "dropdown")) {
  ## sanity checks
  stopifnot(
    "length of answerlist and solution must match" = length(answerlist) == length(solution)
  )
  
  ## type of interaction/display
  display <- match.arg(display, c("buttons", "dropdown"))

  ## answer processing
  answerlist <- as.character(unlist(answerlist))
  answerlist2 <- gsub("\'", "&apos;", answerlist, fixed = TRUE)

  if(display == "buttons") {
    ## checkbox buttons interaction (grouped by random label)
    lab <- paste0("checkbox_group_", paste(sample(letters, 10, replace = TRUE), collapse = ""))
    html <- sprintf("<label><input type='checkbox' autocomplete='off' name='%s' value='%s'></input><span>%s</span></label>",
      lab, ifelse(solution, "answer", ""), answerlist2)
    html <- sprintf("<div class='webex-checkboxgroup' id='%s'>%s</div>\n", lab, paste(html, collapse = ""))
  } else {
    ## dropdown menu interaction
    html <- vapply(solution, function(x) {
      forms_schoice(answerlist = c("TRUE", "FALSE"), solution = c(x, !x), display = "dropdown")
    }, "")
    html <- paste("*", html, answerlist2, collapse = "\n")
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


## start/end for solution boxes
solutionbox_start <- function(title = NULL, quarto = NULL) {
  quarto <- is.null(getOption("knitr.in.progress"))
  if (quarto) {
    title <- if(is.null(title)) "\n" else sprintf("## %s\n\n", title)
    paste0("\n::: {.callout-note collapse='true'}\n", title)
  } else {
    title <- if(is.null(title)) "" else sprintf("<h4>%s</h4>", title)
    paste0("\n<div class='webex-solution'>\n", title)
  }
}

solutionbox_end <- function(quarto = NULL) {
  quarto <- is.null(getOption("knitr.in.progress"))
  if (quarto) {
    "\n:::\n\n"
  } else {
    "\n</div>\n"
  }
}


## naive JSON encoder for single character strings
json_string <- function(x) sprintf('["%s"]', gsub('"', '\\"', x, fixed = TRUE))


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
