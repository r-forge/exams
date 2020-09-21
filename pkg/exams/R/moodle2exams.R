moodle2exams <- function(x, dir = NULL, tdir = NULL)
{
  stopifnot(requireNamespace("xml2"))

  if(is.null(tdir)) {
    tdir <- tempfile()
    dir.create(tdir)
    on.exit(unlink(tdir))
  }

  if(length(x) < 2)
    x <- xml2::read_xml(x)

  owd <- getwd()
  setwd(tdir)

  qu <- xml2::xml_find_all(x, "question")
  types <- xml2::xml_attr(qu, "type")
  converted <- list()
  i <- 1
  titles <- NULL
  for(j in 1:length(qu)) {
    if(types[j] == "cloze")
      warning("cloze conversion not fully supported yet!")
    quj <- xml2::xml_children(qu[[j]])
    qn <- xml2::xml_name(quj)
    if("questiontext" %in% qn) {
      qtext <- xml2::xml_text(quj[qn == "questiontext"])
      qtext <- pandoc(qtext, from = "html", to = "markdown_strict")
      exsol <- extol <- feedback <- NULL
      answers <- solutions <- list()
      if(types[j] == "numerical") {
        exsol <- xml2::xml_text(xml2::xml_children(quj[qn == "answer"])[1])
        extol <- xml2::xml_children(quj[qn == "answer"])
        if("tolerance" %in% xml2::xml_name(extol))
          extol <- xml2::xml_text(extol[xml2::xml_name(extol) == "tolerance"])
      }
      if(types[j] == "multichoice") {
        ans <- quj[qn == "answer"]
        frac <- xml2::xml_attr(ans, "fraction")
        frac <- as.numeric(frac)
        sol <- frac > 0
        exsol <- paste0(sol * 1, collapse = "")
        for(j in 1:length(ans)) {
          ac <- xml2::xml_children(ans[j])
          ac <- ac[xml2::xml_name(ac) == "text"]
          ac <- xml2::xml_text(ac)
          answers[[j]] <- pandoc(ac[1], from = "html", to = "markdown_strict")
          if(length(ac) > 1)
            solutions[[j]] <- pandoc(ac[2], from = "html", to = "markdown_strict")
        }
      }
      if(types[j] == "shortanswer") {
        ans <- xml2::xml_children(quj[qn == "answer"])
        exsol <- xml2::xml_text(ans[xml2::xml_name(ans) == "text"][1])
      }

      if("generalfeedback" %in% qn) {
        feedback <- quj[qn == "generalfeedback"]
        feedback <- xml2::xml_text(feedback)
        feedback <- pandoc(feedback, from = "html", to = "markdown_strict")
      }

      extitle <- xml2::xml_text(quj[qn == "name"])
      extype <- switch(types[j],
        "numerical" = "numeric",
        "essay" = "string",
        "cloze" = "cloze",
        "multichoice" = "mchoice",
        "shortanswer" = "string"
      )

      rmd <- c("Question", "========",
        qtext, "",
        if(types[j] == "multichoice") {
          c(paste("*", unlist(answers)), "")
        } else NULL,
        "Solution", "========",
        "",
        if(length(solutions)) {
          c(paste("*", unlist(solutions)), "")
        } else NULL,
        if(!is.null(feedback)) {
          c(feedback, "")
        } else NULL,
        "Meta-information",
        "================",
        paste("exname:", extitle),
        paste("extype:", extype),
        paste("exsolution:", exsol),
        if(!is.null(extol)) {
          paste("extol:", extol)
        } else NULL
      )

      converted[[i]] <- rmd
      titles <- c(titles, extitle)
      i <- i + 1
    }
  }

  titles <- gsub(" ", "", titles)
  titles <- gsub("...", "", titles, fixed = TRUE)
  titles <- paste0("ex", 1:length(titles), "_", titles)
  names(converted) <- titles

  setwd(owd)

  if(!is.null(dir)) {
    for(j in 1:length(converted)) {
      writeLines(converted[[j]], file.path(dir, paste0(titles[j], ".Rmd")))
    }
  }

  converted
}

