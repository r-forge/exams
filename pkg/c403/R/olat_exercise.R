olat_exercise <- function(x, ..., fixed = TRUE, show = TRUE)
{
  ## obtain exam list
  if(is.character(x)) x <- readRDS(x)
  
  ## all questions
  qu <- t(sapply(x, function(y) sapply(y, function(z)
    paste(c(z$question, unlist(z$questionlist)), collapse = " "))))

  ## determine index of matching questions
  ix <- lapply(list(...), function(pt)
    grepl(pattern = pt, x = qu, fixed = fixed))
  ix <- Reduce("&", ix)
  dim(ix) <- dim(qu)
  ix <- which(ix, arr.ind = TRUE)
  if(nrow(ix) < 1L) stop("no matching exercises found")

  ## extract corresponding exercises  
  exm <- lapply(1L:nrow(ix), function(i) {
    x[[ix[i,,drop = TRUE]]]
  })
  
  ## turn into HTML if requested
  if(show) {
    ## question and solution insertion
    html_body <- "<ol>"
    for(j in seq_along(exm)) {
      html_body <- c(html_body, "<li>")
      html_body <- c(html_body, "<h4>Question</h4>", exm[[j]]$question, "<br/>")
      if(length(exm[[j]]$questionlist) & !is.null(exm[[j]]$questionlist)) {
    	html_body <- c(html_body, '<ol type="a">')
    	for(ql in exm[[j]]$questionlist) {
    	  if(!is.null(ql) & !is.na(ql))
    	    html_body <- c(html_body, "<li>", ql, "</li>")
    	}
    	html_body <- c(html_body, "</ol>", "<br/>")
      }
      html_body <- c(html_body, "<h4>Solution</h4>", exm[[j]]$solution, "<br/>")
      if(length(exm[[j]]$solutionlist) & !is.null(exm[[j]]$solutionlist)) {
    	html_body <- c(html_body, '<ol type="a">')
    	for(sl in exm[[j]]$solutionlist)
    	  html_body <- c(html_body, "<li>", sl, "</li>")
    	html_body <- c(html_body, "</ol>", "<br/>")
      }
      html_body <- c(html_body, "</li>")
    }    
    html_body <- c(html_body, "</ol>")  

    ## combine with template
    html <- readLines(file.path(find.package("exams"), "xml", "plain.html"))
    html <- gsub("##ID##", "", html, fixed = TRUE)
    html <- gsub("##\\exinput{exercises}##", paste(html_body, collapse = "\n"), html, fixed = TRUE)

    ## display
    open_exercise_in_browser(html)
  }
  
  ## return matching exercise(s) (invisibly)
  if(nrow(ix) == 1L) exm <- exm[[1L]]
  if(show) invisible(exm) else return(exm)
}

## show .html code in browser, only used for internal testing
open_exercise_in_browser <- function(x)
{
  if(length(x) == 1L && file.exists(x[1L])) {
    tempf <- dirname(x)
    fname <- basename(x)
  } else {
    dir.create(tempf <- tempfile())
    fname <- "exercise.html"
    writeLines(x, file.path(tempf, fname))
    if(!is.null(imgs <- attr(x, "images"))) {
      for(i in imgs)
        file.copy(i, file.path(tempf, basename(i)))
    }
  }
  browseURL(normalizePath(file.path(tempf, fname)))
}