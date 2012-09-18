## NOTE: needs commands "convert" and optionally "display" from
## ImageMagick (http://www.imagemagick.org/)
## In addition, if tex input is a list(), needs pdftk for splitting .pdf files
tex2image <- function(tex, format = "png", width = 6, 
  pt = 12, density = 350, edir = NULL, tdir = NULL, idir = NULL,
  width.border = 0L, col.border = "white", resize = 650, shave = 4,
  packages = c("a4wide", "sfmath", "verbatim", "amsmath", "amssymb", "amsfonts", "graphicx",
    "fancybox", "slashbox", "booktabs", "array", "hyperref", "color", "fancyvrb"),
  template = c("\\renewcommand{\\sfdefault}{phv}",
    "\\IfFileExists{sfmath.sty}{\n\\RequirePackage{sfmath}\n\\renewcommand{\\rmdefault}{phv}}{}"),
  itemplate = NULL, show = TRUE, bsname = "tex2image-Rinternal", ...)
{
  there <- FALSE
  if(is.null(tdir)) {
    tdir <- tempfile()
    there <- TRUE
  }
  tdir <- file.path(path.expand(tdir), "tex2image")
  dir.create(tdir, recursive = TRUE, showWarnings = FALSE)
  if(there)
    on.exit(unlink(tdir))

  if(!is.list(tex) && (length(text) < 2L) && file.exists(tex)) {
    texfile <- file_path_as_absolute(tex)
    tex <- readLines(con = texfile)
    texdir <- dirname(texfile)
    cfiles <- list.files(texdir)
    cfiles <- cfiles[cfiles != "tex2image"]
    cfiles <- cfiles[cfiles != basename(texfile)]
    if(length(pdfs <- grep("pdf", file_ext(cfiles))))
      cfiles <- cfiles[-pdfs]
    file.copy(file.path(texdir, cfiles), file.path(tdir, cfiles))
    texfile <- paste("tex2image-", basename(texfile), sep = "")
    bsname <- file_path_sans_ext(texfile)
  } else texdir <- tempdir()

  if(any(grepl("\\documentclass", tex, fixed = TRUE))) {
    begin <- grep("\\begin{document}", tex, fixed = TRUE)
    end <- grep("\\end{document}", tex, fixed = TRUE)
    tex <- tex[(begin + 1):(end - 1)]
  }

  if(is.null(edir))
    edir <- texdir

  owd <- getwd()
  setwd(tdir)
  if(length(graphics <- grep("includegraphics", unlist(tex), fixed = TRUE, value = TRUE))) {
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
  for(i in packages) {
    brackets <- if(grepl("{", i, fixed = TRUE)) NULL else c("{", "}")
    texlines <- c(texlines, paste("\\usepackage", brackets[1], i, brackets[2], sep = ""))
  }
  texlines <- c(
    texlines,
    "\\pagestyle{empty}",
    "\\setlength{\\parindent}{0pt}",
    "\\newenvironment{question}{\\item \\textbf{Problem}\\newline}{}",
    "\\newenvironment{solution}{\\textbf{Solution}\\newline}{}",
    "\\newenvironment{answerlist}{\\renewcommand{\\labelenumi}{(\\alph{enumi})}\\begin{enumerate}}{\\end{enumerate}}",
    "\\newenvironment{Schunk}{\\fontsize{9}{10}\\selectfont}{}",
    "\\newenvironment{Scode}{\\verbatim}{\\endverbatim}",
    "\\newenvironment{Sinput}{\\verbatim}{\\endverbatim}",
    "\\newenvironment{Soutput}{\\verbatim}{\\endverbatim}"
  )
  for(i in template)
    texlines <- c(texlines, i)
  texlines <- c(texlines, paste("\\setlength{\\textwidth}{", width, "in}", sep = ""))
  texlines <- c(texlines, "\\begin{document}")
  for(i in itemplate)
    texlines <- c(texlines, i)
  tex <- if(!is.list(tex)) list(tex) else tex
  pic_names <- if(is.null(names(tex))) {
    paste(bsname, "pic", 1:length(tex), sep = "_")
  } else paste(bsname, names(tex), sep = "_")
  pic_names <- paste(pic_names, format, sep = ".")
  nt <- length(tex)
  for(i in 1:nt) {
    if(!any(grepl("begin{figure}", tex[[i]], fixed = TRUE)) &&
      !any(grepl("caption{", tex[[i]], fixed = TRUE))) {
      texlines <- c(texlines, paste("\\frame{\\parbox[t]{", width, "in}{", sep = ""))
      texlines <- c(texlines, "\\vspace*{0.1cm}")
    }
    texlines <- c(texlines, tex[[i]])
    if(!any(grepl("begin{figure}", tex[[i]], fixed = TRUE)) &&
      !any(grepl("caption{", tex[[i]], fixed = TRUE))) {
      texlines <- c(texlines, "\\vspace*{0.1cm}}}")
    }
    if(nt > 1)
      texlines <- c(texlines, "\\newpage")
  }
  texlines <- c(texlines, "\\end{document}")
  file.create(paste(tdir, "/", bsname, ".log", sep = ""))
  writeLines(text = texlines, con = paste(tdir, "/", bsname, ".tex", sep = ""))
  texi2dvi(file = paste(bsname, ".tex", sep = ""), pdf = TRUE, clean = TRUE, quiet = TRUE)
  if(nt > 1) {
    system(paste("pdftk", paste(bsname, "pdf", sep = "."), "burst output",
      paste(bsname, "pic", "%02d.pdf", sep = "_")))
    bsname <- grep(paste(bsname, "pic", sep = "_"), list.files(tdir), fixed = TRUE, value = TRUE)
    bsname <- file_path_sans_ext(bsname)
  }
  image <- paste(bsname, ".", format, sep = "")
  dirout <- rep(NA, length(bsname))
  for(i in seq_along(bsname)) {
    if(format == "png") {
      cmd <- paste("convert -trim -shave ", shave, "x", shave," -density ", density, " ",
        bsname[i], ".pdf -transparent white ", image[i], " > ", bsname[i], ".log", sep = "")
    } else {
      cmd <- paste("convert -trim -shave ", shave, "x", shave," -density ", density, " ",
        bsname[i], ".pdf ", image[i], " > ", bsname[i], ".log", sep = "")
    }
    system(cmd)
    if(!is.null(resize)) {
      cmd <- paste("convert -resize ", resize, "x ", image[i], " ", image[i], " > ", bsname[i], ".log", sep = "")
      system(cmd)
    } else resize <- 800
    width.border <- as.integer(width.border)
    if(width.border > 0L) {
      width.border <- paste(width.border, "x", width.border, sep = "")
      system(paste("convert ", image[i], " -bordercolor ", col.border, " -border ", width.border, " ",
        image[i], " > ", bsname[i], ".log", sep = ""))
    }
    dirout[i] <- file.path(path.expand(edir), pic_names[i])
    file.copy(from = file.path(tdir, image[i]), 
      to = dirout[i], overwrite = TRUE)
    if(show) {
      if(.Platform$OS.type == "windows") 
        shell.exec(dirout[i])
      else {
        resize <- as.integer(resize)
        resize <- paste(resize, "x", resize, sep = "")
        try(system(paste("display -resize ", resize, " -auto-orient ",  
          dirout[i], sep = ""), wait = FALSE))
      } 
    }
  }
  setwd(owd)
  
  return(invisible(dirout))
}
