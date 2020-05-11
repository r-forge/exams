#list.files (path = "/home/julia/BAC-Arbeit", recursive = TRUE)
#a = list.dirs(path = "/home/julia/BAC-Arbeit", recursive=FALSE)
#l = list()
#for(i in 1:length(a)){
#  l[[i]] = list.files(path = a[i])
#}
#l
#names(l) = gsub("^.*/","",a)
#l$Presentation

getDirFilesOneLevel <- function(path){
  dirList = list.dirs(path = path, recursive=FALSE);
  dirFileList = list();
  for(i in 1:length(dirList)){
    dirFileList[[i]] = list.files(path = dirList[i]);
  }
  names(dirFileList) = gsub("^.*/","",dirList);
  return(dirFileList)
}

l = getDirFilesOneLevel("/home/julia/BAC-Arbeit")
nam = names(l)
l[nam[2]]
length(l[nam[2]])
matrix(l[nam[2]])
typeof(l[nam[2]])
df = data.frame(Foldername = character(), Filename = character())
df = rbind(df, data.frame(Foldername = "Arbeit", Filename="01_zugaenge.Rmd"))
df = rbind(df, data.frame(Foldername = "Arbeit", Filename="02_stufenmodell.Rmd"))
df$Filename["02_stufenmodell.Rmd" %in% df$Filename]


getwd()
file.rename("/home/julia/Downloads/orange.png", "/home/julia/Downloads/apple.png")

library(readr)
guess_encoding("/home/julia/rProjectExams/01_loadTab/test.R", n_max = 1000)
stringi::stri_enc_detect2("/home/julia/rProjectExams/01_loadTab/test.R")
stringi::stri_enc_detect("/home/julia/rProjectExams/01_loadTab/test.R")[[1]][1,1]
file.encoding("/home/julia/rProjectExams/01_loadTab/test.R")