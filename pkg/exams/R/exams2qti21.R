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
  manifest_xml <- xml[start:end]

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
  maxscore <- 0
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
      if(i < 2)
        maxscore <- maxscore + if(is.null(exm[[i]][[j]]$metainfo$points)) 1 else exm[[i]][[j]]$metainfo$points

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
          if(any(grepl(dirname(exm[[i]][[j]]$supplements[si]), ibody))) {
            ibody <- gsub(dirname(exm[[i]][[j]]$supplements[si]),
              file.path('media', sup_dir), ibody, fixed = TRUE)
          } else {
            if(any(grepl(f, ibody))) {
              ibody <- gsub(paste(f, '"', sep = ''),
                paste('media', sup_dir, f, '"', sep = '/'), ibody, fixed = TRUE)
            }
          }
        }
      }

      ## FIXME: fixups
      fxtab <- rbind(
        c('&nbsp;', ''),
        c('&fnof;', '&#x192;'),
        c('&Alpha;', '&#x391;'),
        c('&Beta;', '&#x392;'),
        c('&Gamma;', '&#x393;'),
        c('&Delta;', '&#x394;'),
        c('&Epsilon;', '&#x395;'),
        c('&Zeta;', '&#x396;'),
        c('&Eta;', '&#x397;'),
        c('&Theta;', '&#x398;'),
        c('&Iota;', '&#x399;'),
        c('&Kappa;', '&#x39A;'),
        c('&Lambda;', '&#x39B;'),
        c('&Mu;', '&#x39C;'),
        c('&Nu;', '&#x39D;'),
        c('&Xi;', '&#x39E;'),
        c('&Omicron;', '&#x39F;'),
        c('&Pi;', '&#x3A0;'),
        c('&Rho;', '&#x3A1;'),
        c('&Sigma;', '&#x3A3;'),
        c('&Tau;', '&#x3A4;'),
        c('&Upsilon;', '&#x3A5;'),
        c('&Phi;', '&#x3A6;'),
        c('&Chi;', '&#x3A7;'),
        c('&Psi;', '&#x3A8;'),
        c('&Omega;', '&#x3A9;'),
        c('&alpha;', '&#x3B1;'),
        c('&beta;', '&#x3B2;'),
        c('&gamma;', '&#x3B3;'),
        c('&delta;', '&#x3B4;'),
        c('&epsilon;', '&#x3B5;'),
        c('&zeta;', '&#x3B6;'),
        c('&eta;', '&#x3B7;'),
        c('&theta;', '&#x3B8;'),
        c('&iota;', '&#x3B9;'),
        c('&kappa;', '&#x3BA;'),
        c('&lambda;', '&#x3BB;'),
        c('&mu;', '&#x3BC;'),
        c('&nu;', '&#x3BD;'),
        c('&xi;', '&#x3BE;'),
        c('&omicron;', '&#x3BF;'),
        c('&pi;', '&#x3C0;'),
        c('&rho;', '&#x3C1;'),
        c('&sigmaf;', '&#x3C2;'),
        c('&sigma;', '&#x3C3;'),
        c('&tau;', '&#x3C4;'),
        c('&upsilon;', '&#x3C5;'),
        c('&phi;', '&#x3C6;'),
        c('&chi;', '&#x3C7;'),
        c('&psi;', '&#x3C8;'),
        c('&omega;', '&#x3C9;'),
        c('&thetasym;', '&#x3D1;'),
        c('&upsih;', '&#x3D2;'),
        c('&piv;', '&#x3D6;'),
        c('&bull;', '&#x2022;'),
        c('&hellip;', '&#x2026;'),
        c('&prime;', '&#x2032;'),
        c('&Prime;', '&#x2033;'),
        c('&oline;', '&#x203E;'),
        c('&frasl;', '&#x2044;'),
        c('&weierp;', '&#x2118;'),
        c('&image;', '&#x2111;'),
        c('&real;', '&#x211C;'),
        c('&trade;', '&#x2122;'),
        c('&alefsym;', '&#x2135;'),
        c('&larr;', '&#x2190;'),
        c('&uarr;', '&#x2191;'),
        c('&rarr;', '&#x2192;'),
        c('&darr;', '&#x2193;'),
        c('&harr;', '&#x2194;'),
        c('&crarr;', '&#x21B5;'),
        c('&lArr;', '&#x21D0;'),
        c('&uArr;', '&#x21D1;'),
        c('&rArr;', '&#x21D2;'),
        c('&dArr;', '&#x21D3;'),
        c('&hArr;', '&#x21D4;'),
        c('&forall;', '&#x2200;'),
        c('&part;', '&#x2202;'),
        c('&exist;', '&#x2203;'),
        c('&empty;', '&#x2205;'),
        c('&nabla;', '&#x2207;'),
        c('&isin;', '&#x2208;'),
        c('&notin;', '&#x2209;'),
        c('&ni;', '&#x220B;'),
        c('&prod;', '&#x220F;'),
        c('&sum;', '&#x2211;'),
        c('&minus;', '&#x2212;'),
        c('&lowast;', '&#x2217;'),
        c('&radic;', '&#x221A;'),
        c('&prop;', '&#x221D;'),
        c('&infin;', '&#x221E;'),
        c('&ang;', '&#x2220;'),
        c('&and;', '&#x2227;'),
        c('&or;', '&#x2228;'),
        c('&cap;', '&#x2229;'),
        c('&cup;', '&#x222A;'),
        c('&int;', '&#x222B;'),
        c('&there4;', '&#x2234;'),
        c('&sim;', '&#x223C;'),
        c('&cong;', '&#x2245;'),
        c('&asymp;', '&#x2248;'),
        c('&ne;', '&#x2260;'),
        c('&equiv;', '&#x2261;'),
        c('&le;', '&#x2264;'),
        c('&ge;', '&#x2265;'),
        c('&sub;', '&#x2282;'),
        c('&sup;', '&#x2283;'),
        c('&nsub;', '&#x2284;'),
        c('&sube;', '&#x2286;'),
        c('&supe;', '&#x2287;'),
        c('&oplus;', '&#x2295;'),
        c('&otimes;', '&#x2297;'),
        c('&perp;', '&#x22A5;'),
        c('&sdot;', '&#x22C5;'),
        c('&lceil;', '&#x2308;'),
        c('&rceil;', '&#x2309;'),
        c('&lfloor;', '&#x230A;'),
        c('&rfloor;', '&#x230B;'),
        c('&lang;', '&#x2329;'),
        c('&rang;', '&#x232A;'),
        c('&loz;', '&#x25CA;'),
        c('&spades;', '&#x2660;'),
        c('&clubs;', '&#x2663;'),
        c('&hearts;', '&#x2665;'),
        c('&diams;', '&#x2666;'),
        c('&OverBar;', '&#175;'),
        c('&UnderBar;', '&#818;') 
      )
      for(i in 1:nrow(fxtab))
        ibody <- gsub(fxtab[i, 1L], fxtab[i, 2L], ibody)

      ## write the item xml to file
      writeLines(c('<?xml version="1.0" encoding="UTF-8"?>', ibody),
        file.path(test_dir, paste(iname, "xml", sep = ".")))

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
  manifest_xml <- gsub("##Date##", '2014-04-08T05:35:56', manifest_xml, fixed = TRUE)

  assessment_xml <- gsub('##AssessmentId##', test_id, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##TestpartId##', paste(test_id, 'part1', sep = '_'),
    assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##TestTitle##', name, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##AssessmentSections##', paste(sec_xml, collapse = '\n'),
    assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##Score##', cutvalue, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##MaxScore##', maxscore, assessment_xml, fixed = TRUE)
  assessment_xml <- gsub('##CutValue##', cutvalue, assessment_xml, fixed = TRUE)

  ## write xmls to dir
  writeLines(c('<?xml version="1.0" encoding="UTF-8"?>', manifest_xml),
    file.path(test_dir, "imsmanifest.xml"))
  writeLines(c('<?xml version="1.0" encoding="UTF-8"?>', assessment_xml),
    file.path(test_dir, paste(test_id, "xml", sep = ".")))

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
      ## evaluate points for each question
      pv[[i]] <- eval$pointvec(solution[[i]])
      if(eval$partial) {
        pv[[i]]["pos"] <- pv[[i]]["pos"] * q_points[i]
        if(length(grep("choice", type[i])))
          pv[[i]]["neg"] <- pv[[i]]["neg"] * q_points[i]
      }
    }

    if(is.null(minvalue)) {
      if(eval$negative) {
        minvalue <- sum(sapply(pv, function(x) { x["neg"] }))
      } else minvalue <- 0
    }

    for(i in 1:n) {
      ## get item id
      iid <- x$metainfo$id

      ## generate ids
      ids[[i]] <- list("response" = paste(iid, "RESPONSE", make_id(7), sep = "_"),
        "questions" = paste(iid, make_id(10, length(x$metainfo$solution)), sep = "_"))

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
            '" lowerBound="', if(!eval$negative) "0.0" else minvalue, '">', sep = '')
        )
        for(j in seq_along(solution[[i]])) {
          xml <- c(xml,
            paste('<mapEntry mapKey="', ids[[i]]$questions[j], '" mappedValue="',
              if(eval$partial) {
                if(solution[[i]][j]) pv[[i]]["pos"] else pv[[i]]["neg"]
              } else {
                if(solution[[i]][j]) q_points[i] / sum(solution[[i]] * 1) else minvalue * sum(solution[[i]] * 1)
              }, '"/>', sep = '')
          )
        }
        xml <- c(xml, '</mapping>', '</responseDeclaration>')
      }
      ## numeric responses
      if(type[i] == "num") {
        xml <- c(xml,
          paste('<responseDeclaration identifier="', ids[[i]]$response, '" cardinality="single" baseType="float">', sep = ''),
        '<correctResponse>',
          paste('<value>', solution[[i]], '</value>', sep = ''),
          '</correctResponse>',
          '</responseDeclaration>'
        )
      }
    }

    xml <- c(xml,
      '<outcomeDeclaration identifier="WORKSCORE" cardinality="single" baseType="float">',
      '<defaultValue>',
      '<value>0.0</value>',
      '</defaultValue>',
      '</outcomeDeclaration>',
      '<outcomeDeclaration identifier="SCORE" cardinality="single" baseType="float">',
      '<defaultValue>',
      '<value>0.0</value>',
      '</defaultValue>',
      '</outcomeDeclaration>',
      '<outcomeDeclaration identifier="MAXSCORE" cardinality="single" baseType="float">',
      '<defaultValue>',
      paste('<value>', sum(q_points), '</value>', sep = ''),
      '</defaultValue>',
      '</outcomeDeclaration>',
      '<outcomeDeclaration identifier="FEEDBACKBASIC" cardinality="single" baseType="identifier" view="testConstructor">',
      '<defaultValue>',
      '<value>empty</value>',
      '</defaultValue>',
      '</outcomeDeclaration>',
      '<outcomeDeclaration identifier="FEEDBACKMODAL" cardinality="multiple" baseType="identifier" view="testConstructor"/>'
    )

    ## starting the itembody
    xml <- c(xml, '<itemBody>')
    if(!is.null(x$question))
      xml <- c(xml, '<p>', x$question, '</p>')

    for(i in 1:n) {
      if(length(grep("choice", type[i]))) {
        xml <- c(xml,
          paste('<choiceInteraction responseIdentifier="', ids[[i]]$response,
            '" shuffle="', if(shuffle) 'true' else 'false','" maxChoices="',
            if(type[i] == "schoice") "1" else "0", '">', sep = '')
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
      if(type[i] == "num") {
        for(j in seq_along(solution[[i]])) {
          xml <- c(xml,
            '<p>',
            if(!is.null(questionlist[[i]][j])) {
              paste(if(enumerate & n > 1) {
                paste(letters[if(x$metainfo$type == "cloze") i else j], ".",
                  if(x$metainfo$type == "cloze" && length(solution[[i]]) > 1) paste(j, ".", sep = "") else NULL,
                  sep = "")
               } else NULL, if(!is.na(questionlist[[i]][j])) questionlist[[i]][j] else NULL)
            },
            paste('<textEntryInteraction responseIdentifier="', ids[[i]]$response, '"/>', sep = ''),
            '</p>'
          )
        }
      }
    }

    ## close itembody
    xml <- c(xml, '</itemBody>')

    ## response processing
    xml <- c(xml, '<responseProcessing>')

    ## all not answered
    xml <- c(xml,
      '<responseCondition>',
      '<responseIf>',
      if(n > 1) '<and>' else NULL
    )
    for(i in 1:n) {
      xml <- c(xml,
        '<isNull>',
        paste('<variable identifier="', ids[[i]]$response, '"/>', sep = ''),
        '</isNull>'
      )
    }
    xml <- c(xml,
      if(n > 1) '</and>' else NULL,
      '<setOutcomeValue identifier="FEEDBACKBASIC">',
      '<baseValue baseType="identifier">empty</baseValue>',
      '</setOutcomeValue>',
      '</responseIf>',
      '<responseElseIf>',
      '<setOutcomeValue identifier="FEEDBACKBASIC">',
      '<baseValue baseType="identifier">correct</baseValue>',
      '</setOutcomeValue>',
      '</responseElseIf>',
      '</responseCondition>'
    )

    ## not answered points single
    for(i in 1:n) {
      xml <- c(xml,
        '<responseCondition>',
        '<responseIf>',
        '<isNull>',
        paste('<variable identifier="', ids[[i]]$response, '"/>', sep = ''),
        '</isNull>',
        '<setOutcomeValue identifier="WORKSCORE">',
        '<sum>',
        '<variable identifier="WORKSCORE"/>',
        '<baseValue baseType="float">0.0</baseValue>', ## FIXME: points when not answered?
        '</sum>',
        '</setOutcomeValue>',
        '</responseIf>',
        '</responseCondition>'
      )
    }

    ## set the score
    for(i in 1:n) {
      xml <- c(xml,
        '<responseCondition>',
        '<responseIf>',
        if(type[i] == "num") '<and>' else NULL,
        '<match>',
        '<variable identifier="FEEDBACKBASIC"/>',
        '<baseValue baseType="identifier">correct</baseValue>',
        '</match>',
        if(type[i] == "num") {
          c(
            paste('<equal toleranceMode="absolute" tolerance="', max(tol[[i]]), ' ',
              max(tol[[i]]),'" includeLowerBound="true" includeUpperBound="true">', sep = ''),
            paste('<variable identifier="', ids[[i]]$response, '"/>', sep = ''),
            paste('<correct identifier="', ids[[i]]$response, '"/>', sep = ''),
            '</equal>'
          )
        },
        if(type[i] == "num") '</and>' else NULL,
        '<setOutcomeValue identifier="WORKSCORE">',
        '<sum>',
        '<variable identifier="WORKSCORE"/>',
        switch(type[i],
          "mchoice" =  paste('<mapResponse identifier="', ids[[i]]$response, '"/>', sep = ''),
          "schoice" =  paste('<mapResponse identifier="', ids[[i]]$response, '"/>', sep = ''),
          "num" = paste('<baseValue baseType="float">', pv[[i]]["pos"], '</baseValue>', sep = '')
        ),
        '</sum>',
        '</setOutcomeValue>',
        '</responseIf>',
        '</responseCondition>'
      )
    }

    ## show solution when answered and wrong
    xml <- c(xml,
      '<responseCondition>',
      '<responseIf>',
      '<equal toleranceMode="exact">',
      '<variable identifier="WORKSCORE"/>',
      '<variable identifier="MAXSCORE"/>',
      '</equal>',
      '<setOutcomeValue identifier="FEEDBACK">',
      '<baseValue baseType="identifier">correct</baseValue>',
      '</setOutcomeValue>',
      '</responseIf>',
      '<responseElse>',
      '<setOutcomeValue identifier="FEEDBACK">',
      '<baseValue baseType="identifier">incorrect</baseValue>',
      '</setOutcomeValue>',
      '</responseElse>',
      '</responseCondition>'
    )

    xml <- c(xml,
      '<responseCondition>',
      '<responseIf>',
      '<and>',
      '<match>',
      '<baseValue baseType="identifier">incorrect</baseValue>',
      '<variable identifier="FEEDBACKBASIC"/>',
      '</match>',
      '</and>',
      '<setOutcomeValue identifier="SCORE">',
      '<sum>',
      '<variable identifier="SCORE"/>',
      paste('<baseValue baseType="float">', minvalue, '</baseValue>', sep = ''),
      '</sum>',
      '</setOutcomeValue>',
      '</responseIf>',
      '<responseElse>',
      '<setOutcomeValue identifier="SCORE">',
      '<sum>',
      '<variable identifier="SCORE"/>',
      if(!eval$partial) {
        paste('<baseValue baseType="float">', sum(q_points), '</baseValue>', sep = '')
      } else {
        '<variable identifier="WORKSCORE"/>'
      },
      '</sum>',
      '</setOutcomeValue>',
      '</responseElse>',
      '</responseCondition>'
    )

    fid <- make_id(9, 1)
    xml <- c(xml,
      '<responseCondition>',
      '<responseIf>',
      '<and>',
      '<match>',
      '<baseValue baseType="identifier">incorrect</baseValue>',
      '<variable identifier="FEEDBACKBASIC"/>',
      '</match>',
      '</and>',
      '<setOutcomeValue identifier="FEEDBACKMODAL">',
      '<multiple>',
      '<variable identifier="FEEDBACKMODAL"/>',
      paste('<baseValue baseType="identifier">Feedback', fid, '</baseValue>', sep = ''),
      '</multiple>',
      '</setOutcomeValue>',
      '</responseIf>',
      '</responseCondition>'
    )

    ## create solution
    xsolution <- x$solution
    if(length(length(x$solutionlist))) {
      if(!all(is.na(x$solutionlist))) {
        xsolution <- c(xsolution, if(length(xsolution)) "<br />" else NULL)
        if(enumerate) xsolution <- c(xsolution, '<ol type = "a">')
        if(x$metainfo$type == "cloze") {
          g <- rep(seq_along(x$metainfo$solution), sapply(x$metainfo$solution, length))
          ql <- sapply(split(x$questionlist, g), paste, collapse = " / ")
          sl <- sapply(split(x$solutionlist, g), paste, collapse = " / ")
        } else {
          ql <- x$questionlist
          sl <- x$solutionlist
        }
        nsol <- length(ql)
        xsolution <- c(xsolution, paste(if(enumerate) rep('<li>', nsol) else NULL,
          ql, if(length(x$solutionlist)) "<br />" else NULL,
          sl, if(enumerate) rep('</li>', nsol) else NULL))
        if(enumerate) xsolution <- c(xsolution, '</ol>')
      }
    }

    xml <- c(xml, '</responseProcessing>')

    ## solution when wrong
    xml <- c(xml,
      paste('<modalFeedback identifier="Feedback', fid, '" outcomeIdentifier="FEEDBACKMODAL" showHide="show">', sep = ''),
      '<p>',
      xsolution,
      '</p>',
      '</modalFeedback>'
    )

    xml <- c(xml, '</assessmentItem>')

    xml
  }
}

