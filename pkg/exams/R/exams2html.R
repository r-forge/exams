## generate exams in .html format
exams2html <- function(file, n = 1L, nsamp = NULL, dir = NULL,
  name = "exam", quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL,
  solution = TRUE, doctype = NULL, head = NULL, mathjax = FALSE, resolution = 100,
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
  htmltransform <- make_exercise_transform_html(...)
  htmlwrite <- make_exams_write_html(doctype, head, mathjax, solution, name)

  ## create final .html exam
  rval <- xexams(file, n = n, nsamp = nsamp,
    driver = list(sweave = list(quiet = quiet, pdf = FALSE, png = TRUE,
      resolution = resolution, width = width, height = height),
      read = NULL, transform = htmltransform, write = htmlwrite),
    dir = dir, edir = edir, tdir = tdir, sdir = sdir)

  ## display single .html on the fly
  if(display) {
    out <- file.path(dir, paste(name, "1.html", sep = ""))
    out <- normalizePath(out)
    browseURL(out)
  }
  
  ## return xexams object invisibly
  invisible(rval)
}


## writes the final .html site
make_exams_write_html <- function(doctype = NULL,
  head = NULL, mathjax = FALSE, solution = TRUE, name = NULL)
{
  function(x, dir, info)
  {
    tdir <- tempfile()
    dir.create(tdir)
    on.exit(unlink(tdir))
    if(is.null(doctype)) {
      doctype <- c(
        '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"',
        '"http://www.w3.org/TR/html4/strict.dtd">'
      )
    }
    if(is.null(head)) {
      mathjax <- if(mathjax) c(
        '<script type="text/javascript"',
        '  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">',
        '</script>'
      ) else character(0)

      head <- c(
        '<head>',
        paste('<title> ', 'exam', info$id, ' </title>', sep = ''),
        '<style type="text/css">',
        'body{font-family:Arial;}',
        '</style>',
	      mathjax,
        '</head>'
      )
    }
    if(is.null(name)) name <- "exam"
    html <- c(doctype, "<html>", head, "<body>", paste('<h2>', 'Exam', info$id, ' </h2>'), "<ol>")
    j <- 1
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
        if(!file.exists(file.path(tdir, "media")))
          dir.create(file.path(tdir, "media"))
        if(!file.exists(media_dir <- file.path(tdir, "media", nid <- paste(name, info$id, sep = ""))))
          dir.create(media_dir)
        if(!file.exists(ex_dir <- file.path(media_dir, exj <- paste("exercise", j, sep = ""))))
          dir.create(ex_dir)
        for(i in ex$supplements) {
          file.copy(i, file.path(ex_dir, basename(i)))
          if(any(grep(dirname(i), html, fixed = TRUE)))
            html <- gsub(dirname(i), file.path("media", nid, exj), html, fixed = TRUE)
          src <- paste('src="', basename(i), sep = "")
          if(any(grep(src, html, fixed = TRUE))) {
            html <- gsub(src, paste('src="', file.path("media", nid, exj, basename(i)),
              sep = ""), html, fixed = TRUE)
          }
          href <- paste('href="', basename(i), sep = "")
          if(any(grep(href, html, fixed = TRUE))) {
            html <- gsub(href, paste('href="', file.path("media", nid, exj, basename(i)),
              sep = ""), html, fixed = TRUE)
          }
        }
      }
      j <- j + 1
    }
    html <- c(html, "</ol>", "</body>", "</html>")
    writeLines(html, file.path(tdir, paste(name, info$id, ".html", sep = "")))
    ## out_dir <- file.path(dir, paste(name, info$id, sep = ""))
    ## dir.create(out_dir)
    file.copy(file.path(tdir, list.files(tdir)), dir, recursive = TRUE)
    invisible(NULL)
  }
}


## show .html code in browser
## FIXME: This is currently also exported in the NAMESPACE. Do we want
## that or was this function mainly useful for internal testing?
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
  browseURL(normalizePath(file.path(tempf, fname)))
}
