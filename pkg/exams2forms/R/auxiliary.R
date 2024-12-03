## convenience interface for gsub() that returns NULL for NULL
xsub <- function(pattern, replacement, x, ...) {
  if(is.null(x)) {
    return(NULL)
  } else {
    gsub(pattern, replacement, x, ...)
  }
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


## get webex id for 'id/solution checking'. If input `x` is a single character,
## it is returned as is. If input `is.null(x)` we return a specific random webex ID
## for checking the webex ID on the javascript side.
make_webex_id <- function(x, algo = "md5") {
  ## current time in milliseconds
  curtime <- floor(as.numeric(Sys.time()) * 1e6)

  ## label
  lab <- if (is.character(x)) x[1L] else opts_current$get("label")
  if (!is.character(lab)) lab <- "exams2forms"

  ## creating unique webex id
  id <- digest(sprintf("%.0f_%s", curtime, lab), algo = algo)

  ## special character injection
  if (isFALSE(x)) {
    idxtime <- max(1L, curtime %% 32)
    substr(id, idxtime, idxtime) <- c(LETTERS[11L:26L], letters[11L:26L])[idxtime]
  }

  return(id)
}

## digest transformer handling obfuscate argument
make_exercise_transform_digest <- function(obfuscate = TRUE) {
  function(x) {
    x$metainfo$obfuscate <- obfuscate
    return(x)
  }
}



#' Encode/Decode (Obfuscate) Answer
#'
#' Takes the correct answer (or the obfuscated correct answer) and an
#' obfuscation key to "enfuscate/defuscate" (encode/decode) the correct answer
#' using a combination of xOR "encryption" and base64 encoding.
#'
#' @param x character, correct (obfuscated) answer (character of length 1).
#' @param key character, obfuscation key. Must be length with 1 or more characters.
#' @param encrypt logical, if `TRUE` (default) argument `x` is encoded,
#'        else it is decoded (for testing).
#'
#' @return Returns the obfuscated (or defuscated) answer.
obfuscate <- function(x, key, encrypt = TRUE) {
  # convert input string and key to raw bytes
  x_raw <- if (encrypt) charToRaw(x) else base64decode(x)
  key_raw <- charToRaw(key)

  # repeat the key to match the length of the input
  key_repeated <- rep(key_raw, length.out = length(x_raw))

  # perform XOR operation (convert to integer, XOR, then back to raw)
  raw <- as.raw(bitwXor(as.integer(x_raw), as.integer(key_repeated)))

  if (encrypt) {
    res <- base64encode(raw)
  } else {
    res <- rawToChar(raw)
  }
  return(res)
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

## helper function to lighten colors in CIELUV
lighten_luv <- function(x, amount = 0.3) {
  x <- convertColor(t(col2rgb(x, alpha = FALSE)/255), from = "sRGB", to = "Luv")
  x[, 1L] <- 100 - (100 - x[, 1L]) * amount
  x[, -1L] <- x[, -1L] * (1 - amount)
  rgb(convertColor(x, from = "Luv", to = "sRGB"))
}
