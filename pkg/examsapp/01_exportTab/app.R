library(shiny)
source("loadTabModules.R")
source("chooseTabModules.R")
source("addPointsTabModules.R")
source("exportTabModules.R")

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
    if(!file.exists(file.path(dir, "exams"))) {
      dir.create(file.path(dir, "exams"))
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
  chooseTabUI("chooseTab"),
  addPointsTabUI("addPointsTab"),
  exportTabUI("exportTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL,
    pathExercisesGiven = NULL,
    pathTemplatesGiven = NULL,
    possibleExerciseList = data.frame(Foldername=character(), Filename=character()),
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    givenExercises = NULL,
    formatList = c()
  )
  
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathExercisesGiven = file.path("../testExercises")
    reactVals$pathTemplatesGiven = file.path("../templates")
    reactVals$possibleExerciseList = data.frame(Foldername=character(), Filename=character())
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric())
    reactVals$givenExercises = getDirFilesOneLevel("../testExercises")
    reactVals$formatList = c("TCExam", "Moodle", "QTI21", "QTI12", "Canvas", "PDF", "DOCX", "OpenOLAT", "NOPS", "HTML", "Blackboard", "ARSnova")
  })
  
  #Observes the output of the loadTab - at the moment it is only the selectedFiles table
  observe({
    reactVals$possibleExerciseList = modifiedDataLoadTab()
  })
  
  observe({
    reactVals$selectedExerciseList = modifiedDataChooseTab()
  })
  
  observe({
    reactVals$selectedExerciseList = modifiedDataAddPointsTab()
  })
  
  modifiedDataLoadTab = callModule(loadTabLogic, "loadTab", reactive(reactVals$pathExercisesGiven), reactive(reactVals$pathToTmpFolder), 
                                  reactive(reactVals$possibleExerciseList), reactive(reactVals$givenExercises))
  
  modifiedDataChooseTab = callModule(chooseTabLogic, "chooseTab", reactive(reactVals$pathToTmpFolder), reactive(reactVals$possibleExerciseList),
                                    reactive(reactVals$selectedExerciseList))
  
  modifiedDataAddPointsTab = callModule(addPointsTabLogic, "addPointsTab", reactive(reactVals$selectedExerciseList))
  
  callModule(exportTabLogic, "exportTab", reactive(reactVals$selectedExerciseList), reactive(reactVals$formatList), reactive(reactVals$pathTemplatesGiven), reactive(reactVals$pathToTmpFolder))
  
}

shinyApp(ui, server)