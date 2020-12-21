library(shiny)
source("loadTabModules.R")
source("chooseTabModules.R")
source("addPointsTabModules.R")
source("exportTabModules.R")

locationExercises <- "./testExercises"
locationTemplates <- "./templates"

# function creates temporary folder
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

# function creates list of list of the subfolder including files of a 
# given path (folder)
getDirFilesOneLevel <- function(path){
  dirList = list.dirs(path = path, recursive=FALSE);
  dirFileList = list();
  for(i in 1:length(dirList)){
    dirFileList[[i]] = list.files(path = dirList[i]);
  }
  names(dirFileList) = gsub("^.*/","",dirList);
  return(dirFileList)
}

# user interface of the app
# using the user interface elements defined in the modules
ui <- navbarPage(
  title = "R Exams",
  loadTabUI("loadTab"),
  chooseTabUI("chooseTab"),
  addPointsTabUI("addPointsTab"),
  exportTabUI("exportTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    # path to the temporary folder
    pathToTmpFolder = NULL,
    # path to the existing exercises
    pathExercisesGiven = NULL,
    # path to the templates
    pathTemplatesGiven = NULL,
    # possible exercises (are already choosen but not stored in an exam)
    possibleExerciseList = data.frame(Foldername=character(), Filename=character()),
    # selected exercises (are stored in an exam)
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    # exercises from path pathExercisesGiven
    givenExercises = NULL,
    # list of possible formats for export
    formatList = c(),
    # list of seeds (vector with three elements - more elements are ignored)
    seedList = c()
  )
 
  # Observer to store the parameters given to the app in reactive values 
  # using the values directly in the reactive values did not work in all cases
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathExercisesGiven = file.path(locationExercises)
    reactVals$pathTemplatesGiven = file.path(locationTemplates)
    reactVals$possibleExerciseList = data.frame(Foldername=character(), Filename=character())
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric())
    reactVals$givenExercises = getDirFilesOneLevel(locationExercises)
    reactVals$formatList = c("TCExam", "Moodle", "QTI21", "QTI12", "Canvas", "PDF", "DOCX", "OpenOLAT", "NOPS", "HTML", "Blackboard", "ARSnova")
    reactVals$seedList = sample(0L:1e8L,3)#c(845934, 9468946, 2039589)
  })
  
  # Observes the output of the load tab
  observe({
    reactVals$possibleExerciseList = modifiedDataLoadTab()
  })
  
  # Observes the output of the choose tab
  observe({
    reactVals$selectedExerciseList = modifiedDataChooseTab()
  })
  
  # Observes the output of the add points tab
  observe({
    reactVals$selectedExerciseList = modifiedDataAddPointsTab()
  })
  
  # call the server logic of the load tab and store the returned value
  modifiedDataLoadTab = callModule(loadTabLogic, "loadTab", reactive(reactVals$pathExercisesGiven), reactive(reactVals$pathToTmpFolder), 
                                  reactive(reactVals$possibleExerciseList), reactive(reactVals$givenExercises))
  
  # call the server logic of the choose tab and store the returned value
  modifiedDataChooseTab = callModule(chooseTabLogic, "chooseTab", reactive(reactVals$pathToTmpFolder), reactive(reactVals$possibleExerciseList),
                                    reactive(reactVals$selectedExerciseList), reactive(reactVals$seedList))
  
  # call the server logic of the add points tab and store the returned value
  modifiedDataAddPointsTab = callModule(addPointsTabLogic, "addPointsTab", reactive(reactVals$selectedExerciseList))
  
  # call the server logic of the export tab
  callModule(exportTabLogic, "exportTab", reactive(reactVals$selectedExerciseList), reactive(reactVals$formatList), reactive(reactVals$pathTemplatesGiven), 
             reactive(reactVals$pathToTmpFolder), reactive(reactVals$seedList))
  
}

shinyApp(ui, server)