TTH <- TTM <- ""

.onLoad <- function(libname, pkgname) {
    
    ## command line options should be arguments of tth(), current
    ## version is proof of concept
    if(suppressWarnings(require("tth"))) {
      if(.Platform$OS.type == "windows") {
        TTH <<- file.path(.find.package("tth"), "libs", .Platform$r_arch, "tth.exe -r -u -e2 -y0")
        TTM <<- file.path(.find.package("tth"), "libs", .Platform$r_arch, "ttm.exe -r -u -e2 -y0")
      } else {
        TTH <<- file.path(.find.package("tth"), "libs", .Platform$r_arch, "tth -r -u -e2 -y0")
        TTM <<- file.path(.find.package("tth"), "libs", .Platform$r_arch, "ttm -r -u -e2 -y0")
      }
    } else {
      if(.Platform$OS.type == "windows") {
        TTH <<- "tth.exe -r -u -e2 -y0"
        TTM <<- "ttm.exe -r -u -e2 -y0"
      } else {
        TTH <<- "tth -r -u -e2 -y0"
        TTM <<- "ttm -r -u -e2 -y0"
      }    
    }
}

tth <- function(x, delblanks = TRUE)
{
    y <- system(htmltools:::TTH, input = x, intern = TRUE, ignore.stderr = TRUE)

    if(delblanks)
        y <- y[-grep("^ *$", y)]    

    y
}

ttm <- function(x, delblanks = TRUE)
{
    y <- system(htmltools:::TTH, input = x, intern = TRUE, ignore.stderr = TRUE)

    if(delblanks)
        y <- y[-grep("^ *$", y)]    

    y
}
