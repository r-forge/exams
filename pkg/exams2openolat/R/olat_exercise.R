olat_exercise <- function(x, ..., fixed = TRUE, show = TRUE, mathjax = TRUE)
{
  ## obtain exam list
  if(is.character(x)) x <- readRDS(x)

  ## ... can either be a single integer or a sequence of search terms
  if(length(list(...)) == 1L && is.numeric(..1) && ..1 <= length(x) && ..1 == round(..1)) {
    ix <- cbind(..1, 1L:length(x[[1L]]))
  } else {
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
  }

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
    html <- readLines(file.path(find.package("exams"), "xml", "plain8.html"))
    if(mathjax) {
      script <- '    
<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.3.js"></script>
<script type="text/javascript">
/* <![CDATA[ */
jQuery.noConflict();

function o_mathjax(fct_success) {
	window.MathJax = {
		extensions: ["jsMath2jax.js"],
		messageStyle: \'none\',
		showProcessingMessages: false,
		showMathMenu: false,
		menuSettings: { },
		jsMath2jax: {
			preview: "none"
		},
		tex2jax: {
			ignoreClass: "math"
		},
		"HTML-CSS": {
		    EqnChunk: 5, EqnChunkFactor: 1, EqnChunkDelay: 100
		},
		"fast-preview": {
			disabled: true
		}
	}
	jQuery.ajax("https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML", {
		cache: true,
		dataType: "script",
		crossDomain: true,
		success: function() {
	    	if(!(typeof fct_success === "undefined")) {
	    		fct_success();
	    	}
		}
	});
}
jQuery(function() {
	if ((window.unsafeWindow == null ? window : unsafeWindow).MathJax == null) {
		var count = jQuery(\'div.math,span.math,math,div.mathEntryInteraction\').length;
		if (count > 0) {
		    o_mathjax();
		}
	}
});
/* ]]> */
</script>
'
      jd <- grep("</head>", html, fixed = TRUE)
      html <- c(html[1L:(jd - 1)], script, html[jd:length(html)])
    }
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
