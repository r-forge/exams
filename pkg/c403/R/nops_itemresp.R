#' Extract Item-Response Data from NOPS Exams
#' 
#' Process data from NOPS evaluation results (via \code{\link[c403]{nops_eval}})
#' for subsequent IRT (item response theory) modeling.
#' 
#' \code{nops_itemresp} returns a data frame with several item response
#' outcomes for each student: \code{solved} indicates whether or not an
#' exercise was fully solved, \code{partial} whether or not it was at least
#' partially solved.  \code{points} gives the points achieved for each
#' exercise. The corresponding \code{nsolved}, \code{npartial}, and
#' \code{npoints} are the sums of these for each student. Moreover,
#' \code{solved2}, \code{partial2}, and \code{points2} distinguish not only the
#' exercises within the exam but also the actual source template within each
#' exercise.
#' 
#' @param eval character. File name of CSV output from \code{nops_eval}.
#' @param exam character. File name of RDS output from \code{exams2nops}.
#' @param psychotools logical. Should \code{itemresp} from \pkg{psychotools} be
#' used as the class for item response columns? By default, this is used if the
#' \pkg{psychotools} package is available. If \code{FALSE}, matrices with dummy
#' codings are used.
#' @param labels function for extracting exercise labels from each
#' \code{$metainfo}.  By default the original file name \code{$metainfo$file}
#' is used.
#' @param \dots additional arguments (such as \code{colClasses}) passed to
#' \code{read.csv2(eval, dec = ".", ...)}.
#'
#' @return A \code{data.frame}.
#'
#' @aliases nops_itemresp
#' @seealso nops_eval
#' @keywords utilities
#' @export
nops_itemresp <- function(eval = "nops_eval.csv", exam = Sys.glob("*.rds"),
  psychotools = NULL, labels = NULL, ...)
{
  ## read evaluation data - once as character and once "as usual" allowing ... arguments
  d <- read.csv2(eval, dec = ".", ...)
  d$exam <- gsub(" ", "0", format(d$exam, width = 11L, scientific = FALSE), fixed = TRUE)

  ## answers: correct, partially correct, points
  a <- d[, grep("check.", names(d), fixed = TRUE)]
  a_solved <- sapply(a, function(x) as.numeric(x >= 1))
  a_partial <- sapply(a, function(x) as.numeric(x >  0))
  a_points <- d[, grep("points.", names(d), fixed = TRUE)]

  ## set up return data frame with summaries across all items
  rval <- data.frame(
    nsolved = rowSums(a_solved),
    npartial = rowSums(a_partial),
    npoints = rowSums(a_points),
    mark = if(is.null(d$mark)) NA else factor(d$mark),
    id = factor(d$exam),
    group = factor(substr(d$exam, 7L, 7L))
  )
  
  ## is psychotools available?
  if(is.null(psychotools)) psychotools <- requireNamespace("psychotools")
  if(!is.logical(psychotools)) psychotools <- as.logical(psychotools)
  
  ## extract labels from meta-information  
  if(is.null(labels)) labels <- TRUE
  if(is.logical(labels)) {
    labels <- if(labels) function(metainfo) metainfo$file else function(metainfo) ""
  }
  if(is.character(labels)) {
    labels <- if(labels == "c403") {
      function(metainfo) {
        nam <- metainfo$file
        nam <- strsplit(nam, "-")[[1L]][3L]
        nam <- strsplit(nam, "_")[[1L]][1L]
	nam
      }
    } else {
      utils::getAnywhere(labels)
    }
  }
  if(!is.function(labels)) stop("unknown specification of 'labels'")
  
  ## exercise files
  if(length(exam) >= 1L) {
    exam <- do.call("c", lapply(exam, readRDS))
    m <- length(exam[[1L]])
    file <- lapply(1L:m, function(i) sort(unique(sapply(exam, function(y) y[[i]]$metainfo$file))))

    ## column names
    labs <- sapply(exam[[1L]], function(e) labels(e$metainfo))
    labs <- if(any(nchar(labs) > 0L)) paste0(1:NCOL(a_solved), "_", labs) else 1:NCOL(a_solved)
    colnames(a_solved) <- colnames(a_partial) <- colnames(a_points) <- labs
  
    ## wide version (by item template rather than by exercise)
    fd <- data.frame(id = rep(1L:length(file), sapply(file, length)), stringsAsFactors = FALSE)
    fd$file <- unlist(file)
    labs <- lapply(1L:m, function(i) sapply(unname(exam), function(y) {
      rval <- labels(y[[i]]$metainfo)
      names(rval) <- y[[i]]$metainfo$file
      return(rval)
    }))
    labs <- do.call("c", labs)
    labs <- labs[!duplicated(names(labs))]
    fd$labels <- labs[fd$file]
    
    w_solved <- w_partial <- w_points <- matrix(NA_integer_, nrow = nrow(a_solved), ncol = nrow(fd))

    exam <- exam[d$exam]
    for(i in 1L:m) {
      cl <- match(sapply(exam, function(x) x[[i]]$metainfo$file), fd$file)
      w_solved[cbind(1L:nrow(w_solved), cl)] <- a_solved[, i]
      w_partial[cbind(1L:nrow(w_partial), cl)] <- a_partial[, i]
      w_points[cbind(1L:nrow(w_points), cl)] <- a_points[, i]
    }
        
    id2 <- unlist(tapply(fd$id, fd$id, function(x) if(length(x) > 1L) 1L + seq_along(x) else 1L))
    colnames(w_solved) <- colnames(w_partial) <- colnames(w_points) <- paste0(fd$id, c("", letters)[id2], "_", fd$labels)
  } else {
    colnames(a_solved) <- colnames(a_partial) <- colnames(a_points) <- paste0(1:NCOL(a_solved))
    w_solved  <- NULL
    w_partial <- NULL
    w_points  <- NULL
  }

  ## collect results
  rval$solved   <- if(psychotools) psychotools::itemresp(a_solved, mscale = 0L:1L) else a_solved
  rval$partial  <- if(psychotools) psychotools::itemresp(a_partial, mscale = 0L:1L) else a_partial
  rval$points   <- a_points
  rval$solved2  <- if(psychotools && !is.null(w_solved)) psychotools::itemresp(w_solved, mscale = 0L:1L) else w_solved
  rval$partial2 <- if(psychotools && !is.null(w_partial)) psychotools::itemresp(w_partial, mscale = 0L:1L) else w_partial
  rval$points2  <- w_points

  ## add other covariates
  rval <- cbind(rval, d[, 1L:(which(names(d) == "exam") - 1L)])

  return(rval)
}
