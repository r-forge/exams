## create IMS QTI 2.1 .xml files
## specifications and examples available at:
## http://www.imsglobal.org/question/#version2.1
## http://www.imsglobal.org/question/qtiv1p2/imsqti_asi_bestv1p2.html#1466669
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
  for(j in 1:nq) {
    ## first, create the section header
    sec_xml <- c(sec_xml, gsub("##SectionId##", sec_ids[j], section_xml, fixed = TRUE), "")

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

      ## include body in section
      sec_items_A <- c(sec_items_A,
        paste('<assessmentItemRef identifier="', iname, '" href="', iname, '.xml" fixed="false"/>', sep = '')
      )
      sec_items_D <- c(sec_items_D,
        paste('<dependency identifierref="', iname, '"/>', sep = '')
      )
      sec_items_R <- c(sec_items_R,
        paste('<resource identifier="', iname, '" type="imsqti_item_xmlv2p1" href="', iname, '.xml">', sep = ''),
        paste('<file href="', iname, '.xml"/>', sep = ''),
        '</resource>'
      )
    }

    sec_xml <- gsub('##SectionItems##', paste(sec_items_A, collapse = '\n'), sec_xml, fixed = TRUE)
  }

  manifest_xml <- gsub('##AssessmentId##',
    test_id, manifest_xml, fixed = TRUE)
  manifest_xml <- gsub('##ManifestItemDependencies##',
    paste(sec_items_D, collapse = '\n'), manifest_xml, fixed = TRUE)
  manifest_xml <- gsub('##ManifestItemRessources##',
    paste(sec_items_R, collapse = '\n'), manifest_xml, fixed = TRUE)

  writeLines(manifest_xml)
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

    "This is the item XML."
  }
}


## Function to nicely format XML files
formatXML <- function(files = NULL, dir = ".")
{
  rpkg <- paste(c("X", "M", "L"), collapse = "")
  call <- paste("re", "quire(", rpkg, ")", sep = "", collapse = "")
  eval(parse(text = call))
  if(is.null(files)) files <- dir(dir)
  dir.create(fdir <- file.path(dir, "formatXML"))
  owd <- getwd()
  setwd(dir)
  on.exit(setwd(owd))
  for(f in files) {
    xml <- try(xmlTreeParse(f)$doc$children[[1]], silent = TRUE)
    if(inherits(xml, "try-error")) warning(paste("could not format file:", f))
    sink(file.path(fdir, f))
    print(xml)
    sink()
  }
}

