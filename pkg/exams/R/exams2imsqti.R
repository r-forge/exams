exams2imsqti <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  resolution = 100, width = 4, height = 4, ...)
{
  ## set up .html transformer
  htmltransform <- make_exercise_transform_html(...)

  ## generate the exam
  exm <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
      resolution = resolution, width = width, height = height), read = NULL,
      transform = htmltransform, write = NULL),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  ## write exam in IMS QTI 1.2 standard to .xml file
  make_exams_write_imsqti(exm, dir, tdir, name, ...)

  invisible(exm)
}


## writes .xml assessments in IMS QTI 1.2 standard
make_exams_write_imsqti <- function(x, dir, tdir = NULL, name = NULL,
  template.assessment = NULL, template.item = NULL, ...)
{
  dir <- path.expand(dir)
  if(is.null(tdir)) {
    dir.create(tdir <- tempfile())
    on.exit(unlink(tdir))
  } else tdir <- path.expand(tdir)
  if(!file.exists(tdir))
    dir.create(tdir)

  pkg_dir <- .find.package("exams")

  ## obtain the number of exams and questions
  nx <- length(x)
  nq <- length(x[[1]])
  
  ## get the assement template.assessment
  template.assessment <- if(is.null(template.assessment)) {
    file.path(pkg_dir, "xml", "imsqti_v1p2p1_assessment.xml")
  } else path.expand(template.assessment)
  if(!file.exists(template.assessment))
    stop(paste("The following file cannot be found: ", template.assessment, "!", sep = ""))
  test_xml <- readLines(template.assessment)

  ## get the assement template.item
  template.item <- if(is.null(template.item)) {
    file.path(pkg_dir, "xml", "imsqti_v1p2p1_item.xml")
  } else path.expand(template.item)
  if(!file.exists(template.item))
    stop(paste("The following file cannot be found: ", template.item, "!", sep = ""))
  item_xml <- readLines(template.item)

  ## get additional arguments
  args <- list(...)

  ## generate the test id
  test_id <- make_id(9)

  ## create a name
  name <- if(is.null(name)) {
    paste("ImsQtiAssessment", test_id, sep = "_")
  } else name

  ## create the directory where the test is stored
  dir.create(test_dir <- file.path(tdir, name))

  ## create section ids
  sec_ids <- paste(paste("Sec", 1:nq, sep = ""), make_id(10, nq), sep = "_")

  ## cycle through all exams and questions
  ## similar questions are combined in a section, questions are then sampled from the sections
  items <- points <- sections <- NULL
  for(j in 1:nq) {
    ## first, create the section header
    sections <- c(sections,
      paste('<section ident="', sec_ids[j], '" title="">', sep = ""),
      '<selection_ordering>',
      '<selection>',
      '<selection_number>1</selection_number>',
      '</selection>',
      '<order order_type="Random"/>',
      '</selection_ordering>'
    )

    ## now, insert the questions
    for(i in 1:nx)
      sections <- c(sections, ex <- write.imsqti.item(x[[i]][[j]], test_dir, item_xml))

    ## end section
    sections <- c(sections, '</section>')
  }

  ## finalize the test xml file, insert id, name and sections
  test_xml <- gsub("##TestIdent", name, test_xml)
  test_xml <- gsub("##TestTitle", name, test_xml)
  test_xml <- input_text("##TestSections", sections, test_xml)

  ## write to dir
  writeLines(test_xml, file.path(test_dir, "qti.xml"))

  ## compress
  owd <- getwd()
  setwd(test_dir)
  zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
  setwd(owd)

  ## copy the final .zip file
  file.copy(file.path(test_dir, zipname), file.path(dir, zipname))

  invisible(NULL)
}


## functions for item construction
write.imsqti.item <- function(x, dir, xml)
{
  ## get the question type
  type <- x$metainfo$type

  ## get the question spec string
  xcq <- switch(type,
    "mchoice" = "MCQ",
    "schoice" = "SCQ",
    "num" = "FIB"
  )

  xname <- toupper(paste(strsplit(x$metainfo$name, " ")[[1]], collapse = ""))

  ## insert an item id
  xml <- gsub("##ItemId", iname <- paste("QTIEDIT", xcq, paste(xname, make_id(10), sep = "_"),
    sep = ":"), xml)

  ## insert maximum attempts
  xml <- gsub("##ItemMaxAttempts",
    if(is.null(x$metainfo$maxattempts)) "1" else as.character(x$metainfo$maxattempts), xml)
  
  ## get the item body
  class(x) <- c(type, "list")
  body <- get.item.body(x)

  ## insert the body text
  xml <- input_text("##ItemBody", body, xml)

  ## insert possible solution
  xml <- input_text("##ItemSolution", x$solution, xml)

  ## insert possible hints
  xml <- input_text("##ItemHints", x$hints, xml)

  ## insert possible feedback
  xml <- input_text("##ItemFeedback", x$feedback, xml)

  ## copy supplements
  if(length(x$supplements)) {
    if(!file.exists(media_dir <- file.path(dir, "media")))
      dir.create(media_dir)
    j <- 1
    while(file.exists(file.path(media_dir, sup_dir <- paste("supplements", j, sep = "")))) {
      j <- j + 1
    }
    dir.create(ms_dir <- file.path(media_dir, sup_dir))
    for(i in seq_along(x$supplements)) {
      file.copy(x$supplements[i], file.path(ms_dir, f <- basename(x$supplements[i])))
      if(any(grepl(f, xml))) {
        xml <- gsub(f, paste("media", sup_dir, f, sep = "/"), xml, fixed = TRUE)
      }
    }
  }

  xml
}


## create question specific item bodies
get.item.body <- function(x)
{
  UseMethod("get.item.body")
}


## multiple/single choice item writer function
get.item.body.mchoice <- get.item.body.schoice <- function(x)
{
  ## generate ids
  resp_id <- paste("RESPONSE", make_id(7), sep = "_")
  qu_id <- paste("choice", make_id(10, n = length(x$questionlist)), sep = "_")

  ## how many points?
  points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

  ## insert the question
  xml <- c(
    '<material>',
    '<mattext texttype="text/html"><![CDATA[',
    x$question,
    ']]></mattext>',
    '</material>'
  )

  ## some more question control
  xml <- c(xml,
    paste('<response_lid ident="', resp_id, '" rcardinality="',
      if(x$metainfo$type == "mchoice") "Multiple" else "Single", '" rtiming="No">', sep = ''),
    paste('<render_choice shuffle="Yes" minnumber="0" maxnumber="',
      length(x$solutionlist), '">', sep = '')
  )

  ## cycling through all answers
  for(i in seq_along(x$questionlist)) {
    xml <- c(xml,
      '<flow_label class="List">',
      paste('<response_label ident="', qu_id[i], '" rshuffle="Yes">', sep = ''),
      '<material>',
      '<mattext texttype="text/html"><![CDATA[',
      x$questionlist[i],
      ']]></mattext>',
      '</material>',
      '</response_label>',
      '</flow_label>'
    )
  }

  ## finish possible answers
  xml <- c(xml,
    '</render_choice>',
    '</response_lid>',
    '</presentation>'
  )

  ## control the answer mechanism of the item
  xml <- c(xml,
    '<resprocessing>',
    '<outcomes>',
    paste('<decvar varname="SCORE" vartype="Decimal" defaultval="0" minvalue="0" maxvalue="',
      points, '" cutvalue="', points, '"/>', sep = ''),
    '</outcomes>')

  ## which are the correct questions?
  xml <- c(xml,
    paste('<respcondition title="Mastery" continue="Yes">', sep = ''),
    '<conditionvar>',
    '<and>'
  )

  ## point to the correct answer
  for(i in seq_along(x$metainfo$solution)) {
    if(x$metainfo$solution[i]) {
      xml <- c(xml,
        paste('<varequal respident="', resp_id, '" case="Yes">', qu_id[i], '</varequal>', sep = '')
      )
    }
  }

  xml <- c(xml,
    '</and>',
    '<not>',
    '<or>'
  )

  ## point to the wrong answer
  for(i in seq_along(x$metainfo$solution)) {
    if(!x$metainfo$solution[i]) {
      xml <- c(xml,
        paste('<varequal respident="', resp_id, '" case="Yes">', qu_id[i], '</varequal>', sep = '')
      )
    }
  }

  xml <- c(xml,
    '</or>',
    '</not>',
    '</conditionvar>',
    paste('<setvar varname="SCORE" action="Set">',
      if(is.null(x$points)) 1 else x$points, '</setvar>', sep = ''),
    paste('<displayfeedback feedbacktype="Response" linkrefid="Mastery"/>', sep = ''),
    '</respcondition>')

  ## actions for wrong selected answers
  xml <- c(xml,
    paste('<respcondition title="Fail" continue="Yes">', sep = ''),
    '<conditionvar>',
    '<or>'
  )

  ## point to the wrong answer
  for(i in seq_along(x$metainfo$solution)) {
    if(!x$metainfo$solution[i]) {
      xml <- c(xml,
        paste('<varequal respident="', resp_id, '" case="Yes">', qu_id[i], '</varequal>', sep = '')
      )
    }
  }

  ## FIXME not clear what options may be used
  xml <- c(xml,
    '</or>',
    '</conditionvar>',
    '<setvar varname="SCORE" action="Set">0</setvar>',
    '<displayfeedback feedbacktype="Response" linkrefid="Fail"/>',
    '<displayfeedback feedbacktype="Solution" linkrefid="Solution"/>',
    '<displayfeedback feedbacktype="Hint" linkrefid="Hint"/>',
    '</respcondition>'
  )

  for(i in seq_along(x$metainfo$solution)) {
    xml <- c(xml,
      paste('<respcondition title="_olat_resp_feedback" continue="Yes">', sep = ''),
      '<conditionvar>',
      paste('<varequal respident="', resp_id, '" case="Yes">', qu_id[i],
        '</varequal>', sep = ''),
      '</conditionvar>',
      paste('<displayfeedback feedbacktype="Response" linkrefid="', qu_id[i], '"/>', sep = ''),
      '</respcondition>'
    )
  }

  xml
}


## numeric item body writer function
get.item.body.num <- function(x)
{
  ## generate an unique id
  resp_id <- paste("RESPONSE", make_id(7), sep = "_")

  ## how many points?
  points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

  ## the correct solution as text
  soltext <- paste(gsub(" ", "", as.character(x$metainfo$solution), fixed = TRUE), collapse = "-")

  ## start general question setup
  xml <- c(
    '<flow>',
    '<material>',
    '<matbreak/>',
    '<mattext texttype="text/html"><![CDATA[',
    x$question,
    ']]></mattext>',
    '<matbreak/>',
    '</material>',
    paste('<response_str ident="', resp_id, '" rcardinality="Single">', sep = ""),
    paste('<render_fib columns="', nchar(soltext), '" maxchars="', nchar(soltext), '">', sep = ""),
    '<flow_label class="Block">',
    paste('<response_label ident="', resp_id, '" rshuffle="Yes"/>', sep = ""),
    '</flow_label>',
    '</render_fib>',
    '</response_str>',
    '<material>',
    '<mattext><![CDATA[]]></mattext>',
    '</material>',
    '</flow>',
    '</presentation>',
    '<resprocessing>',
    '<outcomes>',
    paste('<decvar varname="SCORE" vartype="Decimal" defaultval="0" minvalue="0" maxvalue="',
      points, '" cutvalue="', points, '"/>', sep = ""),
    '</outcomes>',
    '<respcondition title="Mastery" continue="Yes">',
    '<conditionvar>',
    '<and>',
    '<or>',
    paste('<varequal respident="', resp_id, '" case="No"><![CDATA[', soltext, ']]></varequal>', sep = ""),
    '</or>',
    '</and>',
    '</conditionvar>',
    '<setvar varname="SCORE" action="Set">1.0</setvar>',
    '<displayfeedback feedbacktype="Response" linkrefid="Mastery"/>',
    '</respcondition>'
  )

  xml
}


## function to create identfier ids
make_id <- function(size, n = 1)
{
  rval <- NULL
  for(i in 1:n)
    rval <- c(rval, as.numeric(paste(sample(1:9, size, replace = TRUE), collapse = "")))
  rval
}


## input text in character vector
input_text <- function(pattern, replacement, x)
{
  if(length(i <- grep(pattern, x, fixed = TRUE)))
    x <- c(x[1:(i - 1)], replacement, x[(i + 1):length(x)])
  x
}


## other functions, not in use yet
## functions to input test and item controls text
controllist <- function(...) structure(list(...), class = "controllist")

as.character.controllist <- function(x, ...)
{
  paste(
    names(x),
    " = \"",
    sapply(x, paste, collapse = " "),
    "\"", sep = "", collapse = " "
  )
}

