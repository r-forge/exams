olat_eval <- function(file, plot = TRUE)
{
  ## file basename
  file <- tools::file_path_sans_ext(file)

  ## read/parse data
  exm <- readRDS(paste(file, "rds", sep = "."))
  res <- paste(file, c("xls", "xlsx"), sep = ".")
  res <- res[file.exists(res)]
  res <- read_olat_results(res, exm)
  n <- length(exm)
  k <- length(exm[[1L]])

  ## omit duplicated students, keep only last result
  ## (assuming chronological ordering -> could also be enforced otherwise)
  if("Matrikelnummer" %in% names(res)) {
    res <- res[!duplicated(res$Matrikelnummer, fromLast = TRUE), ]
  } else {
    res <- res[!duplicated(res$Benutzername, fromLast = TRUE), ]  
  }

  ## "Benutzername" needed to be fixed in OpenOLAT for some time
  register <- NULL
  if(!is.null(register)) {
    if(is.character(register)) register <- read.csv2(register, colClasses = "character")
    rownames(register) <- register$Matrikelnr
    rownames(res) <- res$Matrikelnummer
    res <- res[rownames(res) %in% rownames(register), , drop = FALSE]
    res$Benutzername <- register[rownames(res), "Account"]
  }  

  ## write results to csv
  write.table(res, paste(file, "csv", sep = "."), sep = ";", row.names = FALSE, col.names = TRUE, quote = FALSE)
  
  ## visualize aggregate statistics
  if(plot) {
    ## plots
    par(mar = c(4, 6, 4, 1), mfrow = c(1, 2))

    ## exercise names (FIXME: somewhat uibkmath-specific!)
    nam0 <- sapply(exm[[1L]], function(obj) obj$metainfo$file)
    nam <- try(sapply(strsplit(nam0, "-", fixed = TRUE), "[[", 3L), silent = TRUE)
    nam <- if(inherits(nam, "try-error")) {
      nam0
    } else {
      sapply(strsplit(nam, "_", fixed = TRUE), "[[", 1L)
    }

    ## error proportion
    pts <- as.matrix(res[, paste("points", 1L:k, sep = ".")])
    pts[is.na(pts)] <- 0
    pmx <- sapply(exm[[1L]], function(obj) {
      p <- obj$metainfo$points
      if(is.null(p)) 1 else p
    })
    pts <- 1 - pts/pmx
    pts <- colMeans(pts, na.rm = TRUE)
    barplot(pts[k:1L], names = nam[k:1L], horiz = TRUE, las = 1, main = "Error proportion")

    ## median duration
    drt <- as.matrix(res[, paste("duration", 1L:k, sep = ".")])
    drt <- as.vector(apply(drt/3600, 2, median, na.rm = TRUE))
    barplot(drt[k:1L], names = nam[k:1L], horiz = TRUE, las = 1, main = "Median duration")
  }

  ## return overall results invisibly
  invisible(res)
}

## get OLAT test results (FIXME: eval support and cloze evaluation)
read_olat_results <- function(file, xexam = NULL)
{
  ## checking
  stopifnot(file.exists(file <- path.expand(file)))

  ## read xexam (if any)
  if(!is.null(xexam)) {
    if(is.character(xexam)) xexam <- readRDS(xexam)
  }

  ## QTI 2.1 xlsx or QTI 1.2 xls?
  xlsx <- tools::file_ext(file) == "xlsx"

  if(xlsx) {
    ## read data
    x <- openxlsx::read.xlsx(file, startRow = 2)

    ## number of columns of person info
    nc <- min(grep("_", names(x), fixed = TRUE)) - 2

    ## only test results, omitting section points
    y <- x[, -(1:nc)]
    y <- y[, -grep("Punkte", names(y))] ## FIXME: language?

    ## columns pertaining to items
    iid <- sapply(strsplit(names(y), "_"), function(x) rev(x)[2L])
    ok <- which(!is.na(iid))
    gaps <- diff(c(ok, length(iid) + 1L))
    iid <- rep(iid[ok], gaps)
    iid <- as.numeric(iid) - 1
  } else {
    ## read data
    x <- readLines(file, warn = FALSE)
    x <- read.table(file, header = TRUE, sep = "\t",
      colClasses = "character", skip = 1, fill = TRUE,
      nrows = min(which(x == "")) - 3, quote = "\"")

    ## number of columns of person info
    nc <- min(grep("X1_", names(x), fixed = TRUE)) - 1

    ## only test results
    y <- x[, -(1:nc)]

    ## columns pertaining to items
    iid <- na.omit(as.numeric(unlist(sapply(
      strsplit(substr(names(y), 2, nchar(names(y))),
      "_", fixed = TRUE), head, 1))))
  }

  ## item-wise data.frame
  y <- lapply(split(x = seq_along(iid), f = iid),
    function(ind) y[, ind, drop = FALSE])

  ## logical item x person matrix
  ipmat <- t(sapply(y, function(d) nchar(as.character(d[, ncol(d) - 1L])) > 10L))

  ## which person solved which items

  ## assume xexams object
  ## number of sections and items
#  ns <- length(xexam)
#  ni <- unique(sapply(xexam, length))
#  stopifnot(length(ni) == 1L)
  ix1 <- lapply(1:ncol(ipmat), function(i) which(as.vector(ipmat[,i])))
  ni <- max(unlist(lapply(ix1, length)))
  ns <- length(unique(iid)) / ni

  stopifnot(ns %% 1 == 0)

  ix2 <- lapply(ix1, function(i) {
    ix <- rep(NA, ni)
    ix[1L + (i - 1L) %/% ns] <- 1L + (i - 1L) %% ns
    ix
  })

  toPOSIXct <- if(xlsx) {
    function(x) ifelse(is.na(x) | x == "", NA, as.POSIXct(format(structure((x - 25567) * 24 * 3600, class = c("POSIXct", "POSIXt")))))
  } else {
    function(x) ifelse(is.na(x) | x == "", NA, as.POSIXct(strptime(x, format = "%Y-%m-%dT%H:%M:%S")))
  }

  ## compute results
  process_item_result <- function(j)
  {
    rval <- lapply(1:length(ix2[[j]]), function(i) {
      id <- ix2[[j]][i]
      if(!is.na(id)) {
        ir <- y[[id + (i - 1) * ns]][j, ]
        k <- ncol(ir)
        points <- as.numeric(ir[, k - 2 - xlsx])
        points <- if(is.na(points)) 0 else points
        start <- ir[, k - 1]
        dur <- ir[, k]
        ssol <- ssol0 <- ir[, 1:(k - 3 - xlsx)]
        if(NCOL(ssol) > 1) {
          ssol <- ssol0 <- if(xlsx) {
	    try(gsub("NA", "0", gsub("x", "1", paste(ssol, collapse = ""), fixed = TRUE), fixed = TRUE), silent = TRUE)
	  } else {
	    try(gsub(".", "0", paste(ssol[-length(ssol)], collapse = ""), fixed = TRUE), silent = TRUE)	  
	  }
        } else {
          ssol <- ssol0 <- try(gsub(",", ".", ssol, fixed = TRUE), silent = TRUE)
        }
        if(inherits(ssol, "try-error")) ssol <- ssol0 <- NA
        solx <- scheck <- NA
        if(!is.null(xexam) & !is.na(id)) {
          solx  <- xexam[[id]][[i]]$metainfo$solution
          tolx  <- xexam[[id]][[i]]$metainfo$tolerance
	  typex <- xexam[[id]][[i]]$metainfo$type[1L]
	  ptsx  <- xexam[[id]][[i]]$metainfo$points
	  if(is.null(ptsx)) ptsx <- 1
          if(typex %in% c("mchoice", "schoice")) {
            solx <- exams::mchoice2string(solx)
            scheck <- as.numeric(points > 0) ## (ssol == solx) * ptsx
          } else if(typex == "num") {
	    ssol <- as.numeric(gsub(",", ".", ssol, fixed = TRUE))
            scheck <- as.numeric(points > 0) ## ((ssol >= solx - tolx) & (ssol <= solx + tolx)) * ptsx
          } else if(typex == "cloze") {
            stop("OLAT cloze reader not yet implemented")
	  }
        }
        if(is.na(scheck)) scheck <- 0
	res <- data.frame(id + (i - 1) * ns, round(as.numeric(points), digits = 8), scheck, ssol0, solx,
          toPOSIXct(start), as.numeric(dur), stringsAsFactors = FALSE)
      } else {
        res <- data.frame(t(rep(NA, 7L)))
      }
      if(!xlsx) res[res == ""] <- NA
      names(res) <- paste(c("id", "points", "check", "answer", "solution", "start", "duration"), i, sep = ".")
      return(res)
    })
    return(data.frame(rval, stringsAsFactors = FALSE))
  }

  res <- lapply(1L:length(ix2), process_item_result)
  rval <- res[[1L]]
  for(j in 2L:length(res)) rval <- rbind(rval, res[[j]])
  res <- cbind(x[, 2L:nc], rval)
  names(res) <- gsub("Institutionsnummer", "MatrNr", names(res))
  names(res) <- gsub("..s.", "", names(res), fixed = TRUE)
  names(res) <- gsub(".(s)", "", names(res), fixed = TRUE)

  if(xlsx) {
    if("Datum" %in% names(res)) res$Datum <- toPOSIXct(res$Datum)
    if("Punkte" %in% names(res)) res$Punkte <- round(res$Punkte, digits = 8)
  } else {
    true_false <- apply(res, 2, function(x) {
      if(is.character(x)) {
        x == "true" || x == "false"
      } else FALSE
    })
    if(any(true_false)) {
      for(i in which(true_false)) {
        wh <- FALSE
        if(!any(grepl("false", res[[i]]))) {
          res[[i]] <- rep(TRUE, length(res[[i]]))
          wh <- TRUE
        }
        if(!any(grepl("true", res[[i]]))) {
          wh <- TRUE
          res[[i]] <- rep(FALSE, length(res[[i]]))
        }
        if(!wh) res[[i]] <- res[[i]] == "true"
      }
    }
  }
  
  res
}

