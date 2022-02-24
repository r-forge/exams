exams2openolat <- function(file, n = 1L, dir = ".", name = "olattest",
  qti = "2.1", config = TRUE, converter = "pandoc-mathjax", table = TRUE,
  maxattempts = 1, ...)
{
  ## post-process mathjax output for display in OpenOlat
  .exams_set_internal(pandoc_mathjax_fixup = TRUE)
  on.exit(.exams_set_internal(pandoc_mathjax_fixup = FALSE))
  .exams_set_internal(pandoc_table_class_fixup = table)
  on.exit(.exams_set_internal(pandoc_table_class_fixup = FALSE))

  ## QTI version
  qti <- match.arg(qti, c("1.2", "2.1"))
  
  ## catch if maxattempts is too large for OpenOlat
  if(qti == "2.1" && maxattempts >= 100000) {
    warning("'maxattempts' must be smaller than 100000 in OpenOlat with QTI 2.1")
    maxattempts <- 99999
  }

  ## process configuration
  if(qti == "1.2" && !missing(config)) warning("'config' is not supported in QTI 1.2 export")
  if(isTRUE(config)) config <- openolat_config()
  if(is.list(config) && !identical(names(config), "QTIPackageConfig.xml")) config <- do.call("openolat_config", config)
  if(identical(config, FALSE)) config <- NULL

  ## FIXME: config = "test" should be the same as config = TRUE
  ## additionally support config = "exam"
  
  ## call exams2qti12 or exams2qti21
  rval <- switch(qti,
    "1.2" = exams2qti12(file = file, n = n, dir = dir, name = name,
      converter = converter, maxattempts = maxattempts, ...),
    "2.1" = exams2qti21(file = file, n = n, dir = dir, name = name,
      include = config, converter = converter, maxattempts = maxattempts, ...)
  )
  
  invisible(rval)
}

## QTI package config generator for OpenOlat
openolat_config <- function(
  cancel = FALSE,
  suspend = FALSE,
  scoreprogress = FALSE,
  questionprogress = FALSE,
  maxscoreitem = FALSE, ## FIXME
  menu = TRUE,
  titles = TRUE,
  notes = FALSE,
  hidelms = TRUE,
  hidefeedbacks = FALSE, ## FIXME
  blockaftersuccess = FALSE,
  attempts = 1,
  anonym = FALSE,
  signature = FALSE,
  signaturemail = FALSE,
  resultsonfinish = TRUE, ## FIXME
  itemback = FALSE,
  itemresethard = FALSE,
  itemresetsoft = FALSE,
  itemskip = FALSE,
  passedtype = "none", ## FIXME: alternatives? in sync with cutvalue!!
  metadata = FALSE,
  sectionsummary = TRUE,
  questionsummary = FALSE, ## FIXME or vice versa?
  usersolutions = TRUE,
  correctsolutions = TRUE,
  questions = FALSE) {
  
  to_xml <- function(x) if(is.logical(x)) ifelse(x, "true", "false") else x

  list("QTIPackageConfig.xml" = c(
    '<deliveryOptions>',
    paste0('<enableCancel>', to_xml(cancel), '</enableCancel>'),
    paste0('<enableSuspend>', to_xml(suspend), '</enableSuspend>'),
    paste0('<displayScoreProgress>', to_xml(scoreprogress), '</displayScoreProgress>'),
    paste0('<displayQuestionProgress>', to_xml(questionprogress), '</displayQuestionProgress>'),
    paste0('<displayMaxScoreItem>', to_xml(maxscoreitem), '</displayMaxScoreItem>'),
    paste0('<showMenu>', to_xml(menu), '</showMenu>'),
    paste0('<showTitles>', to_xml(titles), '</showTitles>'),
    paste0('<personalNotes>', to_xml(notes), '</personalNotes>'),
    paste0('<hideLms>', to_xml(hidelms), '</hideLms>'),
    paste0('<hideFeedbacks>', to_xml(hidefeedbacks), '</hideFeedbacks>'),
    paste0('<blockAfterSuccess>', to_xml(blockaftersuccess), '</blockAfterSuccess>'),
    paste0('<maxAttempts>', to_xml(attempts), '</maxAttempts>'),
    paste0('<allowAnonym>', to_xml(anonym), '</allowAnonym>'),
    paste0('<digitalSignature>', to_xml(signature), '</digitalSignature>'),
    paste0('<digitalSignatureMail>', to_xml(signaturemail), '</digitalSignatureMail>'),
    paste0('<showAssessmentResultsOnFinish>', to_xml(resultsonfinish), '</showAssessmentResultsOnFinish>'),
    paste0('<enableAssessmentItemBack>', to_xml(itemback), '</enableAssessmentItemBack>'),
    paste0('<enableAssessmentItemResetHard>', to_xml(itemresethard), '</enableAssessmentItemResetHard>'),
    paste0('<enableAssessmentItemResetSoft>', to_xml(itemresetsoft), '</enableAssessmentItemResetSoft>'),
    paste0('<enableAssessmentItemSkip>', to_xml(itemskip), '</enableAssessmentItemSkip>'),
    paste0('<passedType>', to_xml(passedtype), '</passedType>'),
    paste0('<assessmentResultsOptions>'),
    paste0('<metadata>', to_xml(metadata), '</metadata>'),
    paste0('<sectionSummary>', to_xml(sectionsummary), '</sectionSummary>'),
    paste0('<questionSummary>', to_xml(questionsummary), '</questionSummary>'),
    paste0('<userSolutions>', to_xml(usersolutions), '</userSolutions>'),
    paste0('<correctSolutions>', to_xml(correctsolutions), '</correctSolutions>'),
    paste0('<questions>', to_xml(questions), '</questions>'),
    paste0('</assessmentResultsOptions>'),
    '</deliveryOptions>'
  ))
}
