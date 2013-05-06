exams_eval <- function(partial = FALSE, negative = FALSE, rule = c("false", "true"))
{
  ## rule for negative points in partial evaluation of mchoice answers
  rule <- match.arg(rule)
  
  ## negative value for wrong answers (or lower bound for sum of partial results)
  if(is.logical(negative)) negative <- ifelse(negative, -1, 0)
  negative <- -abs(as.numeric(negative))

  ## convenience function for determining exercise type
  extype <- function(correct, answer = NULL) {
    mchoice01 <- function(x) as.numeric(strsplit(unlist(x), "")[[1L]])
    if(is.numeric(correct)) {
      type <- "num"
      if(!is.null(answer)) {
        if(is.character(answer)) answer <- gsub(",", ".", answer, fixed = TRUE)
	answer <- as.numeric(answer)
      }
    } else if(is.logical(correct)) {
      type <- "mchoice"
      if(!is.null(answer)) {
        if(is.character(answer)) answer <- mchoice01(answer)
	answer <- as.logical(answer)
      }
    } else if(is.character(correct)) {
      if(all(strsplit(correct, "")[[1L]] %in% c("0", "1"))) {
        type <- "mchoice"
	correct <- as.logical(mchoice01(correct))
        if(!is.null(answer)) {
          if(is.character(answer)) answer <- mchoice01(answer)
	  answer <- as.logical(answer)
        }
      } else {
        type <- "string"
	if(!is.null(answer)) answer <- as.character(answer)
      }    
    } else {
      stop("Unknown exercise type.")
    }
    
    if(!is.null(answer)) {
      if(!is.na(answer) && (length(correct) != length(answer))) stop(
        "Length of 'correct' and given 'answer' do not match.")
    }
    
    return(list(type = type, correct = correct, answer = answer))
  }
  
  checkanswer <- function(correct, answer, tolerance = 0)
  {
    ## preprocess type of solution
    type <- extype(correct, answer)
    correct <- type$correct
    answer <- type$answer
    type <- type$type

    if(is.null(answer)) return(rep.int(0, length(correct)))
    
    ## numeric answer can be NA or needs to fall into tolerance interval
    if(type == "num") {
      if(is.na(answer)) return(0L)
      if(answer >= correct - tolerance & answer <= correct + tolerance) {
        return(1L)
      } else {
        return(-1L)
      }
    }
    
    ## mchoice answer can be processed partially or as a whole pattern
    if(type == "mchoice") {
      if(any(is.na(answer))) return(0L)
      if(partial) {
	rval <- rep.int(0L, length(answer))
        if(all(!answer)) return(rval)
	rval[which(correct & answer)] <- 1L
	rval[which(!correct & answer)] <- -1L
	return(rval)
      } else {
        if(any(is.na(answer))) return(0)
        if(negative < 0 & all(!answer)) return(0)
        return(ifelse(all(correct == answer), 1L, -1L))
      }
    }
    
    ## string answer is NA if empty, otherwise has to match exactly
    if(type == "string") {
      if(is.na(answer) | all(grepl("^[[:space:]]*$", answer))) return(NA)
      return(ifelse(correct == answer, 1L, -1L))
    }
  }

  pointvec <- function(correct = NULL) {
    if(!partial) return(c("pos" = 1, "neg" = negative))
    if(is.null(correct)) stop("Need 'correct' answer to compute points vector.")
    type <- extype(correct)
    if(type$type == "mchoice") {
      n <- if(rule == "false") pmax(sum(!type$correct), 2) else sum(type$correct)
      return(c("pos" = 1/sum(type$correct), "neg" = -1/n))
    } else {
      return(c("pos" = 1, "neg" = negative))
    }
  }
  
  pointsum <- function(correct, answer, tolerance = 0) {
    pts <- pointvec(correct)
    chk <- as.character(checkanswer(correct, answer, tolerance = tolerance))
    res <- rep(0, length.out = length(chk))
    res[which(chk == "1")] <- pts["pos"]
    res[which(chk == "-1")] <- pts["neg"]
    pmax(sum(res), negative)
  }

  ## return (processed) parameters and functions
  list(
    partial = partial,
    negative = negative,
    rule = rule,
    checkanswer = checkanswer,
    pointvec = pointvec,
    pointsum = pointsum
  )
}

if(FALSE) {
## default evaluation policy: partial = FALSE, negative = FALSE
ee <- exams_eval()

## points that can be achieved are 0/1
ee$pointvec()

## checkanswer() returns 1 for correct, -1 for incorrect and 0 for missing answer
ee$checkanswer(1.23, 1.23)
ee$checkanswer(1.23, "1.23")
ee$checkanswer(1.23, "1,23")
ee$checkanswer(1.23, 1.24)
ee$checkanswer(1.23, 1.24, tolerance = 0.01)
ee$checkanswer(1.23, NA)
ee$checkanswer(1.23, NULL)
ee$checkanswer(1.23, "")

## similarly for logical (mchoice/schoice) answers
## (which allows either string or logical specification)
ee$checkanswer("10000", "10000")
ee$checkanswer(c(TRUE, FALSE, FALSE, FALSE, FALSE), c(TRUE, FALSE, FALSE, FALSE, FALSE))
ee$checkanswer(c(TRUE, FALSE, FALSE, FALSE, FALSE), "10000")
ee$checkanswer("10000", "01000")
ee$checkanswer("10000", "11000")

## and analogously for strings
ee$checkanswer("foo", "foo")
ee$checkanswer("foo", "bar")
ee$checkanswer("foo", "")

## obtain points achieved
ee$pointsum("10000", "10000")
ee$pointsum("10000", "01000")
ee$pointsum("10000", "00000")
ee$pointsum("10000", NA)

## ---------------------------------------------------------
## evaluation policy with -25% penalty for wrong answers
ee <- exams_eval(partial = FALSE, negative = -0.25)

## points that can be achieved are 1/-0.25 (or zero)
ee$pointvec()

## obtain points achieved
ee$pointsum("10000", "10000")
ee$pointsum("10000", "01000")
ee$pointsum("10000", "00000")
ee$pointsum("10000", NA)
ee$pointsum(1.23, 1.23)
ee$pointsum(1.23, 2.34)
ee$pointsum(1.23, NA)

## ---------------------------------------------------------
## evaluation policy with partial points
## (but without negative points overall)
ee <- exams_eval(partial = TRUE)

## points that can be achieved are 1/3 (1/#true)
## or -1/2 (1/#false)
ee$pointvec("10101")

## obtain points achieved
ee$pointsum("10101", "10101")
ee$pointsum("10101", "10100")
ee$pointsum("10101", "11100")
ee$pointsum("10101", "01010")
ee$pointsum("10101", "00000")

## show individual answer check
ee$checkanswer("10101", "10101")
ee$checkanswer("10101", "10100")
ee$checkanswer("10101", "11100")
ee$checkanswer("10101", "01010")
ee$checkanswer("10101", "00000")

## numeric/string answers are not affected by partial=TRUE
ee$checkanswer(1.23, 1.23)
ee$pointsum(1.23, 1.23)
ee$checkanswer(1.23, 2.34)
ee$pointsum(1.23, 2.34)

## ---------------------------------------------------------
## evaluation policy with partial points
## (and with up to -25% negative points overall)
ee <- exams_eval(partial = TRUE, negative = -0.25)

## points that can be achieved are 1/3 (1/#true)
## or -1/2 (1/#false)
ee$pointvec("10101")

## obtain points achieved
ee$pointsum("10101", "10101")
ee$pointsum("10101", "01010")
ee$pointsum("10101", "00000")

## show individual answer check
ee$checkanswer("10101", "10101")
ee$checkanswer("10101", "10100")
ee$checkanswer("10101", "11100")
ee$checkanswer("10101", "01010")
ee$checkanswer("10101", "00000")

## numeric/string answers are not affected by partial=TRUE
ee$pointsum(1.23, 1.23)
ee$pointsum(1.23, 2.34)
}
