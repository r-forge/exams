library(shiny)
library(tools)

getExercises <- function(path){
  exfiles <- list.files(paste0(path,"/","exercises"), recursive = TRUE)
  exfiles <- exfiles[tolower(file_ext(exfiles)) %in% c("rnw", "rmd")]
  return(exfiles)
}

fileCopySubdir <- function(file,dirFrom,dirTo) {
  tmpDir <- paste0(dirTo,"/",dirname(file))
  if (!dir.exists(tmpDir)) dir.create(tmpDir,recursive = T)
  file.copy(paste0(dirFrom,"/",file),tmpDir)
}



source("loadTabModules.R")
source("chooseTabModules.R")
source("addPointsTabModules.R")
source("exportTabModules.R")

locationExercises <- "./testExercises"
locationTemplates <- "./templates"

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
    
    lapply(c("exercises","tmp","exams","templates"),function(x) {
      if(!file.exists(file.path(dir, x))) {
        dir.create(file.path(dir, x))
      } else {
        tf <- dir(file.path(dir, x), full.names = TRUE)
        unlink(tf)
      }
    })
    
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

# unique(dirname(list.files("testExercises/",recursive = T)))



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
  modifiedDataLoadTab = loadTabServer("loadTab", reactive(reactVals$pathExercisesGiven), reactive(reactVals$pathToTmpFolder),                                  reactive(reactVals$possibleExerciseList), reactive(reactVals$givenExercises))
  
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