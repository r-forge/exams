library(shiny)
source("loadTabModules.R")
source("chooseTabModules.R")

#https://stackoverflow.com/questions/39270365/shiny-dt-single-cell-selection/39270631

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

ui <- navbarPage(
  #titlePanel("Load Exercises"),
  title = "R Exams",
  loadTabUI("loadTab"),
  chooseTabUI("chooseTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL,
    pathExercisesGiven = NULL,
    possibleExerciseList = data.frame(Foldername=character(), Filename=character()),
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character()),
    givenExercises = NULL
  )
  
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathExercisesGiven = file.path("../testExercises")
    reactVals$possibleExerciseList = data.frame(Foldername=character(), Filename=character())
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character())
    reactVals$givenExercises = getDirFilesOneLevel("../testExercises")
  })
  
  #Observes the output of the loadTab - at the moment it is only the selectedFiles table
  observe({
    reactVals$possibleExerciseList = modifiedDataLoadTab()
    #print(reactVals$possibleExerciseList)
  })
  
  modifiedDataLoadTab = callModule(loadTabLogic, "loadTab", reactive(reactVals$pathExercisesGiven), reactive(reactVals$pathToTmpFolder), 
                                  reactive(reactVals$possibleExerciseList), reactive(reactVals$givenExercises))
  
  callModule(chooseTabLogic, "chooseTab", reactive(reactVals$pathToTmpFolder), reactive(reactVals$possibleExerciseList),
             reactive(reactVals$selectedExerciseList))
  
}

shinyApp(ui, server)