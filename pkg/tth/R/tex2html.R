TTH <- ""

.onLoad <- function(libname, pkgname){
    
    ## command line options should be arguments of tth(), current
    ## version is proof of concept
    if(.Platform$OS.type == "windows"){
        TTH <<- file.path(libname, pkgname, "libs",
                          .Platform$r_arch, "tth.exe -r -u -e2 -y0")
    } else {
        TTH <<- file.path(libname, pkgname, "libs", 
                          .Platform$r_arch, "tth -r -u -e2 -y0 2>/dev/null")
    }
}




tth <- function(x, delblanks=TRUE)
{
    y <- system(tth:::TTH, intern=TRUE, input=x)

    if(delblanks)
        y <- y[-grep("^ *$", y)]    

    y
}
