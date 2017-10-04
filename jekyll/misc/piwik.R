# -------------------------------------------------------------------
# - NAME:        piwik.R
# - AUTHOR:      Reto Stauffer
# - DATE:        2017-10-04
# -------------------------------------------------------------------
# - DESCRIPTION:
# -------------------------------------------------------------------
# - EDITORIAL:   2017-10-04, RS: Created file on thinkreto.
# -------------------------------------------------------------------
# - L@ST MODIFIED: 2017-10-04 10:46 on thinkreto
# -------------------------------------------------------------------


   ##Sys.setenv("piwik_token"="6e6*****************************")
   ##Sys.setenv("piwik_baseurl"="http://retostauffer.org/piwik/")
   ##Sys.setenv("piwik_idSite"=3) # 3 is r-exams, 2 is hclwizard, 1 is retostauffer

   visits <- function( idSite, token, baseurl, format="csv", ndays=30 ) {
      stopifnot( require("zoo") )
      # If not set: use environment variable
      if ( missing(idSite) )  idSite  <- Sys.getenv("piwik_idSite")
      if ( missing(baseurl) ) baseurl <- Sys.getenv("piwik_baseurl")
      if ( missing(token) )   token   <- Sys.getenv("piwik_token")
      # Check
      if ( nchar(idSite)==0 )  stop("Baseurl not defined.")
      if ( nchar(baseurl)==0 ) stop("Baseurl not defined.")
      if ( nchar(token)==0   ) stop("Token undefined.")
      # Create url
      #method <- "VisitsSummary.getVisits"
      method <- "VisitsSummary.get"
      url <- paste0(
                     baseurl,
                     sprintf("?module=API&method=%s",method),
                     sprintf("&idSite=%d",as.integer(idSite)),
                     sprintf("&period=day&date=last%d",as.integer(ndays)),
                     sprintf("&format=%s",format),
                     sprintf("&token_auth=%s",token)
                  )
      cat(sprintf("Requesting:\n     %s\n",url))
      tmp.file <- tempfile("piwik",fileext=".csv")
      download.file( url, tmp.file, quiet=TRUE )
      system( sprintf("dos2unix %s", tmp.file) )
      x <- read.table( tmp.file, header = TRUE, sep = ",")
      file.remove( tmp.file )

      # Prepare data.frame
      x$bounce_rate <- gsub("%","",x$bounce_rate)
      x <- zoo( data.matrix( subset(x,select=-c(date)) ), as.Date(x$date) )
      return(x)
   }
   

   visitsByCountry <- function( idSite, token, baseurl, format="csv", ndays=30 ) {
      stopifnot( require("zoo") )
      # If not set: use environment variable
      if ( missing(idSite) )  idSite  <- Sys.getenv("piwik_idSite")
      if ( missing(baseurl) ) baseurl <- Sys.getenv("piwik_baseurl")
      if ( missing(token) )   token   <- Sys.getenv("piwik_token")
      # Check
      if ( nchar(idSite)==0 )  stop("Baseurl not defined.")
      if ( nchar(baseurl)==0 ) stop("Baseurl not defined.")
      if ( nchar(token)==0   ) stop("Token undefined.")
      # Create url
      #method <- "VisitsSummary.getVisits"
      method <- "UserCountry.getCountry"
      url <- paste0(
                     baseurl,
                     sprintf("?module=API&method=%s",method),
                     sprintf("&idSite=%d",as.integer(idSite)),
                     sprintf("&period=day&date=last%d",as.integer(ndays)),
                     sprintf("&format=%s",format),
                     sprintf("&token_auth=%s",token)
                  )
      cat(sprintf("Requesting:\n     %s\n",url))
      tmp.file <- tempfile("piwik",fileext=".csv")
      download.file( url, tmp.file, quiet=TRUE )
      system( sprintf("dos2unix %s", tmp.file) )
      x <- read.table( tmp.file, header = TRUE, sep = ",")
      file.remove( tmp.file )

      # Prepare data.frame
      x <- subset( x, select = -c(metadata_logoHeight,metadata_segment,metadata_logo) )
      x$date <- as.Date( x$date )
      return(x)
   }


   visits <- visits() 
   print( visits )

   visitsByC <- visitsByCountry()
   print( visitsByC )












