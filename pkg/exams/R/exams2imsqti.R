exams2imsqti <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  type = "html", converter = "ttx", base64 = TRUE, width = 550,
  body = TRUE, solution = TRUE, doctype = NULL, head = NULL, ...)
{
  transform2x <- make_exercise_transform_x(converter = converter,
    base64 = base64, body = body, width = width, ...)

  exm <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL, transform = transform2x),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  make_exams_write_imsqti(exm, dir, name, ...)

  invisible(exm)
}


make_exams_write_imsqti <- function(x, dir, name = NULL,
  template.assessment = NULL, template.items = NULL, ...)
{
  dir <- path.expand(dir)
  if(!file.exists(dir))
    dir.create(dir)

  pkg_dir <- .find.package("exams")

  ## obtain the number of exams and questions
  nx <- length(x)
  nq <- length(x[[1]])

  ## the unique test id
  test_id <- make_id(14)
  
  ## get the assement template
  template.assessment <- if(is.null(template.assessment)) {
    file.path(pkg_dir, "xml", "imsqti-test.xml")
  } else path.expand(template.assessment)
  if(!file.exists(template.assessment))
    stop(paste("The following file cannot be found: ", template.assessment, "!", sep = ""))
  xml.assessment <- readLines(template.assessment)

  ## create a name
  name <- if(is.null(name)) {
    paste(file_path_sans_ext(basename(template.assessment)), test_id, sep = "_")
  } else name

  ## create the directory where the .xml files are stored
  dir.create(dir <- file.path(dir, name))

  ## get the item templates
  if(is.null(template.items)) {
    xml_dir <- file.path(pkg_dir, "xml")
    item_templates <- grep("item", list.files(xml_dir), value = TRUE)
    xml.items <- list()
    for(i in seq_along(item_templates)) {
      spec <- strsplit(item_templates[i], "-")[[1]]
      spec <- file_path_sans_ext(spec[length(spec)])
      xml.items[[spec]] <- readLines(file.path(xml_dir, item_templates[i]))
    }
  } else {
    xml.items <- template.items
    if(!is.list(xml.items)) stop("Argument 'template.items' must be a named list!")
    if(!any(names(xml.items) %in% c("mchoice", "num")))
      stop("The names of the list argument 'template.items' are specified wrong, possible names are 'mchoice', 'num'!")
    for(i in seq_along(xml.items)) {
      if(file.exists(fi <- path.expand(xml.items[[i]][1])))
        xml.items[[i]] <- readLines(fi)
    }
  }

  ## cycle through all exams and questions
  ## similar questions are combined in a section, questions are then sampled from the sections
  items <- points <- NULL
  for(j in 1:nq) {
    for(i in 1:nx) {
      ex <- x[[i]][[j]]
      type <- ex$metainfo$type
      class(ex) <- c(type, "list")
      file_name <- write.imsqti.item(ex, dir, xml.items[[type]], ...)
      items <- c(items, file_name)
      points <- c(points, attr(file_name, "points"))
    }
  }

  ## insert the items in assessment
  oit <- file_path_sans_ext(items)
  for(i in seq_along(items)) {
    items[i] <-   paste('<assessmentItemRef identifier="', file_path_sans_ext(items[i]),
      '" href="', items[i], '" fixed="false" />', sep = "")
  }
  xml.assessment <- input_text("##ItemRefs", items, xml.assessment)

  ## input the test points
  xml.assessment <- gsub("##TestPoints", sum(points), xml.assessment, fixed = TRUE)

  ## input the test title
  xml.assessment <- gsub("##TestTitle", name, xml.assessment, fixed = TRUE)

  ## input the test identifier
  xml.assessment <- gsub("##TestIdentifier", name, xml.assessment, fixed = TRUE)

  ## write assessment to file
  writeLines(xml.assessment, file.path(dir, paste(name, "xml", sep = ".")))

  ## copy ims manifest and other
  cfiles <- file.path(file.path(pkg_dir, "xml"),
    c("imscp_v1p1.xsd", "imsmd_v1p2p2.xsd", "imsqti_v2p1.xsd"))
  file.copy(cfiles, dir)

  ## get the manifest files
  xml.manifest <- readLines(file.path(pkg_dir, "xml", "imsmanifest.xml"))
  xml.manifest.item <- readLines(file.path(pkg_dir, "xml", "imsmanifest-item.xml"))

  ## MANIFEST FILES, FIXME not clear if needed
  ## insert test identifier
  xml.manifest <- gsub("##TestIdentifier", name, xml.manifest, fixed = TRUE)

  ## insert the test title
  xml.manifest <- gsub("##TestTitle", name, xml.manifest, fixed = TRUE)

  ## insertin the item refs and manifests
  irefs <- imanifests <- NULL
  for(i in seq_along(oit)) {
    irefs <- c(irefs, paste('<imscp:dependency identifierref="', oit[i], '"/>', sep = ""))
    im <- gsub("##ItemIdentifier", oit[i], xml.manifest.item, fixed = TRUE)
    im <- gsub("##ItemTitle", oit[i], im, fixed = TRUE)
    imanifests <- c(imanifests, im)
  }

  ## insert refs and item manifests
  xml.manifest <- input_text("##ItemRefs", irefs, xml.manifest)
  xml.manifest <- input_text("##ItemManifests", imanifests, xml.manifest)

  ## write to dir
  writeLines(xml.manifest, file.path(dir, "imsmanifest.xml"))

  ## compress
  owd <- getwd()
  setwd(dir)
  zip(zipfile = paste(name, "zip", sep = "."), files = list.files(dir))
  setwd(owd)
}


## function to create identfiers
make_id <- function(size, n = 1)
{
  rval <- NULL
  for(i in 1:n)
    rval <- c(rval, as.numeric(paste(sample(1:9, size, replace = TRUE), collapse = "")))
  rval
}


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


write.imsqti.item.mchoice <- function(x, dir, xml, ...)
{
  ## checks for necessary tags
  check_tags(c("##ItemBody", "##ResponseIdentifier", "##CorrectAnswer"), xml, x$metainfo$type)

  ## create a unique item, response and feedback identifier
  item_id <- paste("MP1", make_id(9), sep = "_")
  resp_id <- paste("RESPONSE", make_id(7), sep = "_")
  feed_id <- paste("FEEDBACK", make_id(8), sep = "_")

  ## input the item body
  body <- c(
    '<itemBody>',
    paste(x$question, collapse = "\n"),
    paste('<choiceInteraction responseIdentifier="', resp_id, '" shuffle="false" maxChoices="0">')
  )

  ## generate the choice ids
  choice_ids <- paste("choice", make_id(9, length(x$questionlist)), sep = "_")

  ## input all questions
  for(j in seq_along(x$questionlist)) {
    body <- c(body,
      paste('<simpleChoice identifier="', choice_ids[j], '">', sep = ""),
      x$questionlist[j],
      '</simpleChoice>'
    )
  }

  ## finish the body
  body <- c(body,
    '</choiceInteraction>',
    '</itemBody>'
  )

  ## input the body
  xml <- input_text("##ItemBody", body, xml)

  ## input the id if the correct answer
  xml <- input_text("##CorrectAnswer", choice_ids[x$metainfo$solution], xml)

  ## input the response id
  xml <- gsub("##ResponseIdentifier", resp_id, xml, fixed = TRUE)

  ## input the item id
  xml <- gsub("##ItemIdentifier", item_id, xml, fixed = TRUE)

  ## input a feedback id
  xml <- gsub("##FeedbackIdentifier", feed_id, xml, fixed = TRUE)

  ## input points
  points <- if(!is.null(x$metainfo$points)) x$metainfo$points else 1
  xml <- gsub("##ItemPoints", points, xml, fixed = TRUE)

  ## input the name
  xml <- gsub("##ItemTitle", x$metainfo$name, xml, fixed = TRUE)

  ## input solution as feedback
  xml <- input_text("##FeedbackText", x$solution, xml)

  ## the item file name
  file_name <- paste(item_id, "xml", sep = ".")

  ## write item to file
  writeLines(xml, file.path(dir, file_name))

  ## store item points as an attribute
  attr(file_name, "points") <- points

  file_name
}


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


write.imsqti.item.num <- function(x, dir, xml, ...)
{
  NULL
}
