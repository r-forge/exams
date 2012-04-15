## writer function for the UIBK exams server in xml format
xml4uibk <- function(x, dir = NULL, name = NULL, ...)
{
  args <- list(...)
  if(is.null(dir)) {
    dir <- tempfile()
    dir.create(dir)
  }

  scipen <- getOption("scipen")
  options("scipen" = 100)  

  examid <- olatid(14)

  if(is.null(name)) name <- paste("Online-Test", Sys.Date(), sep = "-")

  txt <- c(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
    "<!DOCTYPE questestinterop SYSTEM \"ims_qtiasiv1p2p1.dtd\">",
    "",
    "<questestinterop>",
    paste("<assessment ident=",
      if(is.null(args$ident)) paste("\"uibkolat_22_", examid, sep = "") else args$ident,
      "\" title=\"", if(is.null(args$title)) name else args$title, "\">", sep = ""),
    "<qtimetadata>",
    "<qtimetadatafield>",
    "<fieldlabel>qmd_assessmenttype</fieldlabel>",
    "<fieldentry>Assessment</fieldentry>",
    "</qtimetadatafield>",
    "</qtimetadata>",
    paste("<assessmentcontrol feedbackswitch=\"",
      if(is.null(args$feedbackswitch)) "Yes" else args$feedbackswitch, "\" hintswitch=\"",
      if(is.null(args$hintswitch)) "No" else args$hintswitch, "\" solutionswitch=\"",
      if(is.null(args$solutionswitch)) "No" else args$solutionswitch, "\"/>", sep = ""),
    paste("<outcomes_processing scoremodel=\"",
      if(is.null(args$scoremodel)) "SumOfScores" else args$scoremodel, "\">", sep = ""),
    "<outcomes>",
    paste("<decvar varname=\"SCORE\" vartype=\"Decimal\" cutvalue=\"",
      if(is.null(args$cutvalue)) 0.0 else args$cutvalue, "\"/>", sep = ""),
    "</outcomes>",
    "</outcomes_processing>"
  )

  secid <- examid + 1

  ## FIXME: not clear how to set up the samples in each question/section within xexams()?
  ## maybe transform only outside of xexams()???
  for(i in seq_along(x)) {
    a <- 1
  }

  x
}


## convenience function
olatid <- function(x) as.numeric(paste(sample(1:9, x, replace = TRUE), collapse = ""))
