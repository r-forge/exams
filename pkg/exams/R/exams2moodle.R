## generate exams in .xml format
exams2moodle <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  solution = TRUE, doctype = NULL, head = NULL, resolution = 100,
  width = 4, height = 4, ...)
{
  ## set up .xml transformer and writer function
  htmltransform <- make_exercise_transform_x(...)
  moodlewrite <- make_exams_write_moodle(name, ...)

  ## create final .xml exam
  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
      resolution = resolution, width = width, height = height),
      read = NULL, transform = htmltransform, write = moodlewrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}


## writes the final .xml site
make_exams_write_moodle <- function(name = NULL, ...)
{
  function(x, dir, info)
  {
    args <- list(...)

    if(is.null(name))
      name <- "MoodleExam"
    name <- paste(name, as.character(Sys.Date()), info$id, sep = "-")

    dir.create(tdir <- tempfile())
    on.exit(unlink(tdir))
    dir.create(test_dir <- file.path(tdir, name))

    ## start to write the exam.xml
    exam.xml <- c(
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<quiz>',
      '<question type="category">',
      '<category>',
      paste('<text>$course$/', args$category, '</text>', sep = ""),
      '</category>',
      '</question>'
    )

    ## cycle trough th questions
    sfiles <- NULL
    for(ex in x) {
      class(ex) <- c(ex$metainfo$type, "list")
      exam.xml <- c(exam.xml, write.moodle.question(ex))
      sfiles <- c(sfiles, x$supplements)
    }

    ## finish the exam xml
    exam.xml <- c(exam.xml, '</quiz>')

    ## write xml to dir and copy supplements
    writeLines(exam.xml, file.path(test_dir, paste(name, "xml", sep = ".")))
    if(length(sfiles))
      for(i in sfiles)
        file.copy(i, file.path(test_dir, basename(i)))

    ## compress
    owd <- getwd()
    setwd(test_dir)
    zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
    setwd(owd)

    ## copy the final .zip file
    file.copy(file.path(test_dir, zipname), file.path(dir, zipname))

    invisible(NULL)
  }
}


## generic WU question writer function
write.moodle.question <- function(x)
{
  UseMethod("write.moodle.question")
}


## write moodle mchoice question
write.moodle.question.mchoice <- function(x)
{
  ## set up question .xml
  id <- make_id(10)
  xml <- c(
    '<question type="multichoice">',
    paste('<name><text>', gsub(" ", "_", paste(x$metainfo$name, id, sep = "_")), '</text></name>', sep = ""),
    '<questiontext format="html">',
    '<text><![CDATA[',
    x$question,
    ']]></text>',
    '</questiontext>',
    paste('<defaultgrade>',
      if(is.null(x$metainfo$points)) 1 else x$metainfo$points, '</defaultgrade>',
      sep = ""),
    paste('<shuffleanswers>',
      if(!is.null(x$metainfo$shuffle)) as.integer(x$metainfo$shuffle) else 1, '</shuffleanswers>',
      sep = ""),
    '<single>false</single>'
  )
  n <- length(x$solutionlist)
  frac <- rep(-100, n)
  frac[x$metainfo$solution] <- 100 / sum(x$metainfo$solution)
  for(i in 1:n) {
    xml <- c(
      xml,
      paste('<answer fraction="', frac[i], '">', sep = ""),
      '<text>',
      x$questionlist[i],
      '</text>',
      '<feedback format="html">',
      '<text><![CDATA[',
      if(!is.null(x$solutionlist)) x$solutionlist[i] else NULL,
      ']]></text>',
      '</feedback>',
      '</answer>'
    )
  }
  xml <- c(xml, '</question>')

  ## path replacements
  xml <- gsub(paste(attr(x$supplements, "dir"), .Platform$file.sep, sep = ""), "", xml)

  xml
}


## write moodle num question
write.moodle.question.num <- function(x)
{
  ## set up question .xml
  id <- make_id(10)
  xml <- c(
    '<question type="numerical">',
    paste('<name><text>', gsub(" ", "_", paste(x$metainfo$name, id, sep = "_")), '</text></name>', sep = ""),
    '<questiontext format="html">',
    '<text><![CDATA[',
    x$question,
    ']]></text>',
    '</questiontext>',
    paste('<defaultgrade>',
      if(is.null(x$metainfo$points)) 1 else x$metainfo$points, '</defaultgrade>',
      sep = ""),
    '<answer fraction="100">',
    paste('<text>', x$metainfo$solution, '</text>', sep = ""),
    paste('<tolerance>', x$metainfo$tolerance[1], '</tolerance>', sep = ""),
    '<feedback format="html">',
    '<text><![CDATA[',
    x$solution,
    ']]></text>',
    '</feedback>',
    '</answer>',
    '</question>'
  )

  ## path replacements
  xml <- gsub(paste(attr(x$supplements, "dir"), .Platform$file.sep, sep = ""), "", xml)

  xml
}
