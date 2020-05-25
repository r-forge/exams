library(shiny)
source("loadTabModules.R")

makeTmpPath <- function(){
    owd <- getwd()
    dir = NULL
    if(is.null(dir)) {
      dir.create(dir <- tempfile())
      on.exit(unlink(dir))
    }
    dir <- path.expand(dir)
    print(dir)
    if(!file.exists(file.path(dir, "exercises"))) {
      dir.create(file.path(dir, "exercises"))
    }
    if(!file.exists(file.path(dir, "tmp"))) {
      dir.create(file.path(dir, "tmp"))
    }
    return(file.path(dir))
}

getDirFilesOneLevel <- function(path){
  dirList = list.dirs(path = path, recursive=FALSE);
  dirFileList = list();
  for(i in 1:length(dirList)){
    dirFileList[[i]] = list.files(path = dirList[i]);
  }
  names(dirFileList) = gsub("^.*/","",dirList);
  return(dirFileList)
}

ui <- fluidPage(
  titlePanel("Load Exercises"),
  loadTabUI("loadTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL,
    pathExercisesGiven = NULL,
    possibleExerciseList = data.frame(Foldername=character(), Filename=character()),
    givenExercises = NULL
  )
  
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathExercisesGiven = file.path("../testExercises")
    reactVals$possibleExerciseList = data.frame(Foldername=character(), Filename=character())
    reactVals$givenExercises = getDirFilesOneLevel("../testExercises")
  })
  
  callModule(loadTabLogic, "loadTab", reactive(reactVals$pathExercisesGiven), reactive(reactVals$pathToTmpFolder), 
             reactive(reactVals$possibleExerciseList), reactive(reactVals$givenExercises))
}

shinyApp(ui, server)