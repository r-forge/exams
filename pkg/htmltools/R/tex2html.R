TTH <- TTM <- ""

.onLoad <- function(libname, pkgname) {
    
    ## command line options should be arguments of tth(), current
    ## version is proof of concept
    if(.Platform$OS.type == "windows"){
        TTH <<- file.path(libname, pkgname, "libs",
                          .Platform$r_arch, "tth.exe -r -u -e2 -y0")
        TTM <<- file.path(libname, pkgname, "libs",
                          .Platform$r_arch, "ttm.exe -r -u -e2 -y0")
    } else {
        TTH <<- file.path(libname, pkgname, "libs", 
                          .Platform$r_arch, "tth -r -u -e2 -y0")
        TTM <<- file.path(libname, pkgname, "libs", 
                          .Platform$r_arch, "ttm -r -u -e2 -y0")
    }
}

tth <- function(x, delblanks = TRUE)
{
    y <- system(tth:::TTH, input = x, intern = TRUE, ignore.stderr = TRUE)

    if(delblanks)
        y <- y[-grep("^ *$", y)]    

    y
}

ttm <- function(x, delblanks = TRUE)
{
    y <- system(tth:::TTH, input = x, intern = TRUE, ignore.stderr = TRUE)

    if(delblanks)
        y <- y[-grep("^ *$", y)]    

    y
}
