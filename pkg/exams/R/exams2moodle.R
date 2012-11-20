## generate exams in Moodle 2.3 .xml format
## http://docs.moodle.org/23/en/Moodle_XML_format
exams2moodle <- function(file, n = 1L, nsamp = NULL, dir,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  resolution = 100, width = 4, height = 4,
  num = NULL, mchoice = NULL, schoice = mchoice, string = NULL, cloze = NULL,
  zip = FALSE, ...)
{
  ## set up .html transformer
  htmltransform <- make_exercise_transform_html(...)

  ## generate the exam
  exm <- xexams(file, n = n, nsamp = nsamp,
   driver = list(
       sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
         resolution = resolution, width = width, height = height),
       read = NULL, transform = htmltransform, write = NULL),
     dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  ## get the possible moodle question body functions and options
  moodlequestion = list(num = num, mchoice = mchoice, schoice = schoice, cloze = cloze, string = string)

  for(i in c("num", "mchoice", "schoice", "cloze", "string")) {
    if(is.null(moodlequestion[[i]])) moodlequestion[[i]] <- list()
    if(is.list(moodlequestion[[i]])) moodlequestion[[i]] <- do.call("make_question_moodle23", moodlequestion[[i]])
    if(!is.function(moodlequestion[[i]])) stop(sprintf("wrong specification of %s", sQuote(i)))
  }

  ## create a temporary directory
  dir <- path.expand(dir)
  if(is.null(tdir)) {
    dir.create(tdir <- tempfile())
    on.exit(unlink(tdir))
  } else {
    tdir <- path.expand(tdir)
  }
  if(!file.exists(tdir)) dir.create(tdir)

  ## obtain the number of exams and questions
  nx <- length(exm)
  nq <- length(exm[[1L]])

  ## create a name
  if(is.null(name)) name <- "MoodleExam"

  ## function for internal ids
  make_test_ids <- function(n, type = c("test", "section", "item"))
  {
    switch(type,
      "test" = paste(name, make_id(9), sep = "_"),
      paste(type, formatC(1:n, flag = "0", width = nchar(n)), sep = "_")
    )
  }

  ## generate the test id
  test_id <- make_test_ids(type = "test")

  ## create section ids
  question_ids <- paste(test_id, make_test_ids(nq, type = "question"), sep = "/")

  ## create the directory where the test is stored
  dir.create(test_dir <- file.path(tdir, name))

  ## start the quiz .xml
  xml <- c('<?xml version="1.0" encoding="UTF-8"?>', '<quiz>\n')

  ## cycle through all questions and samples
  for(j in 1:nq) {
    ## first, create the category tag for the question
    xml <- c(xml,
      '\n<question type="category">',
      '<category>',
      paste('<text>$course$/', question_ids[j], '</text>', sep = ''),
      '</category>',
      '</question>\n')

    ## create ids for all samples
    sample_ids <- paste(question_ids[j], make_test_ids(nx, type = "sample"), sep = "_")

    ## create the questions
    for(i in 1:nx) {
      ## get the question type
      type <- exm[[i]][[j]]$metainfo$type

      ## attach sample id to metainfo
      exm[[i]][[j]]$metainfo$id <- paste(sample_ids[i], type, sep = "_")

      ## create the .xml
      question_xml <- moodlequestion[[type]](exm[[i]][[j]])

      ## copy supplements
      if(length(exm[[i]][[j]]$supplements)) {
        if(!file.exists(media_dir <- file.path(test_dir, "media")))
          dir.create(media_dir)
        sj <- 1
        while(file.exists(file.path(media_dir, sup_dir <- paste("supplements", sj, sep = "")))) {
          sj <- sj + 1
        }
        dir.create(ms_dir <- file.path(media_dir, sup_dir))
        for(si in seq_along(exm[[i]][[j]]$supplements)) {
          file.copy(exm[[i]][[j]]$supplements[si],
            file.path(ms_dir, f <- basename(exm[[i]][[j]]$supplements[si])))
          if(any(grepl(f, question_xml))) {
            question_xml <- gsub(f, paste("media", sup_dir, f, sep = "/"), question_xml, fixed = TRUE)
          }
        }
      }

      ## add question to quiz .xml
      xml <- c(xml, question_xml)
    }
  }

  ## finish the quiz
  xml <- c(xml, '</quiz>')

  ## write to dir
  writeLines(xml, file.path(test_dir, paste(name, "xml", sep = ".")))

  ## compress
  if(zip) {
    owd <- getwd()
    setwd(test_dir)
    zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
    setwd(owd)
  } else zipname <- list.files(test_dir)

  ## copy the final .zip file
  file.copy(file.path(test_dir, zipname), if(zip) file.path(dir, zipname) else dir, recursive = TRUE)

  ## assign test id as an attribute
  attr(exm, "test_id") <- test_id

  invisible(exm)
}


## Moodle 2.3 question constructor function
make_question_moodle23 <- function(name = NULL, shuffle = TRUE, penalty = 0, answernumbering = "abc",
  usecase = FALSE, cloze_mchoice_display = "MULTICHOICE_V")
{
  function(x) {
    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    ## match question type
    type <- switch(x$metainfo$type,
      "num" = "numerical",
      "mchoice" = "multichoice",
      "schoice" = "multichoice",
      "cloze" = "cloze",
      "string" = "shortanswer"
    )

    ## question name
    if(is.null(name)) name <- x$metainfo$name

    ## start the question xml
    xml <- c(
      paste('\n<question type="', type, '">', sep = ''),
      '<name>',
      paste('<text>', name, '</text>'),
      '</name>',
      '<questiontext format="html">',
      '<text><![CDATA[<p>', if(type != "cloze") x$question else '##QuestionText', '</p>]]></text>',
      '</questiontext>'
    )

    ## insert the solution
    if(length(x$solution)) {
      xml <- c(xml,
        '<generalfeedback format="html">',
        '<text><![CDATA[<p>', x$solution,
        if(!type %in% c("mchoice", "schoice") && length(x$solutionlist)) x$solutionlist else NULL,
        '</p>]]></text>',
        '</generalfeedback>'
      )
    }

    ## penalty and points
    xml <- c(xml,
      paste('<penalty>', penalty, '</penalty>', sep = ''),
      paste('<defaultgrade>', points, '</defaultgrade>', sep = '')
    )

    ## multiple choice processing
    if(type == "multichoice") {
      xml <- c(xml,
        paste('<shuffleanswers>', if(shuffle) 'true' else 'false', '</shuffleanswers>', sep = ''),
        paste('<single>', if(x$metainfo$type == "schoice") 'true' else 'false', '</single>', sep = ''),
        paste('<answernumbering>', answernumbering, '</answernumbering>', sep = '')
      )

      n <- length(x$solutionlist)
      frac <- rep(0, n)
      frac[x$metainfo$solution] <- 100 / sum(x$metainfo$solution)
      for(i in 1:n) {
        xml <- c(
          xml,
          paste('<answer fraction="', frac[i], '" format="html">', sep = ''),
          '<text><![CDATA[<p>', x$questionlist[i], '</p>]]></text>',
          if(!is.null(x$solutionlist[i])) {
            c('<feedback format="html">',
            '<text><![CDATA[<p>', x$solutionlist[i], '</p>]]></text>',
            '</feedback>')
          } else NULL,
          '</answer>'
        )
      }
    }

    ## numeric question processing
    if(type == "numerical") {
      xml <- c(xml,
        '<answer fraction="100" format="moodle_auto_format">',
        paste('<text>', x$metainfo$solution, '</text>', sep = ''),
        paste('<tolerance>', x$metainfo$tolerance[1], '</tolerance>', sep = ''),
        '</answer>'
      )
    }

    ## string questions
    if(type == "shortanswer") {
      xml <- c(xml,
        paste('<usecase>', usecase * 1, '</usecase>', sep = ''),
        '<answer fraction="100" format="moodle_auto_format">',
        '<text>', x$metainfo$solution, '</text>',
        '</answer>'
      )
    }

    ## cloze type questions
    if(type == "cloze") {
      qtext <- c('<pre>', x$question)
      for(i in seq_along(x$metainfo$clozetype)) {
        qtext <- c(qtext, x$questionlist[i])
        if(x$metainfo$clozetype[i] %in% c("mchoice", "schoice")) { ## FIXME: schoice
          tmp <- paste('{', length(x$metainfo$solution[i]), ':', cloze_mchoice_display, ':', sep = '')
          for(j in seq_along(x$metainfo$solution[[i]])) {
            sol <- if(!is.null(x$solutionlist[[i]][j])) x$solutionlist[[i]][j] else j
            tmp <- paste(tmp, paste(if(x$metainfo$solution[[i]][j]) '=' else '~', sol, sep = ''), sep = '')
          }
          tmp <- paste(tmp, '}', sep = '')
        }
        qtext <- c(qtext, tmp)
      }
      qtext <- c(qtext, '</pre>')
      xml <- gsub('##QuestionText', paste(qtext, collapse = "\n"), xml)
    }

    ## end the question
    xml <- c(xml, '</question>\n')

    ## path replacements
    xml <- gsub(paste(attr(x$supplements, "dir"), .Platform$file.sep, sep = ""), "", xml)

    xml
  }
}

