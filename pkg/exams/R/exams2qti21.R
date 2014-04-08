## create IMS QTI 2.1 .xml files
## specifications and examples available at:
## http://www.imsglobal.org/question/#version2.1
## https://www.ibm.com/developerworks/library/x-qti/
## https://www.onyx-editor.de/
exams2qti21 <- function(file, n = 1L, nsamp = NULL, dir = ".",
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  resolution = 100, width = 4, height = 4, encoding  = "",
  num = NULL, mchoice = NULL, schoice = mchoice, string = NULL, cloze = NULL,
  template = "qti21",
  duration = NULL, stitle = "Exercise", ititle = "Question",
  adescription = "Please solve the following exercises.",
  sdescription = "Please answer the following question.", 
  maxattempts = 1, cutvalue = 0, solutionswitch = TRUE, zip = TRUE,
  points = NULL, eval = list(partial = TRUE, negative = FALSE), ...)
{
  ## set up .html transformer
  htmltransform <- make_exercise_transform_html(...)

  ## generate the exam
  is.xexam <- FALSE
  if(is.list(file)) {
    if(any(grepl("exam1", names(file))))
      is.xexam <- TRUE
  }
  if(!is.xexam) {
    exm <- xexams(file, n = n, nsamp = nsamp,
      driver = list(
        sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
          resolution = resolution, width = width, height = height,
          encoding = encoding),
        read = NULL, transform = htmltransform, write = NULL),
      dir = dir, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose)
  } else {
    exm <- file
    rm(file)
  }

  ## start .xml assessement creation
  ## get the possible item body functions and options  
  itembody = list(num = num, mchoice = mchoice, schoice = schoice, cloze = cloze, string = string)

  for(i in c("num", "mchoice", "schoice", "cloze", "string")) {
    if(is.null(itembody[[i]])) itembody[[i]] <- list()
    if(is.list(itembody[[i]])) {
      if(is.null(itembody[[i]]$eval))
        itembody[[i]]$eval <- eval
      if(i == "cloze" & is.null(itembody[[i]]$eval$rule))
        itembody[[i]]$eval$rule <- "none"
      itembody[[i]] <- do.call("make_itembody_qti21", itembody[[i]])
    }
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
  pkg_dir <- find.package("exams")

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

  ## check template for all necessary tags
  ## extract the template for the assessement, sections and items
  if(length(start <- grep("<assessmentTest", xml, fixed = TRUE)) != 1L ||
    length(end <- grep("</assessmentTest>", xml, fixed = TRUE)) != 1L) {
    stop(paste("The XML template", template,
      "must contain exactly one opening and closing <assessmentTest> tag!"))
  }
  assessment_xml <- xml[start:end]

  if(length(start <- grep("<assessmentSection", xml, fixed = TRUE)) != 1L ||
    length(end <- grep("</assessmentSection>", xml, fixed = TRUE)) != 1L) {
    stop(paste("The XML template", template,
      "must contain exactly one opening and closing <assessmentSection> tag!"))
  }
  section_xml <- xml[start:end]

  if(length(start <- grep("<manifest", xml, fixed = TRUE)) != 1L ||
    length(end <- grep("</manifest>", xml, fixed = TRUE)) != 1L) {
    stop(paste("The XML template", template,
      "must contain exactly one opening and closing <manifest> tag!"))
  }
  manifest_xml <- c('<?xml version="1.0" encoding="UTF-8"?>', xml[start:end])

  ## obtain the number of exams and questions
  nx <- length(exm)
  nq <- if(!is.xexam) length(exm[[1L]]) else length(exm)

  ## create a name
  if(is.null(name)) name <- file_path_sans_ext(basename(template))

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
  sec_ids <- paste(test_id, make_test_ids(nq, type = "section"), sep = "_")

  ## create section/item titles and section description
  if(is.null(stitle)) stitle <- ""
  stitle <- rep(stitle, length.out = nq)
  if(!is.null(ititle)) ititle <- rep(ititle, length.out = nq)
  if(is.null(adescription)) adescription <- ""
  if(is.null(sdescription)) sdescription <- ""
  sdescription <- rep(sdescription, length.out = nq)

  ## points setting
  if(!is.null(points))
    points <- rep(points, length.out = nq)

  ## create the directory where the test is stored
  dir.create(test_dir <- file.path(tdir, name))

  ## cycle through all exams and questions
  ## similar questions are combined in a section,
  ## questions are then sampled from the sections
  items <- sec_xml <- sec_items_D <- sec_items_R <- NULL
  for(j in 1:nq) {
    ## first, create the section header
    sec_xml <- c(sec_xml, gsub("##SectionId##", sec_ids[j], section_xml, fixed = TRUE))

    ## insert a section title -> exm[[1]][[j]]$metainfo$name?
    sec_xml <- gsub("##SectionTitle##", stitle[j], sec_xml, fixed = TRUE)

    ## insert a section description -> exm[[1]][[j]]$metainfo$description?
    sec_xml <- gsub("##SectionDescription##", sdescription[j], sec_xml, fixed = TRUE)

    ## special handler
    if(is.xexam) nx <- length(exm[[j]])

    ## create item ids
    item_ids <- paste(sec_ids[j], make_test_ids(nx, type = "item"), sep = "_")

    ## collect items for section linking
    sec_items_A <- NULL

    ## now, insert the questions
    for(i in 1:nx) {
      ## special handling of indices
      if(is.xexam) {
        if(i < 2)
          jk <- j
        j <- i
        i <- jk
      }

      ## overule points
      if(!is.null(points)) exm[[i]][[j]]$metainfo$points <- points[[j]]

      ## get and insert the item body
      type <- exm[[i]][[j]]$metainfo$type

      ## create an id
      iname <- paste(item_ids[if(is.xexam) j else i], type, sep = "_")

      ## attach item id to metainfo
      exm[[i]][[j]]$metainfo$id <- iname

      ibody <- itembody[[type]](exm[[i]][[j]])

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
            ibody <- gsub(paste(f, '"', sep = ''),
              paste('media', sup_dir, f, '"', sep = '/'), ibody, fixed = TRUE)
          }
        }
      }

      ## write the item xml to file
      writeLines(ibody, file.path(test_dir, paste(iname, "xml", sep = ".")))

      ## include body in section
      sec_items_A <- c(sec_items_A,
        paste('<assessmentItemRef identifier="', iname, '" href="', iname, '.xml" fixed="false"/>', sep = '')
      )
      sec_items_D <- c(sec_items_D,
        paste('<dependency identifierref="', paste(iname, 'id', sep = '_'), '"/>', sep = '')
      )
      sec_items_R <- c(sec_items_R,
        paste('<resource identifier="', paste(iname, 'id', sep = '_'), '" type="imsqti_item_xmlv2p1" href="', iname, '.xml">', sep = ''),
        paste('<file href="', iname, '.xml"/>', sep = ''),
        '</resource>'
      )
    }

    sec_xml <- gsub('##SectionItems##', paste(sec_items_A, collapse = '\n'), sec_xml, fixed = TRUE)
  }

  manifest_xml <- gsub('##AssessmentId##',
    test_id, manifest_xml, fixed = TRUE)
  manifest_xml <- gsub('##AssessmentTitle##',
    name, manifest_xml, fixed = TRUE)
  manifest_xml <- gsub('##ManifestItemDependencies##',
    paste(sec_items_D, collapse = '\n'), manifest_xml, fixed = TRUE)
  manifest_xml <- gsub('##ManifestItemRessources##',
    paste(sec_items_R, collapse = '\n'), manifest_xml, fixed = TRUE)
  manifest_xml <- gsub("##AssessmentDescription##", adescription, manifest_xml, fixed = TRUE)

  assessment_xml <- gsub('##AssessmentId##', test_id, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##TestpartId##', paste(test_id, 'part1', sep = '_'),
    assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##TestTitle##', name, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##AssessmentSections##', paste(sec_xml, collapse = '\n'),
    assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##Score##', cutvalue, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##MaxScore##',
    if(!is.null(points)) sum(unlist(points)) else 10000, assessment_xml, fixed = TRUE)

  ## write xmls to dir
  writeLines(manifest_xml, file.path(test_dir, "imsmanifest.xml"))
  writeLines(assessment_xml, file.path(test_dir, paste(test_id, "xml", sep = ".")))

  ## compress
  if(zip) {
    owd <- getwd()
    setwd(test_dir)
    zip(zipfile = zipname <- paste(name, "zip", sep = "."), files = list.files(test_dir))
    setwd(owd)
  } else zipname <- list.files(test_dir)

  ## copy the final .zip file
  file.copy(file.path(test_dir, zipname), dir, recursive = TRUE)

  ## assign test id as an attribute
  attr(exm, "test_id") <- test_id

  invisible(exm)
}


## QTI 2.1 item body constructor function
make_itembody_qti21 <- function(rtiming = FALSE, shuffle = FALSE, rshuffle = shuffle,
  minnumber = NULL, maxnumber = NULL, defaultval = NULL, minvalue = NULL,
  maxvalue = NULL, cutvalue = NULL, enumerate = TRUE, digits = NULL, tolerance = is.null(digits),
  maxchars = 12, eval = list(partial = TRUE, negative = FALSE), fix_num = TRUE)
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
      if(x$metainfo$type == "cloze") {
        g <- rep(seq_along(x$metainfo$solution), sapply(x$metainfo$solution, length))
        split(x$questionlist, g)
      } else list(x$questionlist)
    } else x$questionlist
    if(length(questionlist) < 1) questionlist <- NULL

    tol <- if(!is.list(x$metainfo$tolerance)) {
      if(x$metainfo$type == "cloze") as.list(x$metainfo$tolerance) else list(x$metainfo$tolerance)
    } else x$metainfo$tolerance
    tol <- rep(tol, length.out = n)

    q_points <- rep(points, length.out = n)
    if(x$metainfo$type == "cloze")
      points <- sum(q_points)

    ## set question type(s)
    type <- x$metainfo$type
    type <- if(type == "cloze") x$metainfo$clozetype else rep(type, length.out = n)

    ## evaluation policy
    if(is.null(eval) || length(eval) < 1L) eval <- exams_eval()
    if(!is.list(eval)) stop("'eval' needs to specify a list of partial/negative/rule")
    eval <- eval[match(c("partial", "negative", "rule"), names(eval), nomatch = 0)]
    if(x$metainfo$type %in% c("num", "string")) eval$partial <- FALSE
    if(x$metainfo$type == "cloze" & is.null(eval$rule)) eval$rule <- "none"
    eval <- do.call("exams_eval", eval) ## always re-call exams_eval

    ## character fields
    maxchars <- if(is.null(x$metainfo$maxchars)) {
        if(length(maxchars) < 2) {
           c(maxchars, NA, NA)
        } else maxchars[1:3]
    } else x$metainfo$maxchars
    if(!is.list(maxchars))
      maxchars <- list(maxchars)
    maxchars <- rep(maxchars, length.out = n)
    for(j in seq_along(maxchars)) {
      if(length(maxchars[[j]]) < 2)
        maxchars[[j]] <- c(maxchars[[j]], NA, NA)
    }

    ## start item presentation
    ## and insert question
    xml <- paste('<assessmentItem xsi:schemaLocation="http://www.imsglobal.org/xsd/imsqti_v2p1 http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1p1.xsd http://www.w3.org/1998/Math/MathML http://www.w3.org/Math/XMLSchema/mathml2/mathml2.xsd" identifier="', x$metainfo$id, '" title="', x$metainfo$name, '" adaptive="false" timeDependent="false" xmlns="http://www.imsglobal.org/xsd/imsqti_v2p1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">', sep = '')
    
    ## cycle trough all questions
    ids <- el <- pv <- list()
    for(i in 1:n) {
      ## get item id
      iid <- x$metainfo$id

      ## generate ids
      ids[[i]] <- list("response" = paste(iid, "RESPONSE", make_id(7), sep = "_"),
        "questions" = paste(iid, make_id(10, length(x$metainfo$solution)), sep = "_"))

      ## evaluate points for each question
      pv[[i]] <- eval$pointvec(solution[[i]])
      if(eval$partial) {
        pv[[i]]["pos"] <- pv[[i]]["pos"] * q_points[i]
        if(length(grep("choice", type[i])))
          pv[[i]]["neg"] <- pv[[i]]["neg"] * q_points[i]
      }

      ## insert choice type responses
      if(length(grep("choice", type[i]))) {
        xml <- c(xml,
          paste('<responseDeclaration identifier="', ids[[i]]$response,
            '" cardinality="', if(type[i] == "mchoice") "multiple" else "single", '" baseType="identifier">', sep = ''),
          '<correctResponse>'
        )
        for(j in seq_along(solution[[i]])) {
          if(solution[[i]][j]) {
            xml <- c(xml,
              paste('<value>', ids[[i]]$questions[j], '</value>', sep = '')
            )
          }
        }
        xml <- c(xml, '</correctResponse>',
          paste('<mapping defaultValue="', if(is.null(defaultval)) 0 else defaultval,
            '" lowerBound="', if(is.null(minvalue)) "0.0" else minvalue, '">', sep = '')
        )
        for(j in seq_along(solution[[i]])) {
          xml <- c(xml,
            paste('<mapEntry mapKey="', ids[[i]]$questions[j], '" mappedValue="',
              if(solution[[i]][j]) pv[[i]]["pos"] else pv[[i]]["neg"], '"/>', sep = '')
          )
        }
        xml <- c(xml, '</mapping>', '</responseDeclaration>')
      }
    }

    xml <- c(xml,
      '<outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float">',
      '<defaultValue>',
      '<value>0</value>',
      '</defaultValue>',
      '</outcomeDeclaration>',
      '<outcomeDeclaration identifier="MAXSCORE" cardinality="single" baseType="float">',
      '<defaultValue>',
      paste('<value>', sum(q_points), '</value>', sep = ''),
      '</defaultValue>',
      '</outcomeDeclaration>'
    )

    ## starting the itembody
    xml <- c(xml, '<itemBody>')
    if(!is.null(x$question))
      xml <- c(xml, '<p>', x$question, '</p>')

    for(i in 1:n) {
      if(length(grep("choice", type[i]))) {
        xml <- c(xml,
          paste('<choiceInteraction responseIdentifier="', ids[[i]]$response,
            '" shuffle="', if(shuffle) 'true' else 'false','" maxChoices="0">', sep = '')
        )
        for(j in seq_along(solution[[i]])) {
          xml <- c(xml, paste('<simpleChoice identifier="', ids[[i]]$questions[j], '">', sep = ''),
            '<p>',
             paste(if(enumerate) {
               paste(letters[if(x$metainfo$type == "cloze") i else j], ".",
                 if(x$metainfo$type == "cloze" && length(solution[[i]]) > 1) paste(j, ".", sep = "") else NULL,
                 sep = "")
             } else NULL, questionlist[[i]][j]),
            '</p>',
            '</simpleChoice>'
          )
        }
        xml <- c(xml, '</choiceInteraction>')
      }
    }

    ## close itembody
    xml <- c(xml, '</itemBody>')

    ## response processing
    xml <- c(xml, '<responseProcessing>')

    ## not answered, then points
    for(i in 1:n) {
      xml <- c(xml,
        '<responseCondition>',
        '<responseIf>',
        '<isNull>',
        paste('<variable identifier="', ids[[i]]$response, '"/>', sep = ''),
        '</isNull>',
        '<setOutcomeValue identifier="SCORE">',
        '<sum>',
        '<variable identifier="SCORE"/>',
        '<baseValue baseType="float">0.0</baseValue>', ## FIXME: points when not answered?
        '</sum>',
        '</setOutcomeValue>',
        '<setOutcomeValue identifier="FEEDBACKBASIC">',
        '<baseValue baseType="identifier">incorrect</baseValue>',
        '</setOutcomeValue>',
        '</responseIf>',
        '<responseElse>',
        '<setOutcomeValue identifier="SCORE">',
        '<sum>',
        '<variable identifier="SCORE"/>',
         if(length(grep("choice", type[i]))) {
           if(eval$partial) {
             paste('<mapResponse identifier="', ids[[i]]$response, '"/>', sep = '')
           } else {
             paste('<baseValue baseType="float">', pv[[i]]["pos"], '</baseValue>', sep = '')
           }
         },
        '</sum>',
        '</setOutcomeValue>',
        '</responseElse>',
        '</responseCondition>'
      )
    }

    xml <- c(xml, '</responseProcessing>', '</assessmentItem>')

    xml
  }
}
