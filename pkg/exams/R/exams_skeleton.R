exams_skeleton <- exams.skeleton <- function(dir = ".",
  type = c("num", "schoice", "mchoice", "cloze", "string"),
  writer = c("exams2html", "exams2pdf", "exams2moodle", "exams2qti12"),
  absolute = FALSE)
{
  ## match available types/writers
  type <- as.vector(sapply(type, match.arg,
    c("num", "schoice", "mchoice", "cloze", "string")))
  writer <- as.vector(sapply(writer, match.arg,
    c("exams2html", "exams2pdf", "exams2moodle", "exams2qti12")))

  ## create output directory (if necessary)
  create_dir <- function(path) {
    isdir <- file.info(path)$isdir
    if(identical(isdir, FALSE)) stop(sprintf("File (rather than directory) %s exists.", path))
    if(is.na(isdir)) dir.create(path)
  }
  create_dir(dir)
  create_dir(edir <- file.path(dir, "exercises"))
  if(!identical(writer, "exams2moodle")) create_dir(templ <- file.path(dir, "templates"))
  pdir <- find.package("exams")
  if(absolute) dir <- file_path_as_absolute(dir)
  
  ## select exercises fro demo script and all available exercises
  exrc <- c(
    "num"     = "tstat.Rnw",
    "schoice" = "tstat2.Rnw",
    "mchoice" = "boxplots.Rnw",
    "cloze"   = "boxhist.Rnw",
    "string"  = "function.Rnw"
  )
  exrc <- exrc[type]
  axrc <- list.files(path = file.path(pdir, "exercises"), pattern = "Rnw$")
  axrc <- axrc[axrc != "confint.Rnw"]
  file.copy(file.path(pdir, "exercises", axrc), edir)
  
  ## copy templates
  if("exams2pdf"   %in% writer) file.copy(file.path(pdir, "tex", c("exam.tex", "solution.tex")), templ)
  if("exams2html"  %in% writer) file.copy(file.path(pdir, "xml", "plain.html"), templ)
  if("exams2qti12" %in% writer) file.copy(file.path(pdir, "xml", "qti12.xml"), templ)
  
  ## start script
  script <- c(
    '## load package',
    'library("exams")',
    '',
    '## exam with a simple vector of exercises',
    '## (alternatively try a list of vectors of more exercises)',
    sprintf('myexam <- c("%s")', paste(exrc, collapse = '", "')),
    '',
    ''
  )

  if("exams2html" %in% writer) script <- c(script,
    '## generate a single HTML exam (shown in browser)',
    'exams2html(myexam, n = 1,',
    sprintf('  edir = "%s",', if(absolute) file.path(dir, "exercises") else "exercises"),
    sprintf('  template = "%s")', if(absolute) file.path(dir, "templates", "plain.html") else file.path("templates", "plain.html")),
    '',
    '## generate three HTML exams without solutions in output directory',
    'exams2html(myexam, n = 3, name = "html-demo", solution = FALSE,',
    sprintf('  dir = "%s",', if(absolute) file.path(dir, "output") else "output"),
    sprintf('  edir = "%s",', if(absolute) file.path(dir, "exercises") else "exercises"),
    sprintf('  template = "%s")', if(absolute) file.path(dir, "templates", "plain.html") else file.path("templates", "plain.html")),
    '',
    ''
  )
  
  if("exams2pdf" %in% writer) script <- c(script,
    '## generate a single PDF exam (shown in PDF viewer)',
    'exams2pdf(myexam, n = 1,',
    sprintf('  edir = "%s",', if(absolute) file.path(dir, "exercises") else "exercises"),
    sprintf('  template = "%s")', if(absolute) file.path(dir, "templates", "exam.tex") else file.path("templates", "exam.tex")),
    '',
    '## generate three PDF exams and corresponding solutions in output directory',
    'exams2pdf(myexam, n = 3, name = c("pdf-exam", "pdf-solution"),',
    sprintf('  dir = "%s",', if(absolute) file.path(dir, "output") else "output"),
    sprintf('  edir = "%s",', if(absolute) file.path(dir, "exercises") else "exercises"),
    sprintf('  template = c("%s", "%s"))',
      if(absolute) file.path(dir, "templates", "exam.tex") else file.path("templates", "exam.tex"),
      if(absolute) file.path(dir, "templates", "exam.tex") else file.path("templates", "solution.tex")),
    '',
    ''
  )

  if("exams2moodle" %in% writer) script <- c(script,
    '## generate Moodle exam with three replications per question',
    'exams2moodle(myexam, n = 3, name = "moodle-demo",',
    sprintf('  dir = "%s",', if(absolute) file.path(dir, "output") else "output"),    
    sprintf('  edir = "%s")', if(absolute) file.path(dir, "exercises") else "exercises"),
    '',
    ''
  )
  
  if("exams2qti12" %in% writer) script <- c(script,
    '## generate QTI 1.2 exam for OLAT/OpenOLAT with three replications per question',
    '## (showing correct solutions after failed attempts and passing only if solving',
    '## all items)',
    'exams2qti12(myexam, n = 3, name = "qti12-demo",',
    sprintf('  dir = "%s",', if(absolute) file.path(dir, "output") else "output"),    
    sprintf('  edir = "%s",', if(absolute) file.path(dir, "exercises") else "exercises"),
    sprintf('  template = "%s",', if(absolute) file.path(dir, "templates", "qti12.xml") else file.path("templates", "qti12.xml")),
    sprintf('  solutionswitch = TRUE, maxattempts = 1, cutvalue = %i)', length(exrc)),
    '',
    ''
  )
  
  writeLines(script, file.path(dir, "demo.R"))
  invisible(script)
}
