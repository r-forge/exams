getExercises <- function(path){
  lf <- list.files(paste0(path,"/","exercises"), recursive = TRUE)
  lf <- lf[tolower(file_ext(lf)) %in% c("rnw", "rmd")]
  return(lf)
}

getExams <- function(path){
  lf <- list.files(paste0(path,"/","exams"), recursive = TRUE)
  lf <- lf[tolower(file_ext(lf)) %in% c("json")]
  return(lf)
}

fileCopySubdir <- function(file,dirFrom,dirTo) {
  tmpDir <- paste0(dirTo,"/",dirname(file))
  if (!dir.exists(tmpDir)) dir.create(tmpDir,recursive = T)
  file.copy(paste0(dirFrom,"/",file),tmpDir)
}


# function creates temporary folder with subfolders
makeTmpPath <- function(){
  owd <- getwd()
  dir = NULL
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }
  dir <- path.expand(dir)
  #print(dir)
  
  if ("defaultStructure" %in% list.dirs(recursive = F,full.names = F)) {file.copy("defaultStructure/.",dir,recursive=T)} else {
    lapply(c("exams","exercises","exportConfig","templates","tmp"),function(x) {
      if(!file.exists(file.path(dir, x))) {
        dir.create(file.path(dir, x))
      } else {
        tf <- dir(file.path(dir, x), full.names = TRUE)
        unlink(tf)
      }
    })}
  
  return(file.path(dir))
}


# # function creates list of list of the subfolder including files of a 
# # given path (folder)
# getDirFilesOneLevel <- function(path){
#   dirList = list.dirs(path = path, recursive=FALSE);
#   dirFileList = list();
#   for(i in 1:length(dirList)){
#     dirFileList[[i]] = list.files(path = dirList[i]);
#   }
#   names(dirFileList) = gsub("^.*/","",dirList);
#   return(dirFileList)
# }

