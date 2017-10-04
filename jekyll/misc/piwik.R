##Sys.setenv("piwik_token"="6e6*****************************")
##Sys.setenv("piwik_baseurl"="http://retostauffer.org/piwik/")
##Sys.setenv("piwik_idSite"=3) # 3 is r-exams, 2 is hclwizard, 1 is retostauffer

piwik <- function(token, method = "VisitsSummary.get",
  idSite = 3, baseurl = "http://retostauffer.org/piwik/",
  format = "csv", ndays = 30, ...)
{
  ## if not set: use environment variable
  if (is.null(idSite))  idSite  <- Sys.getenv("piwik_idSite")
  if (is.null(baseurl)) baseurl <- Sys.getenv("piwik_baseurl")
  if (missing(token))	token	<- Sys.getenv("piwik_token")

  ## check
  if (nchar(idSite)==0L)  stop("idSite not defined.")
  if (nchar(baseurl)==0L) stop("baseurl not defined.")
  if (nchar(token)==0L) stop("token undefined.")

  ## methods: "VisitsSummary.get", "UserCountry.getCountry"

  ## download
  url <- paste0(
    baseurl,
    sprintf("?module=API&method=%s", method),
    sprintf("&idSite=%d", as.integer(idSite)),
    sprintf("&period=day&date=last%d", as.integer(ndays)),
    sprintf("&format=%s", format),
    sprintf("&token_auth=%s", token)
  )
  cat(sprintf("Requesting:\n	 %s\n", url))
  tmp.file <- tempfile("piwik", fileext = ".csv")
  download.file(url, tmp.file, quiet = TRUE)
  on.exit(file.remove(tmp.file))

  ## read
  system(sprintf("dos2unix %s", tmp.file))
  read.csv(tmp.file, ...)
}
