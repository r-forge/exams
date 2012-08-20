## generate exams in .html format
exams2html <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = "exam", quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  solution = TRUE, doctype = NULL, head = NULL, resolution = 100,
  width = 4, height = 4, ...)
{
  ## output directory or display on the fly (n == 1L & is.null(dir))
  display <- is.null(dir)
  if(is.null(dir)) {
    if(n == 1L) {
      display <- TRUE
      dir.create(dir <- tempfile())
    } else {
      stop("Please specify an output 'dir'.")
    }
  }

  ## set up .html transformer and writer function
  htmltransform <- make_exercise_transform_x(...)
  htmlwrite <- make_exams_write_html(doctype, head, solution, name, ...)

  ## create final .html exam
  rval <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
      resolution = resolution, width = width, height = height),
      read = NULL, transform = htmltransform, write = htmlwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  ## display single .html on the fly
  if(display) {
    out <- file.path(dir, paste(name, 1, sep = ""), paste(name, "1.html", sep = ""))
    ## FIXME: Maybe omit extra exam layer directory?
    browseURL(out)
  }
  
  ## return xexams object invisibly
  invisible(rval)
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
        if(length(ex$solution)) {
          html <- c(html, ex$solution, "<br/>")
        }
        if(length(ex$solutionlist)) {
          html <- c(html, '<ol type="a">')
          for(i in ex$solutionlist)
            html <- c(html, "<li>", i, "</li>")
          html <- c(html, "</ol>", "<br/>")
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
    if(is.null(name)) name <- "exam"
    writeLines(html, file.path(tdir, paste(name, info$id, ".html", sep = "")))
    out_dir <- file.path(dir, paste(name, info$id, sep = ""))
    dir.create(out_dir)
    file.copy(file.path(tdir, list.files(tdir)), file.path(out_dir, list.files(tdir)))
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
  browseURL(file.path(tempf, fname))
}
