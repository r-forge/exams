## create IMS QTI 1.2 .xml files
## specifications and examples available at:
## http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bindv1p2.html
## http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bestv1p2.html#1466669
exams2qti12 <- function(file, n = 1L, nsamp = NULL, dir,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  resolution = 100, width = 4, height = 4,
  num = NULL, mchoice = NULL, schoice = mchoice, cloze = NULL, string = NULL,
  template = "qti12", ...)
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
  itembody = list(num = num, mchoice = mchoice, schoice = schoice, cloze = cloze, string = string)

  for(i in c("num", "mchoice", "schoice", "cloze", "string")) {
    if(is.null(itembody[[i]])) itembody[[i]] <- list()
    if(is.list(itembody[[i]])) itembody[[i]] <- do.call("make_itembody_qti12", itembody[[i]])
    if(!is.function(itembody[[i]])) stop(sprintf("wrong specification of %s", sQuote(i)))
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

  ## the package directory
  pkg_dir <- .find.package("exams")

  ## get the .xml template
  template <- path.expand(template)
  template <- ifelse(
    tolower(substr(template, nchar(template) - 3L, nchar(template))) != ".xml",
    paste(template, ".xml", sep = ""), template)
  template <- ifelse(file.exists(template),
    template, file.path(pkg_dir, "xml", basename(template)))
  if(!all(file.exists(template))) {
    stop(paste("The following files cannot be found: ",
      paste(basename(template)[!file.exists(template)], collapse = ", "), ".", sep = ""))
  }
  xml <- readLines(template[1L])

  ## check template for section and item inclusion
  ## extract the template for the assessement, sections and items
  if(length(section_start <- grep("<section ident", xml, fixed = TRUE)) != 1L ||
    length(section_end <- grep("</section>", xml, fixed = TRUE)) != 1L) {
    stop(paste("The XML template", template,
      "must contain exactly one opening and closing <section> tag!"))
  }
  section <- xml[section_start:section_end]
  if(length(item_start <- grep("<item ident", section, fixed = TRUE)) != 1 ||
    length(item_end <- grep("</item>", section, fixed = TRUE)) != 1) {
    stop(paste("The XML template", template,
      "must contain exactly one opening and closing <item> tag!"))
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
  if(is.null(name)) name <- paste(file_path_sans_ext(basename(template)), test_id, sep = "_")

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
      ibody <- gsub("##ItemId", iname <- paste(attr(thebody, "type"), make_id(10), sep = "_"), ibody)

      ## attach item id to metainfo
      exm[[i]][[j]]$metainfo$id <- iname

      ## insert an item title
      ibody <- gsub("##ItemTitle", qu_name, ibody, fixed = TRUE)

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
          if(any(grepl(f, ibody))) {
            ibody <- gsub(f, paste("media", sup_dir, f, sep = "/"), ibody, fixed = TRUE)
          }
        }
      }

      ## include body in section
      sec_xml <- c(sec_xml, ibody, "")
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


## QTI 1.2 item body constructor function
## includes item <presentation> and <resprocessing> tags
make_itembody_qti12 <- function(rtiming = FALSE, shuffle = FALSE, rshuffle = shuffle,
  minnumber = NULL, maxnumber = NULL, defaultval = NULL, minvalue = NULL,
  maxvalue = NULL, cutvalue = NULL, enumerate = TRUE, digits = 2)
{
  function(x) {
    ## how many points?
    points <- if(is.null(x$metainfo$points)) 1 else x$metainfo$points

    ## how many questions
    solution <- if(!is.list(x$metainfo$solution)) {
      list(x$metainfo$solution)
    } else x$metainfo$solution
    n <- length(solution)

    questionlist <- if(!is.list(x$questionlist)) {
      if(x$metainfo$type == "cloze") as.list(x$questionlist) else list(x$questionlist)
    } else x$questionlist
    if(length(questionlist) < 1) questionlist <- NULL

    tolerance <- if(!is.list(x$metainfo$tolerance)) {
      if(x$metainfo$type == "cloze") as.list(x$metainfo$tolerance) else list(x$metainfo$tolerance)
    } else x$questionlist
    tolerance <- rep(tolerance, length.out = n)

    ## set question type(s)
    type <- x$metainfo$type
    type <- if(type == "cloze") x$metainfo$clozetype else rep(type, length.out = n)

    ## start item presentation
    ## and insert question
    xml <- c(
      '<presentation>',
      '<flow>',
      if(!is.null(x$question)) {
        c(
          '<material>',
          '<matbreak/>',
          '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
          x$question,
          ']]></mattext>',
          '<matbreak/>',
          '</material>'
        )
      } else NULL
    )

    ## insert responses
    ids <- el <- list()
    for(i in 1:n) {
      ## generate ids
      ids[[i]] <- list("response" = paste("RESPONSE", make_id(7), sep = "_"),
        "questions" = paste(type, make_id(10, length(x$metainfo$solution)), sep = "_"))

      ## insert choice type responses
      if(length(grep("choice", type[i]))) {
        xml <- c(xml,
          paste('<response_lid ident="', ids[[i]]$response, '" rcardinality="',
            if(type[i] == "mchoice") "Multiple" else "Single", '" rtiming=',
            if(rtiming) '"Yes"' else '"No"', '>', sep = ''),
          paste('<render_choice shuffle=', if(shuffle) '"Yes"' else '"No">', sep = '')
        )
        for(j in seq_along(solution[[i]])) {
          xml <- c(xml,
            '<flow_label class="List">',
            paste('<response_label ident="', ids[[i]]$questions[j], '" rshuffle="',
              if(rshuffle) 'Yes' else 'No', '">', sep = ''),
            '<material>',
            '<mattext texttype="text/html" charset="utf-8"><![CDATA[',
             paste(if(enumerate) {
               paste(letters[if(length(solution[[i]]) == 1) i else j], ".", sep = "")
             } else NULL, questionlist[[i]][j]),
            ']]></mattext>',
            '</material>',
            '</response_label>',
            '</flow_label>'
          )
        }

        ## finish response tag
        xml <- c(xml,
          '</render_choice>',
          '</response_lid>'
        )
      } 
      if(type[i] == "string" || type[i] == "num") {
        for(j in seq_along(solution[[i]])) {
          soltext <- if(type[i] == "num") {
            format(round(solution[[i]][j], digits), nsmall = digits)
          } else {
            if(!is.character(solution[[i]][j])) {
              format(round(solution[[i]][j], digits), nsmall = digits)
            } else solution[[i]][j]
          }
          xml <- c(xml,
            if(!is.null(questionlist[[i]][j])) {
              c('<material>',
                paste('<mattext><![CDATA[', paste(if(enumerate) {
                  paste(letters[if(length(solution[[i]]) == 1) i else j], ".", sep = '')
                } else NULL, questionlist[[i]][j]), ']]></mattext>', sep = ""),
                '</material>',
                '<matbreak/>'
              )
            } else NULL,
            paste(if(type[i] == "string") '<response_str ident="' else '<response_num ident="',
              ids[[i]]$response, '" rcardinality="Single">', sep = ''),
            paste('<render_fib maxchars="', maxchars <- if(type[i] == "string") {
                nchar(soltext)
              } else {
                max(c(nchar(soltext), 10))
              }, '" columns="', maxchars, '">', sep = ''),
            '<flow_label class="Block">',
            paste('<response_label ident="', ids[[i]]$response, '" rshuffle="No"/>', sep = ''),
            '</flow_label>',
            '</render_fib>',
            if(type[i] == "string") '</response_str>' else '</response_num>',
            '<matbreak/>'
          )
        }
      }
    }

    ## finish presentation
    xml <- c(xml, '</flow>', '</presentation>')

    ## start resprocessing
    xml <- c(xml,
      '<resprocessing>',
      '<outcomes>',
      paste('<decvar varname="SCORE" vartype="Decimal" defaultval="',
        if(is.null(defaultval)) 0 else defaultval, '" minvalue="',
        if(is.null(minvalue)) 0 else minvalue, '" maxvalue="',
        if(is.null(maxvalue)) points else maxvalue, '" cutvalue="',
        if(is.null(cutvalue)) points else cutvalue, '"/>', sep = ''),
      '</outcomes>')

    ## scoring for the correct answers
    xml <- c(xml,
      '<respcondition title="Mastery" continue="Yes">',
      '<conditionvar>',
      '<and>'
    )

    correct_answers <- NULL
    for(i in 1:n) {
      if(length(grep("choice", type[i]))) {
        for(j in seq_along(solution[[i]])) {
          if(solution[[i]][j]) {
            correct_answers <- c(correct_answers,
              paste('<varequal respident="', ids[[i]]$response,
                '" case="Yes">', ids[[i]]$questions[j], '</varequal>', sep = '')
            )
          }
        }
      }
      if(type[i] == "string" || type[i] == "num") {
        for(j in seq_along(solution[[i]])) {
          if(type[i] == "string") {
            soltext <- if(!is.character(solution[[i]][j])) {
              format(round(solution[[i]][j], digits), nsmall = digits)
            } else solution[[i]][j]
            correct_answers <- c(correct_answers, paste('<varequal respident="', ids[[i]]$response,
              '" case="No"><![CDATA[', soltext, ']]></varequal>', sep = "")
            )
          } else {
            correct_answers <- c(correct_answers,
              paste('<varequal respident="', ids[[i]]$response,
                '" case="No"><![CDATA[', format(round(solution[[i]][j], digits), nsmall = digits),
                ']]></varequal>', sep = "")
#              paste('<vargte respident="', ids[[i]]$response, '"><![CDATA[',
#                solution[[i]][j] - max(tolerance[[i]]),
#                ']]></vargte>', sep = ""),
#              paste('<varlte respident="', ids[[i]]$response, '"><![CDATA[',
#                solution[[i]][j] + max(tolerance[[i]]),
#                ']]></varlte>', sep = "")
            )
          }
        }
      }
    }

    xml <- c(xml,
      correct_answers,
      '</and>',
      '</conditionvar>',
      paste('<setvar varname="SCORE" action="Set">', points, '</setvar>', sep = ''),
      paste('<displayfeedback feedbacktype="Response" linkrefid="Mastery"/>', sep = ''),
      '</respcondition>'
    )

    ## handling incorrect answers
    xml <- c(xml,
      '<respcondition title="Fail" continue="Yes">',
      '<conditionvar>',
      '<not>',
      '<and>',
      correct_answers,
      '</and>',
      '</not>',
      '</conditionvar>',
      '<displayfeedback feedbacktype="Solution" linkrefid="Solution"/>',
      '</respcondition>',
      '</resprocessing>'
    )

    attr(xml, "enumerate") <- enumerate
    attr(xml, "type") <- x$metainfo$type

    xml
  }
}


## function to create identfier ids
## README: speedup by avoiding for() loop and allowing zeros except for first digit
make_id <- function(size, n = 1L) {
  rval <- matrix(sample(0:9, size * n, replace = TRUE), ncol = n, nrow = size)
  rval[1L, ] <- pmax(1L, rval[1L, ])
  colSums(rval * 10^((size - 1L):0L))
}


## write qti12 solutions to .html file
write_qti12_html <- function(exm, dir, name = NULL)
{
  if(is.null(name))
    name <- "qti12sol"

  htmlwrite <- make_exams_write_html(template = NULL, name = name,
    question = TRUE, solution = TRUE, mathjax = FALSE)

  ## write all questions into one exam
  n <- length(exm)
  nq <- length(exm[[1]])
  exmout <- list()

  counter <- 1
  for(j in 1:nq) {
    for(i in 1:n) {
      exmout[[name]][[counter]] <- exm[[i]][[j]]
      counter <- counter + 1
    }
  }

  htmlwrite(exmout[[name]], dir = dir, info = list(id = "", n = length(exmout)))

  invisible(NULL)
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

