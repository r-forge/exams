## version based on make_exams_write_pdf(),
## first generates a full .tex file, then,
## the converter ex2html() is applied to generate
## the final .html file
exams2html <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  template = "plain", inputs = NULL, header = list(Date = Sys.Date()),
  name = NULL, control = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  mathjax = FALSE, converter = "ttx", show = NULL, ...)
{
  ## if dir = NULL, the function will create a tempfile()
  ## and show the .html file in the default browser
  ## using function show.html()
  show <- if(is.null(show)) FALSE else show
  if(is.null(dir)) {
    dir <- tempfile()
    show <- TRUE
  }

  ## this is parsed to function make_exams_write_pdf(), to generate
  ## the final .html file
  options("ex2html" = make_exams_write_tex2html(converter = converter,
    mathjax = mathjax, show = show, ...))

  pdfwrite <- make_exams_write_pdf(template = template, inputs = inputs,
    header = header, name = name, quiet = quiet, control = control)

  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL, transform = NULL, write = pdfwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}


## writer function for .html conversion of one single exam
## based on a full .tex file
make_exams_write_tex2html <- function(converter = "ttx", mathjax = FALSE, show = TRUE, ...)
{
  args <- list(...)
  function(tex, dir)
  {
    bsname <- file_path_sans_ext(basename(tex))
    hdir <- file.path(dir, bsname)
    dir.create(hdir)
    owd <- getwd()
    setwd(hdir)
    on.exit(setwd(owd))
    cfiles <- list.files(owd)
    file.copy(file.path(owd, cfiles), file.path(hdir, cfiles))
    args$body <- FALSE
    args$x <- file.path(hdir, tex)
    args$tdir <- hdir
    html <- do.call(converter, args)
    if(mathjax) {
      if(length(i <- grep("</head>", html))) {
        html <- c(
          html[1:(i - 1)],
          '<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>',
          html[i:length(html)]
        )
      }
    }
    for(cf in cfiles) {
      if(file.exists(cf <- file.path(hdir, cf)))
        file.remove(cf)
    }
    htmlfile <- paste(bsname, "html", sep = ".")
    writeLines(html, htmlfile)
    if(!is.null(imgs <- attr(html, "images"))) {
      for(i in imgs)
        file.copy(i, file.path(hdir, basename(i)))
    }
    if(show) show.html(htmlfile)
  }
}


## show .html code in browser
show.html <- function(x)
{
  if(length(x) == 1L && file.exists(x[1L])) {
    tempf <- dirname(x)
    fname <- basename(x)
  } else {
    dir.create(tempf <- tempfile())
    fname <- "show.html"
    writeLines(x, file.path(tempf, fname))
    if(!is.null(imgs <- attr(x, "images"))) {
      for(i in imgs)
        file.copy(i, file.path(tempf, basename(i)))
    }
  }
  system(paste(shQuote(getOption("browser")),
    shQuote(file.path(tempf, fname))), wait = FALSE)
  invisible(NULL)
}


## version for more general .xml or .html file generation
## the idea is to convert each question and then apply
## a selfmade document generator
exams2x <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  type = "html", converter = "ttx", base64 = TRUE, width = 550,
  body = TRUE, solution = TRUE, doctype = NULL, head = NULL, ...)
{
  wasNULL <- FALSE
  if(is.null(dir)) {
    dir <- tempfile()
    wasNULL <- TRUE
  }

  htmltransform <- make_exercise_transform_html(converter = converter,
    base64 = base64, body = body, width = width, ...)

  args <- list(...)
  args$dir <- dir
  args$doctype <- doctype
  args$head <- head
  args$solution <- solution
  args$name <- name
  args$wasNULL <- wasNULL
  writer <- paste("make_exams_write", type, sep = "_")

  htmlwrite <- if(type == "olat" && n < 2) {
    do.call(writer, args)
  } else {
    if(type == "olat")
      NULL
    else
      do.call(writer, args)
  }

  exm <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL,
    transform = htmltransform, write = htmlwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  if(type == "olat" && n > 1) {
    fun <- do.call("make_exams_write_olat", args)
    fun(exm, dir, list(id = 1, n = n))
  }

  invisible(exm)
}


## writes the final html site
make_exams_write_html <- function(dir, doctype = NULL,
  head = NULL, solution = TRUE, name = NULL, mathjax = FALSE, ...)
{
  function(x, dir, info)
  {
    tdir <- tempfile()
    sdir <- NULL
    dir.create(tdir)
    on.exit(unlink(tdir))
    if(is.null(doctype)) {
      doctype <- c(
        '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"',
        '"http://www.w3.org/TR/html4/strict.dtd">'
      )
    }
    if(is.null(head)) {
      head <- c(
        '<head>',
        paste('<title> ', 'exam', info$id, ' </title>', sep = ''),
        '<style type="text/css">',
        'body{font-family:Arial;}',
        '</style>',
        if(mathjax) {
          c('<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">',
          '</script>')
        } else {
          NULL
        },
        '</head>'
      )
    }
    html <- c(doctype, "<html>", head, "<body>", paste('<h2>', 'Exam', info$id, ' </h2>'), "<ol>")
    for(ex in x) {
      html <- c(html, "<li>", "<h4>", "Question", "</h4>", ex$question, "<br/>")
      if(length(ex$questionlist)) {
        html <- c(html, '<ol type="a">')
        for(i in ex$questionlist)
          html <- c(html, "<li>", i, "</li>")
        html <- c(html, "</ol>", "<br/>")
      }
      if(solution) {
        html <- c(html, "<h4>", "Solution", "</h4>")
        if(length(ex$solutionlist)) {
          html <- c(html, '<ol type="a">')
          for(i in ex$solutionlist)
            html <- c(html, "<li>", i, "</li>")
          html <- c(html, "</ol>", "<br/>")
        }
        if(length(ex$solution)) {
          html <- c(html, ex$solution, "<br/>")
        }
      }
      html <- c(html, "</li>")
      if(length(ex$supplements)) {
        for(i in ex$supplements) {
          if(any(grepl(basename(i), html)))
            file.copy(i, file.path(tdir, basename(i)))
        }
      }
      sdir <- c(sdir, attr(ex$supplements, "dir"))
    }
    html <- c(html, "</ol>", "</body>", "</html>")
    if(length(sdir))
      for(i in sdir) gsub(i, "", html, fixed = TRUE)
    if(is.null(name))
      name <- "exam"
    writeLines(html, file.path(tdir, paste(name, info$id, ".html", sep = "")))
    out_dir <- file.path(dir, paste(name, info$id, sep = ""))
    dir.create(out_dir)
    file.copy(file.path(tdir, list.files(tdir)), file.path(out_dir, list.files(tdir)))
    args <- list(...)
    if(!is.null(args$wasNULL) && args$wasNULL)
      show.html(file.path(out_dir, paste(name, info$id, ".html", sep = "")))
    invisible(NULL)
  }
}


## a writer function for OLAT .xml test files
## currently the supported mode is only multiple choice
make_exams_write_olat <- function(dir, doctype = NULL,
  head = NULL, solution = TRUE, name = NULL, mathjax = FALSE, ...)
{
  if(is.null(name))
    name <- paste("OlatExam", Sys.Date(), sep = "-")
  args <- list(...)

  function(exm, dir, info = NULL)
  {
    ## generate a temporary dir
    tdir <- tempfile()
    sdir <- NULL
    dir.create(tdir)
    on.exit(unlink(tdir))

    ## generate the exam ids and title
    imsid <- olatid(14L)
    examid <- secid <- imsid
    title <- name

    ## create the .xml directory all files are written to
    xmldir <- file.path(dir, name)
    dir.create(xmldir)

    ## start the master .xml file
    xml <- c('<?xml version="1.0" encoding="UTF-8"?>',
      '<!DOCTYPE questestinterop SYSTEM "ims_qtiasiv1p2p1.dtd">',
      '',
      '<questestinterop>',
      paste('<assessment ident="uibkolat_23_', examid, '" title="', title, '">', sep = ''),
      '<qtimetadata>',
      '<qtimetadatafield>',
      '<fieldlabel>qmd_assessmenttype</fieldlabel>',
      '<fieldentry>Assessment</fieldentry>',
      '</qtimetadatafield>',
      '</qtimetadata>',
      paste('<assessmentcontrol feedbackswitch="',
        if(is.null(args$feedbackswitch)) 'Yes' else args$feedbackswitch, '" hintswitch="',
        if(is.null(args$hintswitch)) 'Yes' else args$hintswitch, '" solutionswitch="',
        if(is.null(args$solutionswitch)) 'Yes' else args$solutionswitch, '"/>', sep = ''),
      paste('<outcomes_processing scoremodel="',
        if(is.null(args$scoremodel)) 'SumOfScores' else args$scoremodel, '">', sep = ''),
      '<outcomes>',
      paste('<decvar varname="SCORE" vartype="Decimal" cutvalue="',
        if(is.null(args$cutvalue)) 1 else args$cutvalue, '"/>', sep = ''),
      '</outcomes>',
      '</outcomes_processing>'
    )

    ## cycle through all exams and questions
    ## need to collect the number of questions
    if(all(c("question", "metainfo", "supplements") %in% names(exm[[1]]))) {
      nq <- length(exm)
      exm <- list(exm)
    } else nq <- length(exm[[1]])

    args$sectitle <- rep(args$sectitle, length.out = nq)
    args$number <- if(is.null(args$number)) {
      rep(1, nq)
    } else rep(args$number, length.out = nq)
    args$order_type <- rep(args$order_type, length.out = nq)

    for(j in 1:nq) {
      xml <- c(xml,
        paste('<section ident="uibkolat_23_', (secid <- secid + 1), '" title="',
          if(is.null(args$sectitle[j])) paste("Section", j) else args$sectitle[j], '">', sep = ''),
        '<selection_ordering>',
        '<selection>',
        paste('<selection_number>', args$number[j], '</selection_number>', sep = ''),
        '</selection>',
        paste('<order order_type="',
        if(is.null(args$order_type[j])) 'Random' else args$order_type[j], '"/>', sep = ''),
        '</selection_ordering>'
      )
      for(i in seq_along(exm)) {
        xml <- c(xml, make_exercise_write_olat(exm[[i]][[j]]))
      }
      xml <- c(xml, "</section>")
    }

    ## complete the .xml file
    xml <- c(xml,
      "</assessment>",
      "</questestinterop>"
    )
    
    ## write to .xml
    writeLines(xml, file.path(xmldir, "qti.xml"))

    ## compress
    owd <- getwd()
    setwd(xmldir)
    zip(zipfile = paste(name, "zip", sep = "."), files = list.files(xmldir))
    setwd(owd)
  }
}


## olat id generating helper function
olatid <- function(x) as.numeric(paste(sample(1:9, x, replace = TRUE), collapse = ""))


## write a single exercise in olat .xml format
make_exercise_write_olat <- function(x)
{
  if(is.null(x$metainfo$type))
    stop("no exercise type specified, cannot process OLAT exam generation!")
  class(x) <- c(paste("exercise", x$metainfo$type, sep = "."), "list")
  write.olat(x)
}


## generic exercise writer function for olat questions
write.olat <- function(x) 
{
  UseMethod("write.olat")
}


## function to write multiple choice questions
write.olat.exercise.mchoice <- function(x)
{
  ## generate an unique id
  itemid <- paste("QTIEDIT:MCQ", olatid(11L), sep = ":")
  respid <- olatid(11L)
  quid <- NULL
  for(i in x$questionlist) quid <- c(quid, olatid(11L))

  ## obtain controling parameters
  ic <- do.call("olatitem.control", delete.args(olatitem.control, x$metainfo))

  ## write the question
  xml <- c(
    paste('<item ident="', itemid, '" title="', ic$title,
      '" maxattempts="', ic$maxattempts,'">', sep = ''),
    # "<objectives>",
    # "<material>",
    # paste("<mattext><![CDATA[", exinfo, "]]></mattext>", sep = ""),
    # "</material>",
    # "</objectives>",
    paste('<itemcontrol feedbackswitch="', ic$feedbackswitch, '" hintswitch="',
      ic$hintswitch, '" solutionswitch="', ic$solutionswitch, '"/>', sep = ''),
    '<presentation>',
    '<material>',
    '<mattext texttype="text/html"><![CDATA[',
    x$question,
    ']]></mattext>',
    '</material>',
    paste('<response_lid ident="', respid, '" rcardinality="',
      ic$rcardinality, '" rtiming="', ic$rtiming, '">', sep = ''),
    paste('<render_choice shuffle="', ic$shuffle, '" minnumber="0" maxnumber="',
      length(x$solutionlist), '">', sep = '')
  )

  ## cycling through all answers
  for(i in seq_along(x$questionlist)) {
    xml <- c(xml,
      '<flow_label class="List">',
      paste('<response_label ident="', quid[i], '" rshuffle="', ic$rshuffle, '">', sep = ''),
      '<material>',
      '<mattext texttype="text/html"><![CDATA[',
      x$questionlist[i],
      ']]></mattext>',
      '</material>',
      '</response_label>',
      '</flow_label>'
    )
  }

  ## more controling of the item
  xml <- c(xml,
    '</render_choice>',
    '</response_lid>',
    '</presentation>',
    '<resprocessing>',
    '<outcomes>',
    paste('<decvar varname="', ic$varname, '" vartype="', ic$vartype,
      '" defaultval="', ic$defaultval, '" minvalue="', ic$minvalue,
      '" maxvalue="', ic$maxvalue, '" cutvalue="', ic$cutvalue, '"/>', sep = ''),
    '</outcomes>',
    paste('<respcondition title="', 'Mastery', '" continue="',
      ic$continue, '">', sep = ''),
    '<conditionvar>',
    '<and>'
  )

  ## point to the correct answer
  for(i in seq_along(x$metainfo$solution)) {
    if(x$metainfo$solution[i]) {
      xml <- c(xml,
        paste('<varequal respident="', respid, '" case="',
          ic$case, '">', quid[i], '</varequal>', sep = '')
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
        paste('<varequal respident="', respid, '" case="',
          ic$case, '">', quid[i], '</varequal>', sep = '')
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
    '</respcondition>', 
    paste('<respcondition title="Fail" continue="', ic$continue, '">', sep = ''),
    '<conditionvar>',
    '<or>'
  )

#  for(i in seq_along(x$metainfo$solution)) {
#    if(!x$metainfo$solution[i]) {
#      xml <- c(xml,
#        paste('<varequal respident="', respid, '" case="',
#          ic$case, '">', quid[i], '</varequal>', sep = '')
#      )
#    }
#  }

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
      paste('<varequal respident="', respid, '" case="', ic$case, '">', quid[i],
        '</varequal>', sep = ''),
      '</conditionvar>',
      paste('<displayfeedback feedbacktype="', ic$feedbacktype,
        '" linkrefid="', quid[i], '"/>', sep = ''),
      '</respcondition>'
    )
  }

  ## hints
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
    '</resprocessing>',
    '<itemfeedback ident="Hint" view="All">',
    paste('<hint feedbackstyle="', ic$feedbackstyle, '">', sep = ''),
    '<hintmaterial>',
    '<material>',
    '<mattext><![CDATA[]]></mattext>',
    '</material>',
    '</hintmaterial>',
    '</hint>',
    '</itemfeedback>'
  )

  ## solution
  if(!is.null(x$solution)) {
    xml <- c(xml,
      '<itemfeedback ident="Solution" view="All">',
      '<solution>',
      '<solutionmaterial>',
      '<material>',
      '<mattext texttype="text/html"><![CDATA[<p><br /><br /><b>Aufgabe</b><br />',
      x$question,
      '<br /><br /><b>L&#246sung</b><br />',
      x$solution,
      '</p>]]></mattext>',
      '</material>',
      '</solutionmaterial>',
      '</solution>',
      '</itemfeedback>'
    )

    ## feedback if selected answer is wrong
    xml <- c(xml,
      '<itemfeedback ident="Fail" view="All">',
      '<material>',
      '<mattext texttype="text/html"><![CDATA[<p><br /><br /><b>Aufgabe</b><br />',
      x$question,
      '<br /><br /><b>L&#246sung</b><br />',
      x$solution,
      '</p>]]></mattext>',
      '</material>',
      '</itemfeedback>'
    )
  }

  xml <- c(xml, "</item>")

  xml
}


## not implemented yet
write.olat.exercise.num <- function(x) NULL


## control parameters of one xml item in OLAT
olatitem.control <- function(title = NULL, stime = NULL, maxattempts = 1, feedbackswitch = "No",
  hintswitch = "No", solutionswitch = "Yes", width = 500, rcardinality = "Multiple", rtiming = "No",
  shuffle = "Yes", rshuffle = "Yes", varname = "SCORE", vartype = "Decimal", defaultval = 0,
  minvalue = 0, maxvalue = 1, cutvalue = 0, respcondtitle = c("Mastery", "Fail"), continue = "Yes",
  case = "Yes", action = "Set", feedbacktype = "Response", feedbackstyle = "Incremental", ...)
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
