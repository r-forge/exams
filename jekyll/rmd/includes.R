include_rmd <- function(file, ...)
{
  ## store all 'assets' (figures and other supplementary files)
  ## in post-specific sub-directory
  assets <- file.path("..", "..", "assets", "posts", tools::file_path_sans_ext(file))  
  if(!file.exists(assets)) dir.create(assets)

  ## the output .md file should be in _posts/<category>/*.md
  output <- tools::file_path_sans_ext(tools::file_path_as_absolute(file))
  output <- paste(c("..", "..", "_posts", utils::tail(strsplit(output, "/")[[1L]], 2L)), collapse = "/")
  output <- paste0(output, ".md")

  ## default knitr settings (can be queried within .Rmd processing)
  knitr::opts_chunk$set(dev = "svg",
    fig.height = 5, fig.width = 6, dpi = 100, ...,
    fig.path = paste0(assets, "/"), knitr::render_jekyll("prettify"))

  ## process .Rmd
  rval <- knitr::knit(input = file, output = output, quiet = TRUE, encoding = "UTF-8")

  ## if no assets were produced, delete folder
  if(length(list.files(assets)) < 1L) unlink(assets)

  ## fix-up relative links using {{ site.url }} syntax
  md <- readLines(output, encoding = "UTF-8")
  md <- gsub("../../assets", "{{ site.url }}/assets", md, fixed = TRUE)
  writeLines(md, output)
  
  invisible(rval)
}

include_asset <- function(file, asset = TRUE, screenshot = TRUE, link = TRUE, density = 25, aspect43 = TRUE, border = TRUE)
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
    file_s <- do.call(paste("include", ext, "screenshot", sep = "_"),
      list(file = file, density = density, aspect43 = aspect43, border = border))
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

  ## make all screenshots with ImageMagick's 'convert'
  for(i in seq_along(file)) {
    cmd <- sprintf("convert -density %s -extent %sx%s %s %s[%s] %s",
      density, round(density * 8.268), ceiling(density * if(aspect43) 8.268 * 0.75 else 11.693),
      if(border) sprintf("-border %sx%s -bordercolor '#666666'", ceiling(density/15), ceiling(density/15)) else "",
      file[i], page - 1, out[i])
    system(cmd)
  }
  
  ## return paths of screenshots invisibly
  invisible(out)
}

include_html_screenshot <- function(file, out = NULL, density = 25, aspect43 = TRUE, border = TRUE)
{
  ## screenshot .png path
  if(is.null(out)) out <- paste0(tools::file_path_sans_ext(basename(file)), ".png")
  if(knitr::opts_chunk$get("fig.path") != "figure/") out <- paste0(knitr::opts_chunk$get("fig.path"), out)

  ## make all screenshots with 'cutycapt' (available via 'apt-get install cutycapt')
  ## and resize/crop with ImageMagick's 'mogrify'
  for(i in seq_along(file)) {
    cmd <- sprintf("cutycapt --url=file://%s --out=%s",
      tools::file_path_as_absolute(file[i]),
      out[i])
    system(cmd)
    cmd <- sprintf("mogrify -resize %s %s %s %s",
      density * 8.268,
      if(aspect43) sprintf("-extent %sx%s", ceiling(density * 8.268), ceiling(density * 8.268 * 0.75)) else "",
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
