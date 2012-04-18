## NOTE: needs pdflatex and ImageMagick url: http://www.imagemagick.org/
tex2image <- function(tex, format = "png", width = 6, 
  pt = 12, density = 350, edir = NULL, tdir = NULL, idir = NULL,
  width.border = 0L, col.border = "white", resize = 1300, shave = 4,
  template = c("\\usepackage{sfmath}",
    "\\renewcommand{\\sfdefault}{phv}",
    "\\IfFileExists{sfmath.sty}{\n\\RequirePackage{sfmath}\n\\renewcommand{\\rmdefault}{phv}}{}"),
  itemplate = NULL, show = TRUE, bsname = "tex2image-Rinternal")
{
  if((length(text) < 2L) && file.exists(tex)) {
    texfile <- file_path_as_absolute(tex)
    tex <- readLines(con = texfile)
    texdir <- dirname(texfile)
    texfile <- paste("tex2image-", basename(texfile), sep = "")
    bsname <- file_path_sans_ext(texfile)
  } else
    texdir <- tempdir()
  if(is.null(edir))
    edir <- texdir
  there <- FALSE
  if(is.null(tdir)) {
    tdir <- tempfile()
    there <- TRUE
  }
  tdir <- file.path(path.expand(tdir), "tex2image")
  dir.create(tdir, recursive = TRUE, showWarnings = FALSE)
  if(there)
    on.exit(unlink(tdir))
  owd <- getwd()
  setwd(tdir)
  if(length(graphics <- grep("includegraphics", tex, fixed = TRUE, value = TRUE))) {
    if(is.null(idir))
      idir <- texdir
    idir <- path.expand(idir)
    files <- list.files(idir)
    for(k in 1L:length(graphics)) {
      g <- strsplit(graphics[k], "")[[1L]]
      take <- NULL
      do <- TRUE
      i <- length(g) - 1L
      while(do) {
        if(g[i] == "{")
          do <- FALSE
        else
          take <- c(take, g[i])
        i <- i - 1L
      }
      graphics[k] <- paste(take[length(take):1L], sep = "", collapse = "")
    }
    cp <- grep(graphics, files, fixed = TRUE, value = TRUE)
    if(length(cp)) {
      for(f in cp) 
        file.copy(from = file.path(idir, f), to = file.path(tdir, f), overwrite = TRUE)
    } else stop(paste("graphic is missing in ", texdir, "!", sep = ""))
  }
  texlines <- paste("\\documentclass[", pt, "pt]{article}", sep = "")
  texlines <- c(
    texlines,
    "\\usepackage[ngerman]{babel}", ## FIXME: modularize usepackages
    "\\usepackage{a4wide, Sweave, verbatim}",
    "\\usepackage[latin1]{inputenc}",
    "\\usepackage[T1]{fontenc}",
    "\\usepackage{amsmath,amssymb,amsfonts}",
    "\\usepackage{graphicx}",
    "\\usepackage{fancybox}",
    "\\usepackage{slashbox, booktabs}",
    "\\usepackage{array}",
    "\\usepackage{hyperref}",
    "\\usepackage{color}",
    "\\pagestyle{empty}"
  )
  for(i in template)
    texlines <- c(texlines, i)
  texlines <- c(texlines, paste("\\setlength{\\textwidth}{", width, "in}", sep = ""))
  texlines <- c(texlines, "\\begin{document}")
  for(i in itemplate)
    texlines <- c(texlines, i)
  if(!any(grepl("begin{figure}", tex, fixed = TRUE)) &&
     !any(grepl("caption{", tex, fixed = TRUE))) {
    texlines <- c(texlines, paste("\\frame{\\parbox[t]{", width, "in}{", sep = ""))
    texlines <- c(texlines, "\\vspace*{0.1cm}")
  }
  texlines <- c(texlines, tex)
  if(!any(grepl("begin{figure}", tex, fixed = TRUE)) &&
     !any(grepl("caption{", tex, fixed = TRUE))) {
    texlines <- c(texlines, "\\vspace*{0.1cm}}}")
  }
  texlines <- c(texlines, "\\end{document}")
  file.create(paste(tdir, "/", bsname, ".log", sep = ""))
  image <- paste(bsname, ".", format, sep = "")
  writeLines(text = texlines, con = paste(tdir, "/", bsname, ".tex", sep = ""))
  texi2dvi(file = paste(bsname, ".tex", sep = ""), pdf = TRUE, clean = TRUE, quiet = TRUE)
  if(format == "png") {
    cmd <- paste("convert -trim -shave ", shave, "x", shave," -density ", density, " ",
      bsname, ".pdf -transparent white ", image, " > ", bsname, ".log", sep = "")
  } else {
    cmd <- paste("convert -trim -shave ", shave, "x", shave," -density ", density, " ",
      bsname, ".pdf ", image, " > ", bsname, ".log", sep = "")
  }
  system(cmd)
  if(!is.null(resize)) {
    cmd <- paste("convert -resize ", resize, "x ", image, " ", image, " > ", bsname, ".log", sep = "")
    system(cmd)
  } else resize <- 800
  width.border <- as.integer(width.border)
  if(width.border > 0L) {
    width.border <- paste(width.border, "x", width.border, sep = "")
    system(paste("convert ", image, " -bordercolor ", col.border, " -border ", width.border, " ",
      image, " > ", bsname, ".log", sep = ""))
  }
  dirout <- file.path(path.expand(edir), image)
  file.copy(from = file.path(tdir, image), 
    to = dirout, overwrite = TRUE)
  if(show) {
    if(.Platform$OS.type == "windows") 
      shell.exec(dirout)
    else {
      resize <- as.integer(resize)
      resize <- paste(resize, "x", resize, sep = "")
      try(system(paste("display -resize ", resize, " -auto-orient ",  
        dirout, sep = ""), wait = FALSE))
    } 
  }
  setwd(owd)
  
  return(invisible(dirout))
}
