exams2arsnova <- function(file, n = 1L, dir = ".", name = "VU",
  quiet = TRUE, resolution = 100, width = 4, height = 4, encoding = "", converter = "ttm",
  url = "https://arsnova.eu/", sessionkey = NULL, jsessionid = NULL,
  active = TRUE, showstatistic = FALSE, showanswer = FALSE, abstention = TRUE,
  variant = "lecture", ssl.verifypeer = TRUE, ...)
{
  ## check whether JSON data can actually be POSTed
  post <- TRUE
  if(is.null(url) | is.null(sessionkey) | is.null(jsessionid)) post <- FALSE

  ## custom reader with rather crude fixup of LaTeX elements
  arsnovaread <- function(...) {
    rval <- read_exercise(...)
    rval$questionlist <- gsub("$", "", rval$questionlist, fixed = TRUE)
    rval$questionlist <- gsub("\\", "", rval$questionlist, fixed = TRUE)
    rval
  }

  ## HTML transformer
  # htmltransform <- make_exercise_transform_html(converter = converter, base64 = TRUE)
  htmltransform <- make_exercise_transform_pandoc(to = "markdown")

  ## create PDF write with custom options
  arsnovawrite <- make_exams_arsnovawrite(url = url, sessionkey = sessionkey, jsessionid = jsessionid,
    post = post, name = name, active = active, showstatistic = showstatistic, showanswer = showanswer,
    abstention = abstention, variant = variant, ssl.verifypeer = ssl.verifypeer)

  ## generate xexams
  rval <- xexams(file, n = n, dir = dir,
    driver = list(
      sweave = list(quiet = quiet, pdf = FALSE, png = TRUE, resolution = resolution, width = width, height = height, encoding = encoding),
      read = arsnovaread,
      transform = htmltransform,
      write = arsnovawrite),
    ...)

  ## return xexams object invisibly
  invisible(rval)
}

make_exams_arsnovawrite <- function(url, sessionkey, jsessionid, post = TRUE,
    name = "VU", active = TRUE, showstatistic = FALSE, showanswer = FALSE,
    abstention = TRUE, variant = "lecture", ssl.verifypeer = TRUE)
{
  ## curl info
  url <- if(substr(url, nchar(url), nchar(url)) == "/") url <- substr(url, 1L, nchar(url) - 1L)
  url <- sprintf("%s/lecturerquestion/?sessionkey=%s", url, sessionkey)
  head <- c("Content-Type: application/json; charset=UTF-8",
    paste0("Cookie: JSESSIONID=", jsessionid))

  ## question list template
  qtemp <- list(
    type = "skill_question",
    questionType = "abcd",
    questionVariant = match.arg(variant, c("lecture", "preparation")),
    subject = name,
    text = NULL,
    active = active,
    releasedFor = "all",
    possibleAnswers = list(),
    noCorrect = FALSE,
    sessionKeyword = sessionkey,
    showStatistic = showstatistic,
    showAnswer = showanswer,
    abstention = abstention
  )
  
  ## set up actual write function
  function(exm, dir, info)
  {
    ## basic indexes
    id <- info$id
    n <- info$n
    m <- length(exm)

    ## check whether all exercises are schoice/mchoice
    wrong_type <- sapply(1L:m, function(n) exm[[n]]$metainfo$file)[
      !sapply(1L:m, function(n) exm[[n]]$metainfo$type %in% c("schoice", "mchoice", "num", "string"))]
    if(length(wrong_type) > 0) {
      stop(paste("the following exercises are not supported:",
        paste(wrong_type, collapse = ", ")))
    }
  
    for(j in 1L:m) {
      ## copy question template and adapt subject
      json <- qtemp      
      if(m > 1L) json$subject <- paste0(name, "/", formatC(j,  width = floor(log10(m)) + 1L, flag = "0"))

      ## collapse question text
      json$text <- paste(exm[[j]]$question, collapse = " ")

      ## questionType and possibleAnswers
      if(exm[[j]]$metainfo$type %in% c("schoice", "mchoice")) {
        json$possibleAnswers <- lapply(seq_along(exm[[j]]$questionlist),
          function(i) list(text = as.vector(exm[[j]]$questionlist)[i], correct = exm[[j]]$metainfo$solution[i]))
      }
      if(exm[[j]]$metainfo$type == "mchoice") {
        json$questionType <- "mc"
        json$noCorrect <- sum(exm[[j]]$metainfo$solution) > 0
      }
      if(exm[[j]]$metainfo$type %in% c("num", "string")) json$questionType <- "freetext"

      ## convert to JSON
      json <- RJSONIO::toJSON(json)      

      if(post) {
        w <- RCurl::basicTextGatherer()
        rval <- RCurl::curlPerform(url = url, httpheader = head, postfields = json, writefunction = w$update,
          ssl.verifypeer = ssl.verifypeer)
	if(rval != 0) warning(paste("question", j, "could not be posted"))
	w$reset()
      } else {
        ## entire curl command string
        curl <- sprintf("curl '%s' -X POST %s --data '%s'",
          url, paste0("-H '", head, "'", collapse = " "), json)

        ## assign names for output files
        fil <- paste0(name, "-",
          formatC(id, width = floor(log10(n)) + 1L, flag = "0"), "-",
          formatC(j,  width = floor(log10(m)) + 1L, flag = "0"), ".json")

        ## create and compile output json
        writeLines(json, fil)
        file.copy(fil, dir, overwrite = TRUE)
      }
    }
  }
}
