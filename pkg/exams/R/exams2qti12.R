## create IMS QTI 1.2 .xml files
## specifications and examples available at:
## http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bindv1p2.html
## http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bestv1p2.html#1466669
## FIXME: maxattempts="3" in <item> template?
exams2qti12 <- function(file, n = 1L, nsamp = NULL, dir,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  resolution = 100, width = 4, height = 4,
  num = NULL, mchoice = NULL, schoice = mchoice, cloze = NULL,
  template = NULL, ...)
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

  ## start .xml assessement creation
  ## get the possible item body functions and options  
  itembody = list(num = num, mchoice = mchoice, schoice = schoice, cloze = cloze)

  for(i in c("num", "mchoice", "schoice", "cloze")) {
    if(is.null(itembody[[i]])) itembody[[i]] <- list()
    if(is.list(itembody[[i]])) itembody[[i]] <- do.call(
      paste("make_itembody_", i, "_qti12", sep = ""), itembody[[i]])
  }

  ## create a temporary directory
  dir <- path.expand(dir)
  if(is.null(tdir)) {
    dir.create(tdir <- tempfile())
    on.exit(unlink(tdir))
  } else tdir <- path.expand(tdir)
  if(!file.exists(tdir))
    dir.create(tdir)

  ## the package directory
  pkg_dir <- .find.package("exams")

  ## get the .xml template
  template <- if(is.null(template)) {
    file.path(.find.package("exams"), "xml", "imsqti12.xml")
  } else path.expand(template)
  template <- ifelse(
    tolower(substr(template, nchar(template) - 3L, nchar(template))) != ".xml",
    paste(template, ".xml", sep = ""), template)
  template <- ifelse(file.exists(template),
    template, file.path(pkg_dir, "xml", basename(template)))
  if(!all(file.exists(template))) {
    stop(paste("The following files cannot be found: ",
      paste(template[!file.exists(template)], collapse = ", "), ".", sep = ""))
  }
  xml <- readLines(template[1])

  ## check template for section and item inclusion
  ## extract the template for the assessement, sections and items
  if(length(section_start <- grep("<section ident", xml, fixed = TRUE)) != 1 ||
    length(section_end <- grep("</section>", xml, fixed = TRUE)) != 1) {
    stop(paste("The .xml template", template,
      "must contain of exactly one opening and closing section tag!"))
  }
  section <- xml[section_start:section_end]
  if(length(item_start <- grep("<item ident", section, fixed = TRUE)) != 1 ||
    length(item_end <- grep("</item>", section, fixed = TRUE)) != 1) {
    stop(paste("The .xml template", template,
      "must contain of exactly one opening and closing item tag!"))
  }
  xml <- c(xml[1:(section_start - 1)], "##TestSections", xml[(section_end + 1):length(xml)])
  item <- section[item_start:item_end]
  section <- section[1:(item_start - 1)]

  ## obtain the number of exams and questions
  nx <- length(exm)
  nq <- length(exm[[1L]])

  ## generate the test id
  test_id <- make_id(9)

  ## create section ids
  sec_ids <- paste(paste("Sec", 1:nq, sep = ""), make_id(10, nq), sep = "_")

  ## create a name
  name <- if(is.null(name)) {
    paste("Rexams", test_id, sep = "_")
  } else name

  ## create the directory where the test is stored
  dir.create(test_dir <- file.path(tdir, name))

  ## cycle through all exams and questions
  ## similar questions are combined in a section,
  ## questions are then sampled from the sections
  items <- points <- sec_xml <- NULL
  for(j in 1:nq) {
    ## first, create the section header
    sec_xml <- c(sec_xml, gsub("##SectionId", sec_ids[j], section, fixed = TRUE))

    ## insert a section title -> exm[[1]][[j]]$metainfo$name?
    sec_xml <- gsub("##SectionTitle", "Question", sec_xml, fixed = TRUE)

    ## now, insert the questions
    for(i in 1:nx) {
      ## the question name
      qu_name <- exm[[i]][[j]]$metainfo$name

      ## get and insert the item body
      type <- exm[[i]][[j]]$metainfo$type
      ibody <- gsub("##ItemBody",
        paste(thebody <- itembody[[type]](exm[[i]][[j]]), collapse = "\n"),
        item, fixed = TRUE)

      ## insert possible solution
      enumerate <- attr(thebody, "enumerate")
      if(is.null(enumerate)) enumerate <- FALSE
      xsolution <- exm[[i]][[j]]$solution
      if(length(nsol <- length(exm[[i]][[j]]$solutionlist))) {
        xsolution <- c(xsolution, "<br/>")
        if(enumerate) xsolution <- c(xsolution, '<ol type = "a">')
        xsolution <- c(xsolution, paste(if(enumerate) rep('<li>', nsol) else NULL,
          exm[[i]][[j]]$questionlist, if(length(exm[[i]][[j]]$solutionlist)) "</br>" else NULL,
          exm[[i]][[j]]$solutionlist, if(enumerate) rep('</li>', nsol) else NULL))
        if(enumerate) xsolution <- c(xsolution, '</ol>')
      }
      ibody <- gsub("##ItemSolution", paste(xsolution, collapse = "\n"), ibody, fixed = TRUE)

      ## insert an item id
      ibody <- gsub("##ItemId", iname <- paste("QTIEDIT", attr(thebody, "type"),
        paste("Rexams", make_id(10), sep = "_"), sep = ":"), ibody)

      ## insert an item title
      ibody <- gsub("##ItemTitle", qu_name, ibody, fixed = TRUE)

      ## include bod in section
      sec_xml <- c(sec_xml, ibody, "")

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
          if(any(grepl(f, sec_xml))) {
            sec_xml <- gsub(f, paste("media", sup_dir, f, sep = "/"), sec_xml, fixed = TRUE)
          }
        }
      }
    }

    ## close the section
    sec_xml <- c(sec_xml, "", "</section>")
  }

  ## finalize the test xml file, insert id, name, duration and sections
  xml <- gsub("##TestIdent", name, xml)
  xml <- gsub("##TestTitle", name, xml)
  xml <- gsub("##TestDuration", "", xml)  ## FIXME: duration in <duration>P0Y0M0DT0H1M35S</duration>
  xml <- gsub("##TestSections", paste(sec_xml, collapse = "\n"), xml)

  ## write to dir
  writeLines(xml, file.path(test_dir, "qti.xml"))

  ## compress
  owd <- getwd()
  setwd(test_dir)
  zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
  setwd(owd)

  ## copy the final .zip file
  file.copy(file.path(test_dir, zipname), file.path(dir, zipname))

  invisible(exm)
}


## multiple/single choice item writer function
make_itembody_mchoice_qti12 <- make_itembody_schoice_qti12 <- function(rtiming = NULL, shuffle = FALSE,
  minnumber = NULL, maxnumber = NULL, rshuffle = shuffle, defaultval = NULL, minvalue = NULL,
  maxvalue = NULL, cutvalue = NULL, enumerate = TRUE)
{
  function(x) {
    ## generate ids
    resp_id <- paste("RESPONSE", make_id(7), sep = "_")
    qu_id <- paste("choice", make_id(10, n = length(x$questionlist)), sep = "_")

    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    ## insert the question
    xml <- c(
      '<presentation>',
      '<material>',
      '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
      x$question,
      ']]></mattext>',
      '</material>'
    )

    ## some more question control
    xml <- c(xml,
      paste('<response_lid ident="', resp_id, '" rcardinality="',
        if(x$metainfo$type == "mchoice") "Multiple" else "Single", '" rtiming="',
        if(is.null(rtiming)) 'No' else rtiming, '">', sep = ''),
      paste('<render_choice shuffle=', if(shuffle) '"Yes"' else '"No"',
        ' minnumber="', if(is.null(minnumber)) 0 else minnumber, '" maxnumber="',
        if(is.null(maxnumber)) length(x$solutionlist) else maxnumber, '">', sep = '')
    )

    ## cycling through all answers
    enumletters <- if(enumerate) paste(letters[1:length(x$questionlist)], ".", sep = "") else NULL
    for(i in seq_along(x$questionlist)) {
      xml <- c(xml,
        '<flow_label class="List">',
        paste('<response_label ident="', qu_id[i], '" rshuffle="', if(rshuffle) 'Yes' else 'No',
          '">', sep = ''),
        '<material>',
        '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
        paste(enumletters[i], x$questionlist[i]),
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
      paste('<decvar varname="SCORE" vartype="Decimal" defaultval="',
        if(is.null(defaultval)) 0 else defaultval, '" minvalue="',
        if(is.null(minvalue)) 0 else minvalue, '" maxvalue="',
        if(is.null(maxvalue)) points else maxvalue, '" cutvalue="',
        if(is.null(cutvalue)) points else cutvalue, '"/>', sep = ''),
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
        if(is.null(x$metainfo$points)) 1 else x$metainfo$points, '</setvar>', sep = ''),
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
      '</resprocessing>'
    )
    attr(xml, "enumerate") <- enumerate
    attr(xml, "type") <- if(x$metainfo$type == "mchoice") "MCQ" else "SCQ"

    xml
  }
}


## numeric item body writer function
make_itembody_num_qti12 <- function(defaultval = NULL, minvalue = NULL, maxvalue = NULL,
  cutvalue = NULL)
{
  function(x) {
    ## generate an unique id
    resp_id <- paste("RESPONSE", make_id(7), sep = "_")

    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    ## the correct solution as text
    soltext <- paste(gsub(" ", "", as.character(x$metainfo$solution), fixed = TRUE), collapse = "-")

    ## start general question setup
    xml <- c(
      '<presentation>',
      '<flow>',
      '<material>',
      '<matbreak/>',
      '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
      x$question,
      ']]></mattext>',
      '<matbreak/>',
      '</material>',
      paste('<response_num ident="', resp_id,
        '" rcardinality="Single" rtiming="No" numtype="Decimal">', sep = ''),
      paste('<render_fib fibtype="Decimal" prompt="Box" maxchars="', nchar(soltext), '">', sep = ""),
      '<response_label ident="A"/>',
      '</render_fib>',
      '</response_num>',
      '</flow>',
      '</presentation>',
      '<resprocessing>',
      '<outcomes>',
      paste('<decvar varname="REALSCORE" vartype="Integer" defaultval="',
        if(is.null(defaultval)) 0 else defaultval, '"/>', sep = ''),
      '</outcomes>',
      '<respcondition title="Mastery" continue="Yes">',
      '<conditionvar>',
      paste('<vargte respident="', resp_id, '">', x$metainfo$solution + max(x$metainfo$tolerance),
        '</vargte>', sep = ""),
      paste('<vargte respident="', resp_id, '">', x$metainfo$solution - max(x$metainfo$tolerance),
        '</vargte>', sep = ""),
      '</conditionvar>',
      paste('<setvar varname="SCORE" action="Set">', points, '</setvar>', sep = ""),
      '<displayfeedback feedbacktype="Response" linkrefid="Mastery"/>',
      '</respcondition>'
    )

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
      '</resprocessing>'
    )
    attr(xml, "type") <- "NUM"

    xml
  }
}


## special num type function using a string answer
make_itembody_num_olat <- function(defaultval = NULL, minvalue = NULL, maxvalue = NULL,
  cutvalue = NULL, digits = 2)
{
  function(x) {
    ## generate an unique id
    resp_id <- paste("RESPONSE", make_id(7), sep = "_")

    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    ## the correct solution as text
    soltext <- format(round(x$metainfo$solution, digits = digits), nsmall = digits)

    ## start general question setup
    xml <- c(
      '<presentation>',
      '<flow>',
      '<material>',
      '<matbreak/>',
      '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
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
      paste('<decvar varname="SCORE" vartype="Decimal" defaultval="',
        if(is.null(defaultval)) 0 else defaultval, '" minvalue="',
        if(is.null(minvalue)) 0 else minvalue, '" maxvalue="',
        if(is.null(maxvalue)) points else maxvalue, '" cutvalue="',
        if(is.null(cutvalue)) points else cutvalue, '"/>', sep = ''),
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
      '</resprocessing>'
    )
    attr(xml, "type") <- "FIB"

    xml
  }
}


## cloze question item body
make_itembody_cloze_olat <- function(defaultval = NULL, minvalue = NULL, maxvalue = NULL,
  cutvalue = NULL, lang = "en", digits = 2, enumerate = TRUE)
{
  function(x) {
    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    yn <- switch(lang,
      "en" = "(yes = 1, no = 2)",
      "de" = "(ja = 1, nein = 2)",
      "fr" = "(oui = 1, no = 2)",
      "es" = "(si = 1, no = 2)"
    )

    ## the correct solution as text
    soltext <- list()
    for(j in seq_along(x$metainfo$solution)) {
      field <- NULL
      qtext <- if(length(x$questionlist)) x$questionlist[j] else NULL
      if(length(grep("choice", x$metainfo$clozetype[j]))) {
        qtext <- paste(qtext, yn)
        field <- if(x$metainfo$solution[[j]][1]) "1" else "2"
      }
      if(length(grep("string", x$metainfo$clozetype[j])))
        field <- as.character(x$metainfo$solution[[j]][1])
      if(length(grep("num", x$metainfo$clozetype[j])))
        field <- format(round(x$metainfo$solution[[j]][1], digits = digits), nsmall = digits)
      if(!is.null(qtext)) qtext <- paste(c(qtext, "</br>"), collapse = "\n")
      soltext[[j]] <- list("text" = qtext, "field" = field)
    }

    ## generate an unique id
    resp_id <- paste("RESPONSE", make_id(7, n <- length(soltext)), sep = "_")

    ## start general question setup
    xml <- c(
      '<presentation>',
      '<flow>',
      '<material>',
      '<matbreak/>',
      '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
      x$question,
      ']]></mattext>',
      '<matbreak/>',
      '</material>')
  
    enumletters <- if(enumerate) paste(letters[1:n], ". ", sep = "") else NULL
    for(i in 1:n) {
      xml <- c(xml,
        '<material>',
        paste('<mattext><![CDATA[', enumletters[i], soltext[[i]]$text, ']]></mattext>', sep = ""),
        '</material>',
        paste('<response_str ident="', resp_id[i], '" rcardinality="Single">', sep = ""),
        paste('<render_fib columns="', nchar(soltext[[i]]$field), '" maxchars="',
          nchar(soltext[[i]]$field), '">', sep = ""),
        '<flow_label class="Block">',
        paste('<response_label ident="', resp_id[i], '" rshuffle="No"/>', sep = ""),
        '</flow_label>',
        '</render_fib>',
        '</response_str>',
        '<matbreak/>')
    }  

    xml <- c(xml,
      '</flow>',
      '</presentation>',
      '<resprocessing>',
      '<outcomes>',
      paste('<decvar varname="SCORE" vartype="Decimal" defaultval="',
        if(is.null(defaultval)) 0 else defaultval, '" minvalue="',
        if(is.null(minvalue)) 0 else minvalue, '" maxvalue="',
        if(is.null(maxvalue)) points else maxvalue, '" cutvalue="',
        if(is.null(cutvalue)) points else cutvalue, '"/>', sep = ''),
      '</outcomes>',
      '<respcondition title="Mastery" continue="Yes">',
      '<conditionvar>',
      '<and>')

    for(i in 1:n) {
      xml <- c(xml,
        '<or>',
        paste('<varequal respident="', resp_id[i],
          '" case="No"><![CDATA[', soltext[[i]]$field, ']]></varequal>', sep = ""),
        '</or>')
    }

    xml <- c(xml,
      '</and>',
      '</conditionvar>',
      '<setvar varname="SCORE" action="Set">1.0</setvar>',
      '<displayfeedback feedbacktype="Response" linkrefid="Mastery"/>',
      '</respcondition>'
    )

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
      '</resprocessing>'
    )
    attr(xml, "type") <- "FIB"
    attr(xml, "enumerate") <- enumerate

    xml
  }
}

## FIXME: No support for question of style "string" and/or "cloze" in IMS QTI?

## function to create identfier ids
## README: speedup by avoiding for() loop and allowing zeros except for first digit
make_id <- function(size, n = 1L) {
  rval <- matrix(sample(0:9, size * n, replace = TRUE), ncol = n, nrow = size)
  rval[1L, ] <- pmax(1L, rval[1L, ])
  colSums(rval * 10^((size - 1L):0L))
}


## README: commented for now
## ## other functions, not in use yet
## ## functions to input test and item controls text
## controllist <- function(...) structure(list(...), class = "controllist")
## 
## as.character.controllist <- function(x, ...)
## {
##   paste(
##     names(x),
##     " = \"",
##     sapply(x, paste, collapse = " "),
##     "\"", sep = "", collapse = " "
##   )
## }

