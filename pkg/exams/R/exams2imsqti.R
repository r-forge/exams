exams2imsqti <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  type = "html", converter = "ttx", base64 = TRUE, width = 550,
  body = TRUE, solution = TRUE, doctype = NULL, head = NULL, ...)
{
  transform2x <- make_exercise_transform_x(converter = converter,
    base64 = base64, body = body, width = width, ...)

  exm <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL,
      transform = transform2x, write = NULL),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  make_exams_write_imsqti(exm, dir, tdir, name, base64, ...)

  invisible(exm)
}


make_exams_write_imsqti <- function(x, dir, tdir = NULL, name = NULL,
  base64 = NULL, template = NULL, ...)
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
  
  ## get the assement template
  template <- if(is.null(template)) {
    file.path(pkg_dir, "xml", "imsqti_v1p2p1_assessment.xml")
  } else path.expand(template)
  if(!file.exists(template))
    stop(paste("The following file cannot be found: ", template, "!", sep = ""))
  test_xml <- readLines(template)

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
      paste('<section ident="', sec_ids[j], '" title="">'),
      '<selection_ordering>',
      '<selection>',
      '<selection_number>1</selection_number>',
      '</selection>',
      '<order order_type="Random"/>',
      '</selection_ordering>'
    )

    ## now, insert the questions
    for(i in 1:nx) {
      exwriter <- eval(parse(text = paste("write.imsqti.item", x[[i]][[j]]$metainfo$type, sep = ".")))
      sections <- c(sections, ex <- exwriter(x[[i]][[j]], test_dir, base64, ...))
      if(!is.null(ex)) {
        a <- 1
      }
    }

    ## end section
    sections <- c(sections, '</section>')
  }

  ## finalize the test xml file, insert id, name and sections
  test_xml <- gsub("##TestIdent", test_id, test_xml)
  test_xml <- gsub("##TestTitle", name, test_xml)
  test_xml <- input_text("##TestSections", sections, test_xml)

  ## formating issues
  test_xml <- xml_indent(test_xml)

  ## delete blank lines
  test_xml <- test_xml[-grep("^ *$", test_xml)]

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


## generic function for item construction
write.imsqti.item <- function(x, dir, xml...)
{
  UseMethod("write.imsqti.item")
}


## multiple/single choice writer function
write.imsqti.item.mchoice <- write.imsqti.item.schoice <- function(x, dir, base64 = NULL, ...)
{
  ## multiple or single choice?
  mchoice <- x$metainfo$type == "mchoice"

  ## obtain controling parameters
  ic <- do.call("item.control", delete.args(item.control, x$metainfo))

  ## generate an unique id
  item_id <- paste(if(mchoice) "QTIEDIT:MCQ" else "QTIEDIT:SCQ", ic$title, make_id(10), sep = ":")
  resp_id <- paste("RESPONSE", make_id(7), sep = "_")
  qu_id <- paste("choice", make_id(10), sep = "_")

  ## hard setting mchoice-question specific arguments
  ic$rcardinality <- if(mchoice) "Multiple" else "Single"

  ## start general question setup
  xml <- c(
    paste('<item ident="', item_id, '" title="', ic$title,
      '" maxattempts="', ic$maxattempts,'">', sep = ''),
    paste('<itemcontrol feedbackswitch="', ic$feedbackswitch, '" hintswitch="',
      ic$hintswitch, '" solutionswitch="', ic$solutionswitch, '"/>', sep = ''),
    '<presentation>')

  ## insert the question
  xml <- c(xml,
    '<material>',
    '<mattext texttype="text/html"><![CDATA[',
    x$question,
    ']]></mattext>',
    '</material>'
  )

  ## some more question controling
  xml <- c(xml,
    paste('<response_lid ident="', resp_id, '" rcardinality="',
      ic$rcardinality, '" rtiming="', ic$rtiming, '">', sep = ''),
    paste('<render_choice shuffle="', ic$shuffle,
      '" minnumber="', if(is.null(ic$minnumber)) 0 else ic$minnumber,
      '" maxnumber="', if(is.null(ic$maxnumber)) length(x$solutionlist) else ic$maxnumber,
      '">', sep = '')
  )

  ## cycling through all answers
  for(i in seq_along(x$questionlist)) {
    xml <- c(xml,
      '<flow_label class="List">',
      paste('<response_label ident="', qu_id[i], '" rshuffle="', ic$rshuffle, '">', sep = ''),
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
    paste('<decvar varname="', ic$varname, '" vartype="', ic$vartype,
      '" defaultval="', ic$defaultval, '" minvalue="', ic$minvalue,
      '" maxvalue="', ic$maxvalue, '" cutvalue="', ic$cutvalue, '"/>', sep = ''),
    '</outcomes>')

  ## which are the correct questions?
  xml <- c(xml,
    paste('<respcondition title="', 'Mastery', '" continue="',
      ic$continue, '">', sep = ''),
    '<conditionvar>',
    '<and>'
  )

  ## point to the correct answer
  for(i in seq_along(x$metainfo$solution)) {
    if(x$metainfo$solution[i]) {
      xml <- c(xml,
        paste('<varequal resp_ident="', resp_id, '" case="',
          ic$case, '">', qu_id[i], '</varequal>', sep = '')
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
        paste('<varequal resp_ident="', resp_id, '" case="',
          ic$case, '">', qu_id[i], '</varequal>', sep = '')
      )
    }
  }

  xml <- c(xml,
    '</or>',
    '</not>',
    '</conditionvar>',
    paste('<setvar varname="', ic$varname, '" action="', ic$action, '">',
      if(is.null(x$points)) 1 else x$points, '</setvar>', sep = ''),
    paste('<displayfeedback feedbacktype="', ic$feedbacktype,
      '" linkrefid="Mastery"/>', sep = ''),
    '</respcondition>')

  ## actions for wrong selected answers
  xml <- c(xml,
    paste('<respcondition title="Fail" continue="', ic$continue, '">', sep = ''),
    '<conditionvar>',
    '<or>'
  )

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
      paste('<respcondition title="_olat_resp_feedback" continue="', ic$continue, '">', sep = ''),
      '<conditionvar>',
      paste('<varequal resp_ident="', resp_id, '" case="', ic$case, '">', qu_id[i],
        '</varequal>', sep = ''),
      '</conditionvar>',
      paste('<displayfeedback feedbacktype="', ic$feedbacktype,
        '" linkrefid="', qu_id[i], '"/>', sep = ''),
      '</respcondition>'
    )
  }

  xml <- c(xml,
    '<respcondition title="Fail" continue="Yes">',
    '<conditionvar>',
    '<other/>',
    '</conditionvar>',
    '<setvar varname="SCORE" action="Set">0</setvar>',
    '<displayfeedback feedbacktype="Response" linkrefid="Fail"/>',
    '<displayfeedback feedbacktype="Solution" linkrefid="Solution"/>',
    '<displayfeedback feedbacktype="Hint" linkrefid="Hint"/>',
    '</respcondition>',
    '</resprocessing>')

  ## hints
  if(!is.null(x$hints)) {
    xml <- c(xml,
      '<itemfeedback ident="Hint" view="All">',
      paste('<hint feedbackstyle="', ic$feedbackstyle, '">', sep = ''),
      '<hintmaterial>',
      '<material>',
      '<mattext><![CDATA[',
      x$hints,
      ']]></mattext>',
      '</material>',
      '</hintmaterial>',
      '</hint>',
      '</itemfeedback>'
    )
  }

  ## solution
  if(!is.null(x$solution)) {
    xml <- c(xml,
      '<itemfeedback ident="Solution" view="All">',
      '<solution>',
      '<solutionmaterial>',
      '<material>',
      '<mattext texttype="text/html"><![CDATA[',
      x$question,
      x$solution,
      ']]></mattext>',
      '</material>',
      '</solutionmaterial>',
      '</solution>',
      '</itemfeedback>'
    )
  }

  ## feedback if selected answer is wrong
  if(!is.null(x$feedback)) { 
    xml <- c(xml,
      '<itemfeedback ident="Fail" view="All">',
      '<material>',
      '<mattext texttype="text/html"><![CDATA[',
      x$feedback,
      ']]></mattext>',
      '</material>',
      '</itemfeedback>'
    )
  }

  xml <- c(xml, "</item>")

  ## copy images to dir if !base64
  if(!is.null(base64) && !base64) {
    if(!file.exists(media_dir <- file.path(dir, "media")))
      dir.create(media_dir)
    if(!is.null(x$supplements)) {
      for(i in seq_along(basename(x$supplements))) {
        if(any(grepl(f <- basename(x$supplements[i]), xml))) {
          nn <- paste("pic", resp_id, f, sep = "-")
          file.copy(x$supplements[i], file.path(media_dir, nn))
          xml <- gsub(f, paste("media", nn, sep = "/"), xml)
        }
      }
    }
  }

  xml
}


## numeric converter function
write.imsqti.item.num <- function(x, dir, base64 = NULL, ...)
{
  NULL
}


## function to nicely format the XML file
xml_indent <- function(x)
{
  d <- 2 * (-1)
  tsep <- ""
  for(i in 1:length(x)) {
    if(nchar(x[i]) > 1) {
      tag <- paste(strsplit(x[i], "")[[1]][1:2], sep = "", collapse = "")
      if(grepl("<", tag, fixed = TRUE) && (tag != "<?" && tag != "<!" && tag != "</"))
        d <- d + 2
      tsep <- if(d < 1) "" else paste(rep(" ", d), sep = "", collapse = "")
      x[i] <- paste(tsep, x[i], sep = "", collapse = "")
      if(grepl("</", x[i], fixed = TRUE) || grepl("/>", x[i], fixed = TRUE))
        d <- d - 2
    }
  }
  x
}


## function to set several controlling arguments of an item
## control parameters of one xml item in OLAT
item.control <- function(title = NULL, stime = NULL, maxattempts = 1, feedbackswitch = "No",
  hintswitch = "No", solutionswitch = "Yes", width = 500, rcardinality = "Multiple", rtiming = "No",
  shuffle = "Yes", minnumber = NULL, maxnumber = NULL, rshuffle = "Yes", varname = "SCORE",
  vartype = "Decimal", defaultval = 0, minvalue = 0, maxvalue = 0, cutvalue = 0,
  respcondtitle = c("Mastery", "Fail"), continue = "Yes", case = "Yes", action = "Set",
  feedbacktype = "Response", feedbackstyle = "Incremental", ...)
{
  if(is.null(stime)) {
    stime <- gsub(" ", "", Sys.time())
    stime <- gsub(":", "", stime)
  }
  if(is.null(title))
    title <- "Question"
  title <- file_path_sans_ext(title)
  rval <- list(
    "title" = title,
    "stime" = stime,
    "maxattempts" = maxattempts,
    "feedbackswitch" = feedbackswitch,
    "hintswitch" = hintswitch,
    "solutionswitch" = solutionswitch,
    "width" = width,
    "rcardinality" = rcardinality,
    "rtiming" = rtiming,
    "shuffle" = if(is.logical(shuffle)) {
      if(shuffle) "Yes" else "No"
    } else shuffle,
    "minnumber" = minnumber,
    "maxnumber" = maxnumber,
    "rshuffle" = if(is.logical(rshuffle)) {
      if(rshuffle) "Yes" else "No"
    } else rshuffle,
    "varname" = varname,
    "vartype" = vartype,
    "defaultval" = defaultval,
    "minvalue" = minvalue,
    "maxvalue" = maxvalue,
    "cutvalue" = cutvalue,
    "respcondtitle" = respcondtitle,
    "continue" = continue,
    "case" = case,
    "action" = action,
    "feedbacktype" = feedbacktype,
    "feedbackstyle" = feedbackstyle 
  )
  rval
}


## function to delete arguments when applied with do.call()
delete.args <- function(fun = NULL, args = NULL, not = NULL)
{
  nf <- names(formals(fun))
  na <- names(args)
  for(elmt in na)
    if(!elmt %in% nf) {
      if(!is.null(not)) {
        if(!elmt %in% not)
          args[elmt] <- NULL
      } else args[elmt] <- NULL
    }

  return(args)
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


## checks for tags
check_tags <- function(tags, xml, type)
{
  mtags <- NULL
  for(i in tags) {
    if(!any(grepl(i, xml, fixed = TRUE)))
      mtags <- c(mtags, i)
  }
  if(!is.null(mtags)) {
    stop(paste("The following tags are missing in the '", type, "' xml template: ",
      paste(mtags, collapse = ", ", sep = ""), "!", sep = ""))
  }
  invisible(NULL)
}
