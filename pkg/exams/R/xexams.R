xexams <- function(file, n = 1L, nsamp = NULL,
  driver = list(sweave = NULL, read = NULL, transform = NULL, write = NULL),
  dir = ".", edir = NULL, tdir = NULL, sdir = NULL, verbose = FALSE,
  points = NULL, seed = NULL, rds = FALSE, ...)
{
  if(verbose) cat("Exams generation initialized.\n\n")

  ## process driver
  if(is.null(driver$sweave)) {
    driver$sweave <- xweave
  } else if(is.list(driver$sweave)) {
    driver_sweave_args <- driver$sweave
    driver$sweave <- function(f) do.call("xweave", c(list(file = f), driver_sweave_args))
  }
  if(is.null(driver$read)) {
    driver$read <- read_exercise
  } else if(is.list(driver$read)) {
    driver_read_args <- driver$read
    driver$read <- function(f) do.call("read_exercise", c(list(file = f), driver_read_args))
  }
  stopifnot(is.function(driver$sweave), is.function(driver$read),
    is.null(driver$transform) || is.function(driver$transform),
    is.null(driver$write) || is.function(driver$write))

  ## manage directories: 
  ##   - for producing several files an output directory is required
  if(is.null(dir) & !is.null(driver$write)) stop("Please specify an output 'dir'.")
  if(!is.null(dir) && !file.exists(dir) && !dir.create(dir))
    stop(gettextf("Cannot create output directory '%s'.", dir))
  ##   - further: dir (output), dir_orig (original), dir_temp (temp), dir_pkg (package), dir_supp (supplements)
  if(!is.null(dir)) dir <- file_path_as_absolute(dir)
  dir_orig <- getwd()
  on.exit(setwd(dir_orig))
  dir_temp <- if(is.null(tdir)) tempfile() else file_path_as_absolute(tdir)
  if(!file.exists(dir_temp) && !dir.create(dir_temp))
    stop(gettextf("Cannot create temporary work directory '%s'.", dir_temp))
  dir_pkg <- find.package("exams")
  dir_supp <- if(is.null(sdir)) tempfile() else sdir
  if(!file.exists(dir_supp) && !dir.create(dir_supp))
    stop(gettextf("Cannot create temporary work directory '%s'.", dir_supp))
  dir_supp <- file_path_as_absolute(dir_supp)
  dir_exrc <- if(is.null(edir)) getwd() else file_path_as_absolute(edir)
  if(!file.exists(dir_exrc))
    stop(gettextf("Exercise directory does not exist: '%s'.", dir_exrc))  
  if(verbose) {
    cat(sprintf("Output directory: %s\n", dir))
    cat(sprintf("Exercise directory: %s\n", dir_exrc))
    cat(sprintf("Supplement directory: %s\n", dir_supp))
    cat(sprintf("Temporary directory: %s\n", dir_temp))
  }
  if(dir_temp == dir) stop("Temporary directory 'tdir' must not be the same as the output directory 'dir'.")
  if(dir_temp == dir_exrc) stop("Temporary directory 'tdir' must not be the same as the exercise directory 'edir'.")

  ## for access in helper functions:
  ## create global variable storing file paths
  .exams_set_internal(
    xexams_dir_output = dir,
    xexams_dir_exercises = dir_exrc,
    xexams_dir_supplements = dir_supp,
    xexams_dir_temporary = dir_temp
  )
  ## create global variable storing (x)exams(2xyz) calls
  if(getRversion() >= "3.2.0") {
    cl <- 0L:sys.parent()
    for(i in seq_along(cl)) cl[[i]] <- sys.parent(cl[[i]])
    cl <- rev(cl[cl > 0L])
    .exams_set_internal(
      xexams_call = lapply(cl, function(i) {
        cl_i <- try(match.call(definition = sys.function(i), call = sys.call(i)), silent = TRUE)
        if(inherits(cl_i, "try-error")) sys.call(i) else cl_i
      })
    )
  }

  ## handle matrix specification of 'file' and transform to list specification:
  ##   - file = list with one vector of all exercises
  ##   - n and nsamp = number of rows and columns, repectively
  ##   - file_id = simply remember fixed exercise selection instead of random sampling
  ##   - expand random seed matrix suitably
  if(is.matrix(file)) {
    if(!missing(n) && !is.null(n) && n != nrow(file)) warning("'n' must not differ from number of rows of 'file'")
    if(!missing(nsamp) && !is.null(nsamp) && nsamp != ncol(file)) warning("'nsamp' must not differ from number of rows of 'file'")
    n <- nrow(file)
    nsamp <- ncol(file)
    file_id <- file
    file <- list(unique(as.vector(t(file))))
    file_id <- structure(match(file_id, file[[1L]]), .Dim = dim(file_id))

    if(!is.null(seed)) {
      if(is.matrix(seed) && all(dim(seed) == c(n, nsamp))) {
        seed_i <- as.integer(seed)
        seed <- matrix(NA_integer_, nrow = n, ncol = length(file[[1L]]))
        seed[cbind(rep(1L:n, nsamp), c(file_id))] <- seed_i
      } else {
        warning(sprintf("'seed' is not a %s x %s matrix and hence ignored", n, nsamp))
        seed <- NULL
      }
    }
  } else {
    file_id <- NULL
  }

  ## number of available exercises in each element of 'file'
  ## and number of selected samples per element
  nfile <- length(file)
  if(is.null(nsamp)) nsamp <- 1L
  if(length(nsamp) < nfile) nsamp <- rep(nsamp, length.out = nfile)
  navail <- sapply(file, length)  
  if(any(navail < nsamp)) {
    ix <- which(navail < nsamp)
    warning(paste("Only", navail[ix], "exercise(s) available in element", ix,
      "of the 'file' argument. Sampling with replacement will be used in order to obtain",
      nsamp[ix], "replications."))
  }

  ## file pre-processing:
  ##   - transform to vector (remember grouping IDs)
  ##   - add paths (generate "foo", "foo.Rnw", "foo.tex", and "path/to/foo.Rnw")
  ##   - check existence (use local files if they exist, otherwise take from package)
  ##   - setup sampling (draw random configuration)
  if(is.null(file_id)) file_id <- rep.int(seq_along(file), navail)
  file_raw <- unlist(file)
  file_sfx <- tolower(substr(file_raw, nchar(file_raw) - 3L, nchar(file_raw)))
  file_Rnw <- ifelse(file_sfx %in% c(".rnw", ".rmd"), file_raw, 
    ## FIXME: default suffix guessing is really ugly -> rethink this
    paste(file_raw, ifelse(file_sfx == ".qmd" | substr(file_sfx, 2L, 4L) == ".md", ".Rmd", ".Rnw"), sep = ""))
  file_base <- file_path_sans_ext(file_Rnw)
  file_ext0 <- file_ext(file_Rnw)
  file_ext <- tolower(file_ext0)
  file_ext <- gsub("r", "", file_ext, fixed = TRUE)
  file_ext[file_ext == "nw"] <- "tex"
  file_path <- search_files(file_Rnw, dir_exrc, recursive = !is.null(edir))
  file_path <- ifelse(is.na(file_path) & file.exists(file_raw), file_raw, file_path)
  file_path <- ifelse(!is.na(file_path), file_path, file.path(dir_pkg, "exercises", file_Rnw))
  if(!all(file.exists(file_path))) stop(paste("The following files cannot be found: ",
    paste(file_raw[!file.exists(file_path)], collapse = ", "), ".", sep = ""))
  if(verbose) {
    cat(sprintf("Exercises: %s\n", paste(file_base, collapse = ", ")))
  }

  ## substitute (back)slashes, colons, and tildes by underscores
  ## in temporary file names to allow handling of relative file paths
  ## (in addition to edir argument)
  file_base <- sub("^(\\./|\\.\\./)+", "", file_base)
  file_base <- gsub("(/|~|\\\\|\\:)+", "_", file_base)

  ## assure uniqueness of temporary file names
  file_base <- make.unique(file_base, sep = "_")

  ## put together temporary file names
  file_Rnw <- paste(file_base, file_ext0, sep = ".")
  file_tex <- paste(file_base, file_ext,  sep = ".")

  ## take everything to temp dir
  file.copy(file_path, file.path(dir_temp, file_Rnw))
  setwd(dir_temp)
  ## could try to delete the temporary directory but not if user-specified, commented for now
  ## on.exit(unlink(dir_temp), add = TRUE)

  ## convenience function for sampling ids
  sample_id <- function(row = NULL) {
    if(!is.null(row) && is.matrix(file_id)) return(file_id[row, ])
    unlist(lapply(unique(file_id), function(i) {
      wi <- file_id == i
      if(sum(wi) > 1L)
        sample(which(wi), nsamp[i], replace = navail[i] < nsamp[i])
      else
        rep(which(wi), length.out = nsamp[i])
    }))
  }

  ## set up list of exams (length n) with list of exercises (length m = sum(nsamp))
  m <- sum(nsamp)
  exm <- rep(list(vector(mode = "list", length = m)), n)
  names(exm) <- paste("exam", formatC(1L:n, width = floor(log10(n)) + 1L, flag = "0"), sep = "")

  ## if global points are specified recycle to the correct length
  if(!is.null(points)) {
    if(length(points) == 1L) points <- rep.int(points, m)
    if(length(points) != m) {
      points <- NULL
      warning(sprintf("'points' was ignored because it is not of length 1 or %s", m))
    }
  }

  ## assure seed (if any) is an n x mm matrix
  mm <- length(file_raw)
  if(identical(seed, FALSE)) seed <- NULL
  if(identical(seed, TRUE)) seed <- matrix(sample(0L:(n * mm * 1000L), n * mm), nrow = n, ncol = mm)
  if(!is.null(seed)) {
    if(length(seed) != n * mm) {
      stop(sprintf("seed should be a %s x %s matrix", n, mm))
    } else {
      if(!is.null(dim(seed)) && any(dim(seed) != c(n, mm))) {
        warning(sprintf("seed has the wrong dimension, should be a %s x %s matrix", n, mm))
      }
      dim(seed) <- c(n, mm)
    }
    ## initialize random seed if necessary
    if(!exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) runif(1L)
  }

  ## cycle through exams: call Sweave, read LaTeX, store supplementary files
  if(verbose) cat("\nGeneration of individual exams.")
  for(i in 1L:n) {

    if(verbose) cat(paste("\nExam ", format(c(i, n))[1L], ":", sep = ""))
    .exams_set_internal(xexams_iteration = i)

    ## sub-directory for supplementary files
    dir_supp_i <- file.path(dir_supp, names(exm)[i])
    if(!file.exists(dir_supp_i) && !dir.create(dir_supp_i)) stop("could not create directory for supplementary files")

    ## select exercise files
    id <- sample_id(i)
    stopifnot(length(id) == m)
    names(exm[[i]]) <- paste("exercise", formatC(1L:m, width = floor(log10(m)) + 1L, flag = "0"), sep = "")

    ## select corresponding seeds (if any)
    seed_i <- if(is.null(seed)) NULL else seed[i, id]

    ## cycle through exercises within exam
    for(j in 1L:m) {

      ## id of exercise within full list of files
      idj <- id[j]
      if(verbose) cat(paste(" ", file_base[idj], " (", sep = ""))

      ## sub-directory for supplementary files
      dir_supp_ij <- file.path(dir_supp_i, names(exm[[i]])[j])
      if(!file.exists(dir_supp_ij) && !dir.create(dir_supp_ij)) stop("could not create directory for supplementary files")

      ## driver: sweave (with fixing and restoring seeds, if any)
      if(verbose) cat("s")
      if(!is.null(seed_i)) {
        .rseed <- get(".Random.seed", envir = .GlobalEnv)
        set.seed(seed_i[j])
      }
      driver$sweave(file_Rnw[idj])
      if(!is.null(seed_i)) {
        assign(".Random.seed", .rseed, envir = .GlobalEnv)
      }

      ## driver: read LaTeX file
      if(verbose) cat("r")
      if(!is.null(seed_i)) {
        .rseed <- get(".Random.seed", envir = .GlobalEnv)
        set.seed(seed_i[j])
      }
      exm[[i]][[j]] <- driver$read(file_tex[idj])
      if(!is.null(seed_i)) {
        assign(".Random.seed", .rseed, envir = .GlobalEnv)
      }

      ## infer and save supplements
      sfile <- dir(pattern = "[.]")
      sfile <- sfile[!(sfile %in% c(file_tex, file_Rnw))]
      if(length(sfile) > 0L) {
        file.copy(sfile, dir_supp_ij)
        file.remove(sfile)
      }
      exm[[i]][[j]]$supplements <- structure(file.path(dir_supp_ij, sfile), names = sfile, dir = dir_supp_ij)

      ## add points globally (if specified)
      if(!is.null(points)) exm[[i]][[j]]$metainfo$points <- points[j]

      ## add seed (if specified)
      if(!is.null(seed_i)) exm[[i]][[j]]$metainfo$seed <- seed_i[j]

      ## driver: transform exercise (e.g., LaTeX -> HTML)
      if(verbose) cat("t")
      if(!is.null(driver$transform)) exm[[i]][[j]] <- driver$transform(exm[[i]][[j]])
      if(verbose) cat(")")
    }

    ## driver: write output for each exam
    if(verbose) cat(" ... w")
    if(!is.null(driver$write)) driver$write(exm[[i]], dir = dir, info = list(id = i, n = n)) ## FIXME: do we need further information?
    if(verbose) cat(" ... done.")
  }
  if(verbose) cat("\n")
  .exams_set_internal(xexams_iteration = NULL)

  ## optionally save return list as rds file
  if(!identical(rds, FALSE)) {
    if(isTRUE(rds)) rds <- "metainfo"
    if(!is.character(rds)) {
      warning("'rds' must be logical or a character file name")
      rds <- "metainfo"
    }
    if(file_ext(rds) == "") rds <- paste0(rds, ".rds")
    saveRDS(exm, file = file.path(dir, rds))
  }

  invisible(exm)
}

xweave <- function(file, quiet = TRUE, encoding = "UTF-8", engine = NULL,
  envir = new.env(), pdf = TRUE, png = FALSE, svg = FALSE, height = 6, width = 6,
  resolution = 100, highlight = FALSE, ...)
{
  ## encoding always assumed to be UTF-8 starting from R/exams 2.4-0
  if(!is.null(encoding) && !(tolower(encoding) %in% c("", "utf-8", "utf8"))) {
    warning("the only supported 'encoding' is UTF-8")
  }
  encoding <- "UTF-8"

  ## process file extension, rendering engine, and graphics device
  ext <- tolower(file_ext(file))
  if(is.null(engine)) {
    engine <- if(ext == "rnw") "sweave" else "knitr"
  }
  engine <- match.arg(tolower(engine), c("sweave", "knitr"))
  if(engine == "sweave" & ext != "rnw") {
    engine <- "knitr"
    warning("Sweave() can only be applied to .Rnw exercises")
  }
  dev <- if(pdf & !png) {
    "pdf"
  } else if(svg & !png) {
    "svg"
  } else {
    "png"
  }
  .exams_set_internal(xweave_device = dev)
  if(is.null(envir)) envir <- new.env()

  if(ext == "rnw") {
    if(engine == "sweave") {
      if(is.null(encoding)) encoding <- ""
      if(dev != "svg") {
        utils::Sweave(file, encoding = encoding, quiet = quiet, pdf = pdf, png = png,
          height = height, width = width, resolution = resolution, ...)
      } else {
        svg_grdevice <- "exams:::.xweave_svg_grdevice" ## requires R >= 3.4.0
        utils::Sweave(file, encoding = encoding, quiet = quiet, grdevice = svg_grdevice,
          height = height, width = width, ...)
      }
      if(png | svg) {
        ## add .png or .svg suffix in case of \includegraphics{} without suffix
        file <- paste0(file_path_sans_ext(file), ".tex")
        tex <- readLines(file)
        ix <- grepl("includegraphics{", tex, fixed = TRUE)
        if(any(ix)) {
          tex[ix] <- gsub("(includegraphics\\{[[:graph:]]+\\})", if(png) "\\1.png" else "\\1.svg", tex[ix])
          tex[ix] <- sapply(strsplit(tex[ix], if(png) "}.png" else "}.svg", fixed = TRUE), function(z) {
            sfix <- ifelse(substr(z, nchar(z) - 3L, nchar(z) - 3L) == ".", "}", if(png) ".png}" else ".svg}")
            if(!grepl("includegraphics{", z[length(z)], fixed = TRUE)) sfix[length(z)] <- ""
            paste(z, sfix, sep = "", collapse = "")
          })
        }
        writeLines(tex, file)
      }
    } else {
      oopts <- knitr::opts_chunk$get()
      knitr::opts_chunk$set(dev = dev,
        fig.height = height, fig.width = width, dpi = resolution, ...,
        fig.path = "", error = FALSE, warning = NA)
      if(!highlight) knitr::render_sweave()
      if(is.null(encoding)) encoding <- getOption("encoding")
      knitr::knit(file, quiet = quiet, envir = envir, encoding = encoding)
      knitr::opts_chunk$set(oopts)    
    }
  } else {
    ## FIXME: recent versions of pandoc do not convert ```text to {verbatim} anymore
    ## hence use highlight=TRUE,lang="" instead of highlight=FALSE for now
    knitr::opts_hooks$set(highlight = function(options) {
      if(!options$highlight) {
        options$highlight <- TRUE
        options$lang <- ""
      }
      options
    })
    oopts <- knitr::opts_chunk$get()
    knitr::opts_chunk$set(dev = dev,
      fig.height = height, fig.width = width, dpi = resolution, fig.path = "",
      error = FALSE, warning = NA, highlight = highlight, ...)
    if(is.null(encoding)) encoding <- getOption("encoding")
    knitr::knit(file, quiet = quiet, envir = envir, encoding = encoding)
    knitr::opts_chunk$set(oopts)
  }
}


.xweave_svg_grdevice <- function(name, width, height, ...) {
  svg(filename = paste(name, "svg", sep = "."), width = width, height = height)
}


## manage internal options, e.g., for passing them to individual exercises
## (which is more difficult to do using regular arguments) and/or control
## application of certain fixups

.exams_internal <- new.env()

.exams_get_internal <- function(x = NULL) {
  if(is.null(x)) return(as.list(.exams_internal))

  x <- as.character(x)[1L]
  return(.exams_internal[[x]])
}

.exams_set_internal <- function(...) {
  dots <- list(...)
  if(is.null(names(dots))) {
    stop("arguments must be named")
  } else if(any(names(dots) == "")) {
    warning("ignoring unnamed arguments")
    dots <- dots[names != ""]
  }
  if(length(dots) > 0L) {
    for(i in names(dots)) {
      .exams_internal[[i]] <- dots[[i]]
    }
  }
  invisible(NULL)
}

.exams_set_internal(
  ## directories used by xexams()
  xexams_dir_output        = NULL,
  xexams_dir_exercises     = NULL,
  xexams_dir_supplements   = NULL,
  xexams_dir_temporary     = NULL,

  ## call/traceback of functions called
  xexams_call              = list(call = NULL, traceback = NULL),

  ## iteration within n replications
  xexams_iteration         = NULL,

  ## default graphics device used in xweave() (png, pdf, svg)
  xweave_device            = "png",

  ## post-process MathJax output from pandoc (for OpenOlat or Blackboard)
  pandoc_mathjax_fixup     = FALSE,

  ## post-process <table> class from pandoc (for OpenOlat or Moodle)
  pandoc_table_class_fixup = FALSE,

  ## restore random seed after single test version of exam
  nops_restore_seed        = TRUE
)
