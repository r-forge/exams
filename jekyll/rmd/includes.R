include_rmd <- function(file, ...)
{
  ## assure UTF-8 locale
  Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## create temporary directory
  if(!file.exists("_tempdir")) dir.create("_tempdir")
  root <- tools::file_path_as_absolute("_tempdir")
  file <- file.path("..", file)
  setwd("_tempdir")

  ## store all 'assets' (figures and other supplementary files)
  ## in post-specific sub-directory
  assets <- file.path("..", "..", "..", "assets", "posts", tools::file_path_sans_ext(basename(file)))
  if(!file.exists(assets)) dir.create(assets)

  ## the output .md file should be in _posts/<category>/*.md
  output <- tools::file_path_sans_ext(tools::file_path_as_absolute(file))
  output <- paste(c("..", "..", "..", "_posts", utils::tail(strsplit(output, "/")[[1L]], 2L)), collapse = "/")
  output <- paste0(output, ".md")

  ## default knitr settings (can be queried within .Rmd processing)
  if(!exists(".knitr_opts_vanilla")) .knitr_opts_vanilla <<- list(chunk = knitr::opts_chunk$get(), knit = knitr::opts_knit$get(), hooks = knitr::knit_hooks$get())
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = paste0(assets, "/"), knitr::render_jekyll("prettify"))
  knitr::opts_knit$set(root.dir = root)
  .knitr_opts_custom <<- list(chunk = knitr::opts_chunk$get(), knit = knitr::opts_knit$get(), hooks = knitr::knit_hooks$get())
    
  ## process .Rmd
  rval <- knitr::knit(input = file, output = output, quiet = TRUE, encoding = "UTF-8")

  if(file.exists("media")) file.copy("media", assets, recursive = TRUE)

  ## if no assets were produced, delete folder
  if(length(list.files(assets)) < 1L) unlink(assets)

  ## fix-ups in Markdown output
  md <- readLines(output, encoding = "UTF-8")
  ## - yaml header
  if(md[1] != "---") {
    ix <- min(which(md == "---")) - 1
    md <- md[-(1:ix)]
  }
  ## - relative links using {{ site.url }} syntax
  md <- gsub("../../../assets", "{{ site.url }}/assets", md, fixed = TRUE)
  writeLines(md, output)
  
  ## clean up
  setwd("..")
  unlink("_tempdir", recursive = TRUE)
  
  invisible(rval)
}

include_asset <- function(file, asset = TRUE, screenshot = TRUE, link = TRUE, density = 25, aspect43 = TRUE, border = TRUE, ...)
{
  ## expand file path if necessary
  if(any(grepl("*", file, fixed = TRUE))) file <- Sys.glob(file)

  ## file type
  ext <- unique(tools::file_ext(file))
  
  ## handle options
  if(!all(ext %in% c("png", "pdf", "html")) | length(ext) > 1L) screenshot <- FALSE
  if(link) asset <- TRUE
  
  ## make a screenshot/thumb?
  if(screenshot) {
    file_s <- do.call(paste("include", ext, "screenshot", sep = "_"), c(
      list(file = file, density = density, aspect43 = aspect43, border = border),
      list(...)))
  }
  
  ## copy file to assets?
  if(asset) file_a <- include_file(file)

  ## create link?
  if(link) {
    file_l <- if(screenshot) {
      sprintf("[![%s](%s)](%s)", basename(file_a), file_s, file_a)
    } else {
      sprintf("[%s](%s)", basename(file_a), file_a)
    }
    return(file_l)
  }
  
  if(asset) return(file_a) else return()
}

include_png_screenshot <- function(file, out = NULL, density = 25, aspect43 = TRUE, border = TRUE)
{
  ## screenshot .png path
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(basename(file)), "-thumb.png")
  if(knitr::opts_chunk$get("fig.path") != "figure/") out <- paste0(knitr::opts_chunk$get("fig.path"), out)

  ## make all screenshots/thumbnails with ImageMagick's 'mogrify'
  for(i in seq_along(file)) {
    file.copy(file[i], out[i], overwrite = TRUE)
    cmd <- sprintf("mogrify -resize %s %s %s %s",
      density * 8.268,
      if(aspect43) sprintf("-extent %sx%s", ceiling(density * 8.268), ceiling(density * 8.268 * 0.75)) else "",
      if(border) sprintf("-border %sx%s -bordercolor '#666666'", ceiling(density/15), ceiling(density/15)) else "",
      out[i])
    system(cmd)    
  }
  
  ## return paths of screenshots invisibly
  invisible(out)
}

include_pdf_screenshot <- function(file, out = NULL, page = 1, density = 25, aspect43 = TRUE, border = TRUE)
{
  ## screenshot .png path
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(basename(file)), ".png")
  if(knitr::opts_chunk$get("fig.path") != "figure/") out <- paste0(knitr::opts_chunk$get("fig.path"), out)

  if(is.numeric(border)) {
    bordersize <- border
    border <- TRUE
  } else {
    if(border) bordersize <- ceiling(density/15)
  }

  ## make all screenshots with ImageMagick's 'convert'
  for(i in seq_along(file)) {
    cmd <- sprintf("convert -density %s -extent %sx%s %s %s[%s] %s",
      density, round(density * 8.268), ceiling(density * if(aspect43) 8.268 * 0.75 else 11.693),
      if(border) sprintf("-border %sx%s -bordercolor '#666666'", bordersize, bordersize) else "",
      file[i], page - 1, out[i])
    system(cmd)
  }
  
  ## return paths of screenshots invisibly
  invisible(out)
}

include_html_screenshot <- function(file, out = NULL, density = 25, aspect43 = TRUE, border = TRUE, engine = c("cutycapt", "firefox", "chromium"))
{
  ## engine
  ## - 'cutycapt' is available via but does not support MathML
  ## - or open 'firefox' and handle window via 'xdotool' and 'wmctrl'
  engine <- match.arg(engine, c("cutycapt", "firefox", "chromium"))
  ## all tools available via apt-get install

  ## screenshot .png path
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(basename(file)), ".png")
  if(knitr::opts_chunk$get("fig.path") != "figure/") out <- paste0(knitr::opts_chunk$get("fig.path"), out)

  ## make screenshots with 'cutycapt' or 'firefox'/'chromium' (+xdotool +wmctrl)
  ## and resize/crop with ImageMagick's 'mogrify'
  for(i in seq_along(file)) {
    if(engine == "cutycapt") {
      cmd <- sprintf("cutycapt --url=file://%s --out=%s",
        tools::file_path_as_absolute(file[i]),
        out[i])
      system(cmd)
    } else {
      system(sprintf("%s -new-window %s", engine, tools::file_path_as_absolute(file[i])))
      Sys.sleep(1)
      id<- sprintf("xdotool search --onlyvisible --name --all '%s'", if(engine == "firefox") "Mozilla Firefox" else "Chromium")
      id <- tail(sort(as.numeric(system(id, intern = TRUE))), 1L)
      system(sprintf("wmctrl -ir %s -b remove,maximized_vert,maximized_horz", id))
      system(sprintf("xdotool windowsize %s 600 800", id))
      Sys.sleep(1)
      system(sprintf("import -window %s %s", id, out[i]))
    }
    off <- switch(engine,
      "cutycapt" = 0,
      "firefox" = 2,
      "chromium" = 1.8
    )
    cmd <- sprintf("mogrify -resize %s %s %s %s %s",
      density * 8.268,
      if(aspect43) sprintf("-extent %sx%s", ceiling(density * 8.268), ceiling(density * (8.268 * 0.75 + off))) else "",
      if(off > 0) sprintf("-gravity north -chop x%s", off * density) else "",
      if(border) sprintf("-border %sx%s -bordercolor '#666666'", ceiling(density/15), ceiling(density/15)) else "",
      tools::file_path_as_absolute(out[i]))
    system(cmd)    
  }
  
  ## return paths of screenshots invisibly
  invisible(out)
}

include_file <- function(file) {
  file.copy(file, knitr::opts_chunk$get("fig.path"), overwrite = TRUE)
  invisible(file.path(knitr::opts_chunk$get("fig.path"), basename(file)))
}

include_template <- function(name, title, teaser, description,
  tags = NULL, related = NULL, randomization = "Yes", supplements = "",
  author = "zeileis", thumb = c(277, 216), page = 1, seed = 1090, utf8 = FALSE)
{
  ## assure UTF-8 locale
  Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## path to assets of post
  assets <- if(knitr::opts_chunk$get("fig.path") == "figure/") "FIXME" else knitr::opts_chunk$get("fig.path")

  ## switch off jekyll rendering hook for template processing
  knitr::knit_hooks$set(.knitr_opts_vanilla$hooks)
  on.exit(knitr::knit_hooks$set(.knitr_opts_custom$hooks))

  ## related exercises: either posts or asset files
  if(length(related) < 1L) {
    related <- ""
  } else {
    exr <- related[tools::file_ext(related) != ""]
    if(length(exr) > 0L) {
      file.copy(system.file("exercises", exr, package = "exams"), to = getwd(), overwrite = TRUE)
      include_asset(exr, link = FALSE)    
    }
    related <- sapply(related, function(r) if(tools::file_ext(r) == "") {
      sprintf('<a href="{{ site.url }}/templates/%s/"><code class="highlighter-rouge">%s</code></a>', r, r)
    } else {
      sprintf('<a href="%s/%s">%s</a>', assets, r, r)
    })
    related <- paste(related, collapse = ", ")
    related <- paste(
      "<div class='row t1 b1'>",
      "  <div class='medium-4 columns'><b>Related:</b></div>",
      sprintf("  <div class='medium-8 columns'>%s</div>", related),
      "</div>",
      collapse = "\n")
  }
  
  ## generate and process asset files
  stopifnot(require("exams"))
  f <- paste0(name, c(
    ".Rnw", ".Rmd",
    ".tex", ".md",
    "-Rnw.html", "-Rmd.html",
    "-Rnw.pdf", "-Rmd.pdf",
    "-Rnw-html.png", "-Rmd-html.png",
    "-Rnw-pdf.png", "-Rmd-pdf.png",
    ".small.png"))
  ##
  ## - exercise templates
  ex <- system.file("exercises", f[1:2], package = "exams")
  file.copy(ex, to = getwd())
  include_asset(f[1:2], link = FALSE)
  ##
  ## - raw
  set.seed(seed)
  Sweave(f[1], encoding = "UTF-8")
  include_asset(f[3], link = FALSE)
  set.seed(seed)
  knitr::knit(f[2], quiet = TRUE, encoding = "UTF-8")
  include_asset(f[4], link = FALSE)
  ##
  ## - HTML
  set.seed(seed)
  ex_html <- if(!utf8) {
    exams2html(f[1], name = "blog", dir = ".")[[1]][[1]]
  } else {
    exams2html(f[1], name = "blog", dir = ".", template = "plain8", encoding = "UTF-8")[[1]][[1]]
  }
  file.rename("blog1.html", f[5])
  include_asset(f[5], engine = "firefox", link = FALSE, out = f[9])
  ##
  set.seed(seed)
  knitr::opts_chunk$set(.knitr_opts_vanilla$chunk)
  knitr::opts_knit$set(.knitr_opts_vanilla$knit)
  if(!utf8) {
    exams2html(f[2], name = "blog", dir = ".")
  } else {
    exams2html(f[2], name = "blog", dir = ".", template = "plain8", encoding = "UTF-8")
  }
  knitr::opts_chunk$set(.knitr_opts_custom$chunk)
  knitr::opts_knit$set(.knitr_opts_custom$knit)
  file.rename("blog1.html", f[6])
  include_asset(f[6], engine = "firefox", link = FALSE, out = f[10])
  ##
  ## - PDF
  set.seed(seed)
  ex_pdf <- if(!utf8) {
    exams2pdf(f[1], name = "blog", dir = ".")[[1]][[1]]
  } else {
    exams2pdf(f[1], name = "blog", dir = ".", template = "plain8", encoding = "UTF-8")[[1]][[1]]
  }
  file.rename("blog1.pdf", f[7])
  include_asset(f[7], link = FALSE, out = f[11])
  ##
  set.seed(seed)
  knitr::opts_chunk$set(.knitr_opts_vanilla$chunk)
  knitr::opts_knit$set(.knitr_opts_vanilla$knit)
  if(!utf8) {
    exams2pdf(f[2], name = "blog", dir = ".")
  } else {
    exams2pdf(f[2], name = "blog", dir = ".", template = "plain8", encoding = "UTF-8")
  }
  knitr::opts_chunk$set(.knitr_opts_custom$chunk)
  knitr::opts_knit$set(.knitr_opts_custom$knit)
  file.rename("blog1.pdf", f[8])
  include_asset(f[8], link = FALSE, out = f[12])
  ##
  ## - thumbnail
  system(sprintf(
    "convert -density 100 %s[%s] -strip -background white -flatten -gravity northwest -chop %sx%s -gravity southeast -chop %sx%s -border 2x2 -bordercolor '#666666' -transparent white %s",
    f[7], page - 1, thumb[1], thumb[2], 827 - 300 - thumb[1], 1169 - 200 - thumb[2], f[13]))
  file.copy(f[13], "../../../images/", overwrite = TRUE)

  ## markdown template
  md <- '---
layout: page
#
# Content
#
title: "@name@: @title@"
teaser: "@teaser@"
categories:
  - templates
tags:
@tags@
author: @author@

#
# Style
#
image:
  # preview in list of posts
  thumb: @name@.small.png
---

<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Name:</b></div>
  <div class=\'medium-8 columns\'><code class="highlighter-rouge">@name@</code></div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Type:</b></div>
  <div class=\'medium-8 columns\'><a href="{{ site.url }}/tag/@type@/"><code class="highlighter-rouge">@type@</code></a></div>
</div>
@related@

<div class=\'row t20 b1\'>
  <div class=\'medium-4 columns\'><b>Description:</b></div>
  <div class=\'medium-8 columns\'>@description@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Solution feedback:</b></div>
  <div class=\'medium-8 columns\'>@solution@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Randomization:</b></div>
  <div class=\'medium-8 columns\'>@randomization@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Mathematical notation:</b></div>
  <div class=\'medium-8 columns\'>@math@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Verbatim R input/output:</b></div>
  <div class=\'medium-8 columns\'>@verbatim@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Images:</b></div>
  <div class=\'medium-8 columns\'>@images@</div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Other supplements:</b></div>
  <div class=\'medium-8 columns\'>@supplements@</div>
</div>

<div class=\'row t20 b1\'>
  <div class=\'medium-4 columns\'><b>Template:</b></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@.Rnw">@name@.Rnw</a></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@.Rmd">@name@.Rmd</a></div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>Raw:</b> (1 random version)</div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@.tex">@name@.tex</a></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@.md" >@name@.md</a></div>
</div>
<div class=\'row t1 b1\'>
  <div class=\'medium-4 columns\'><b>PDF:</b></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@-Rnw.pdf"><img src="@assets@/@name@-Rnw-pdf.png" alt="@name@-Rnw-pdf"/></a></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@-Rmd.pdf"><img src="@assets@/@name@-Rmd-pdf.png" alt="@name@-Rmd-pdf"/></a></div>
</div>
<div class=\'row t1 b20\'>
  <div class=\'medium-4 columns\'><b>HTML:</b></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@-Rnw.html"><img src="@assets@/@name@-Rnw-html.png" alt="@name@-Rnw-html"/></a></div>
  <div class=\'medium-4 columns\'><a href="@assets@/@name@-Rmd.html"><img src="@assets@/@name@-Rmd-html.png" alt="@name@-Rmd-html"/></a></div>
</div>

@browsernote@

**Demo code:**

<pre><code class="prettyprint ">library(&quot;exams&quot;)

set.seed(@seed@)
exams2html(&quot;@name@.Rnw&quot;@encoding@)
set.seed(@seed@)
exams2pdf(&quot;@name@.Rnw&quot;@encoding@)

set.seed(@seed@)
exams2html(&quot;@name@.Rmd&quot;@encoding@)
set.seed(@seed@)
exams2pdf(&quot;@name@.Rmd&quot;@encoding@)</code></pre>
'

  ## look up properties of processes exercises
  math <- any(grepl("<math", unlist(ex_html[c("question", "solution")]), fixed = TRUE))
  verbatim <- any(grepl("<pre>", unlist(ex_html[c("question", "solution")]), fixed = TRUE))
  images = any(grepl("includegraphics", unlist(ex_pdf[c("question", "solution")]), fixed = TRUE))
  supplements <- if(supplements == "") {
    if(length(ex_html$supplements) < 1) FALSE else paste(names(ex_html$supplements), collapse = ", ")
  } else {
    paste(supplements, collapse = ", ")
  }

  ## note about MathML support in browsers
  browsernote <- if(!math) "" else "_(Note that the HTML output contains mathematical equations in MathML. It is displayed by browsers with MathML support like Firefox or Safari - but not Chrome.)_"

  ## tags
  tags <- unique(c(ex_pdf$metainfo$type, tags))
  tags <- paste("  -", tags, collapse = "\n")

  ## find&replace placeholders
  at <- list(
    name = name,
    assets = assets,
    title = title,
    teaser = teaser,
    tags = tags,
    type = ex_pdf$metainfo$type,
    author = author,
    related = related,
    description = description,
    randomization = randomization,
    supplements = if(is.logical(supplements)) c("No", "Yes")[1 + supplements] else supplements,
    math = if(is.logical(math)) c("No", "Yes")[1 + math] else math,
    verbatim = if(is.logical(verbatim)) c("No", "Yes")[1 + verbatim] else verbatim,
    images = if(is.logical(images)) c("No", "Yes")[1 + images] else images,
    solution = if(is.null(ex_pdf$solution)) "No" else "Yes",
    browsernote = browsernote,
    seed = as.character(seed),
    encoding = if(!utf8) "" else ", template = \"plain8\", encoding = \"UTF-8\""
  )
  for(a in names(at)) md <- gsub(paste0("@", a, "@"), at[[a]], md, fixed = TRUE)

  return(md)
}

## ## custom match_exams_call() that ignores the include_* functions
## .match_exams_call <- function(which = 1L, deparse = TRUE) {
##   if(getRversion() < "3.2.0") return("")
##   rval <- if(!deparse) exams:::.xexams_call else sapply(exams:::.xexams_call, function(x) deparse(x[[1L]]))
##   rval <- rval[!(substr(rval, 1, 8) == "include_")]
##   if(!is.null(which)) rval <- rval[[which]]
##   rval[rval == "NULL"] <- ""
##   return(rval)
## }
## assignInNamespace("match_exams_call", .match_exams_call, ns = "exams")

