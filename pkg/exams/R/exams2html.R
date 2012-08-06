## generate exams in .html format
exams2html <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  solution = TRUE, doctype = NULL, head = NULL, resolution = 100,
  width = 4, height = 4, ...)
{
  ## specify a directory if 'dir = NULL'
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    dirNULL <- TRUE
  } else dirNULL <- FALSE

  ## set up .html transformer and writer function
  htmltransform <- make_exercise_transform_x(...)
  htmlwrite <- make_exams_write_html(doctype, head, solution, name, dirNULL = dirNULL, ...)

  ## create final .html exam
  xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
      resolution = resolution, width = width, height = height),
      read = NULL, transform = htmltransform, write = htmlwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)
}


## writes the final .html site
make_exams_write_html <- function(doctype = NULL,
  head = NULL, solution = TRUE, name = NULL, ...)
{
  function(x, dir, info)
  {
    args <- list(...)
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
          file.copy(i, file.path(tdir, basename(i)))
        }
      }
      sdir <- c(sdir, attr(ex$supplements, "dir"))
    }
    html <- c(html, "</ol>", "</body>", "</html>")
    if(length(sdir))
      for(i in sdir) html <- gsub(paste(i, "/", sep = ""), "", html, fixed = TRUE)
    if(is.null(name))
      name <- "exam"
    writeLines(html, file.path(tdir, paste(name, info$id, ".html", sep = "")))
    out_dir <- file.path(dir, paste(name, info$id, sep = ""))
    dir.create(out_dir)
    file.copy(file.path(tdir, list.files(tdir)), file.path(out_dir, list.files(tdir)))
    if(!is.null(args$dirNULL) && args$dirNULL)
      show.html(file.path(out_dir, paste(name, info$id, ".html", sep = "")))
    invisible(NULL)
  }
}


## show .html code in browser
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

