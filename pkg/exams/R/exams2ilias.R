exams2ilias <- function(file, n = 1L, nsamp = NULL, dir = ".",
  name = NULL, quiet = TRUE, edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  resolution = 100, width = 4, height = 4, svg = FALSE, encoding  = "",
  num = list(fix_num = FALSE, minvalue = NA),
  mchoice = list(maxchars = c(3, NA, 3), minvalue = NA),
  schoice = mchoice, string = NULL, cloze = NULL,
  template = "ilias",
  duration = NULL, stitle = "Exercise", ititle = "Question",
  adescription = "Please solve the following exercises.",
  sdescription = "Please answer the following question.", 
  maxattempts = 1, cutvalue = 0, solutionswitch = TRUE, zip = FALSE,
  points = NULL, eval = list(partial = TRUE, negative = FALSE),
  converter = "pandoc-mathjax", ...)
{
  ## assure a certain processing of items for Ilias
  if(is.null(num)) {
    num <- list(fix_num = FALSE, minvalue = NA)
  } else {
    num$fix_num <- FALSE
    num$minvalue <- NA
  }
  if(is.null(mchoice)) {
    mchoice <- list(maxchars = c(3, NA, 3), minvalue = NA)
  } else {
    mchoice$maxchars <- c(3, NA, 3)
    mchoice$minvalue <- NA
  }
  if(is.null(schoice)) {
    schoice <- list(maxchars = c(3, NA, 3), minvalue = NA)  
  } else {
    schoice$maxchars <- c(3, NA, 3)
    schoice$minvalue <- NA
  }
  
  ## FIXME: default name ilias?
  ## FIXME: default maxchars?
  ## FIXME: allow xmlcollapse = FALSE for testing?
  

  ## simply call exams2qti12 with custom template (and XML processing)
  exams2qti12(file = file, n = n, nsamp = nsamp, dir = dir,
    name = name, quiet = quiet, edir = edir, tdir = tdir, sdir = sdir, verbose = verbose,
    resolution = resolution, width = width, height = height, svg = svg, encoding  = encoding,
    num = num, mchoice = mchoice, schoice = schoice, string = string, cloze = cloze,
    template = template,
    duration = duration, stitle = stitle, ititle = ititle,
    adescription = adescription, sdescription = sdescription, 
    maxattempts = maxattempts, cutvalue = cutvalue, solutionswitch = solutionswitch, zip = zip,
    points = points, eval = eval, converter = converter, xmlcollapse = TRUE, ...)
}
