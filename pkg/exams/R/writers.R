## version based on make_exams_write_pdf(),
## first generates a full .tex file, then,
## the converter ex2html() is applied to generate
## the final .html file
exams2html <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  template = "plain", inputs = NULL, header = list(Date = Sys.Date()),
  name = NULL, control = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  mathjax = FALSE, converter = "ttx", show = NULL, ...)
{
  ## if dir = NULL, the function will create a tempfile()
  ## and show the .html file in the default browser
  ## using function show.html()
  show <- if(is.null(show)) FALSE else show
  if(is.null(dir)) {
    dir <- tempfile()
    show <- TRUE
  }

  ## this is parsed to function make_exams_write_pdf(), to generate
  ## the final .html file
  options("ex2html" = make_exams_write_tex2html(converter = converter,
    mathjax = mathjax, show = show, ...))

  pdfwrite <- make_exams_write_pdf(template = template, inputs = inputs,
    header = header, name = name, quiet = quiet, control = control)

  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL, transform = NULL, write = pdfwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}


## writer function for .html conversion of one single exam
## based on a full .tex file
make_exams_write_tex2html <- function(converter = "ttx", mathjax = FALSE, show = TRUE, ...)
{
  args <- list(...)
  function(tex, dir)
  {
    bsname <- file_path_sans_ext(basename(tex))
    hdir <- file.path(dir, bsname)
    dir.create(hdir)
    owd <- getwd()
    setwd(hdir)
    on.exit(setwd(owd))
    cfiles <- list.files(owd)
    file.copy(file.path(owd, cfiles), file.path(hdir, cfiles))
    args$body <- FALSE
    args$x <- file.path(hdir, tex)
    args$tdir <- hdir
    html <- do.call(converter, args)
    if(mathjax) {
      if(length(i <- grep("</head>", html))) {
        html <- c(
          html[1:(i - 1)],
          '<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>',
          html[i:length(html)]
        )
      }
    }
    for(cf in cfiles) {
      if(file.exists(cf <- file.path(hdir, cf)))
        file.remove(cf)
    }
    htmlfile <- paste(bsname, "html", sep = ".")
    writeLines(html, htmlfile)
    if(!is.null(imgs <- attr(html, "images"))) {
      for(i in imgs)
        file.copy(i, file.path(hdir, basename(i)))
    }
    if(show) show.html(htmlfile)
  }
}


## show html code in browser
show.html <- function(x)
{
  if(length(x) == 1L && file.exists(x[1L])) {
    tempf <- dirname(x)
    fname <- basename(x)
  } else {
    dir.create(tempf <- tempfile())
    fname <- "show.html"
    writeLines(x, file.path(tempf, fname))
    if(!is.null(imgs <- attr(x, "images"))) {
      for(i in imgs)
        file.copy(i, file.path(tempf, basename(i)))
    }
  }
  system(paste(shQuote(getOption("browser")),
    shQuote(file.path(tempf, fname))), wait = FALSE)
  invisible(NULL)
}


## version for more general .xml or .html file generation
## the idea is to convert each question and then apply
## a selfmade document generator
exams2x <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  type = "html", converter = "ttx", base64 = TRUE, width = 550,
  body = TRUE, solution = TRUE, doctype = NULL, head = NULL, ...)
{
  wasNULL <- FALSE
  if(is.null(dir)) {
    dir <- tempfile()
    wasNULL <- TRUE
  }

  htmltransform <- make_exercise_transform_html(converter = converter,
    base64 = base64, body = body, width = width, ...)

  writer <- paste("make_exams_write", type, sep = "_")
  args <- list(...)
  args$dir <- dir
  args$doctype <- doctype
  args$head <- head
  args$solution <- solution
  args$name <- name
  args$wasNULL <- wasNULL
  htmlwrite <- do.call(writer, args)

  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet), read = NULL,
    transform = htmltransform, write = htmlwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}


## writes the final html site
make_exams_write_html <- function(dir, doctype = NULL,
  head = NULL, solution = TRUE, name = NULL, mathjax = FALSE, ...)
{
  function(x, dir, info)
  {
    tdir <- tempfile()
    sdir <- NULL
    dir.create(tdir)
    on.exit(unlink(tdir))
    if(is.null(doctype)) {
      doctype <- c(
        '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"',
        '"http://www.w3.org/TR/html4/strict.dtd">'
      )
    }
    if(is.null(head)) {
      head <- c(
        '<head>',
        paste('<title> ', 'exam', info$id, ' </title>', sep = ''),
        '<style type="text/css">',
        'body{font-family:Arial;}',
        '</style>',
        if(mathjax) {
          c('<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">',
          '</script>')
        } else {
          NULL
        },
        '</head>'
      )
    }
    html <- c(doctype, "<html>", head, "<body>", paste('<h2>', 'Exam', info$id, ' </h2>'), "<ol>")
    for(ex in x) {
      html <- c(html, "<li>", "<h4>", "Question", "</h4>", ex$question, "<br/>")
      if(length(ex$questionlist)) {
        html <- c(html, '<ol type="a">')
        for(i in ex$questionlist)
          html <- c(html, "<li>", i, "</li>")
        html <- c(html, "</ol>", "<br/>")
      }
      if(solution) {
        html <- c(html, "<h4>", "Solution", "</h4>")
        if(length(ex$solutionlist)) {
          html <- c(html, '<ol type="a">')
          for(i in ex$solutionlist)
            html <- c(html, "<li>", i, "</li>")
          html <- c(html, "</ol>", "<br/>")
        }
        if(length(ex$solution)) {
          html <- c(html, ex$solution, "<br/>")
        }
      }
      html <- c(html, "</li>")
      if(length(ex$supplements)) {
        for(i in ex$supplements) {
          if(any(grepl(basename(i), html)))
            file.copy(i, file.path(tdir, basename(i)))
        }
      }
      sdir <- c(sdir, attr(ex$supplements, "dir"))
    }
    html <- c(html, "</ol>", "</body>", "</html>")
    if(length(sdir))
      for(i in sdir) gsub(i, "", html, fixed = TRUE)
    if(is.null(name))
      name <- "exam"
    writeLines(html, file.path(tdir, paste(name, info$id, ".html", sep = "")))
    out_dir <- file.path(dir, paste(name, info$id, sep = ""))
    dir.create(out_dir)
    file.copy(file.path(tdir, list.files(tdir)), file.path(out_dir, list.files(tdir)))
    args <- list(...)
    if(!is.null(args$wasNULL) && args$wasNULL)
      show.html(file.path(out_dir, paste(name, info$id, ".html", sep = "")))
    invisible(NULL)
  }
}


## a writer function for OLAT .xml test files
## currently the supported mode is only multiple choice
make_exams_write_olat <- function(dir, doctype = NULL,
  head = NULL, solution = TRUE, name = NULL, mathjax = FALSE, ...)
{
  function(x, dir, info)
  {
    tdir <- tempfile()
    sdir <- NULL
    dir.create(tdir)
    on.exit(unlink(tdir))
  }
}
