library(shiny)
library(tools)

source("auxfunctions.R")

source("loadTabModules.R")
source("chooseTabModules.R")
# source("addPointsTabModules.R")
source("exportTabModules.R")

locationExercises <- "testExercises"
locationTemplates <- "./templates"

# user interface of the app
# using the user interface elements defined in the modules
ui <- navbarPage(id="tabs",
  title = "R Exams",
  loadTabUI("loadTab"),
  chooseTabUI("chooseTab"),
#  addPointsTabUI("addPointsTab"),
  exportTabUI("exportTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    # path to the temporary folder
    pathToTmpFolder = NULL,
    # path to the existing exercises
    pathToExercisesGiven = NULL,
    # path to the templates
    pathTemplatesGiven = NULL,
    # selected exercises (are stored in an exam)
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    # list of possible formats for export
    formatList = c()
  )
 
  # Observer to store the parameters given to the app in reactive values 
  # using the values directly in the reactive values did not work in all cases
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathToExercisesGiven = file.path(locationExercises)
    reactVals$pathTemplatesGiven = file.path(locationTemplates)
    selectedExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric())
    reactVals$formatList = c("TCExam", "Moodle", "QTI21", "QTI12", "Canvas", "PDF", "DOCX", "OpenOLAT", "NOPS", "HTML", "Blackboard", "ARSnova")
  })
  

  # load tab module (and store the returned value)
  modifiedDataLoadTab = loadTabServer("loadTab", reactive(reactVals$pathToTmpFolder), reactive(reactVals$pathToExercisesGiven))
 
  # load choose module (and store the returned value)
  modifiedDataChooseTab = chooseTabServer("chooseTab", reactive(reactVals$pathToTmpFolder),reactive(input$tabs))

  # load export module
  exportTabServer("exportTab", reactive(reactVals$pathToTmpFolder),reactive(input$tabs))
  
  # # call the server logic of the export tab
  # callModule(exportTabLogic, "exportTab", reactive(reactVals$selectedExerciseList), reactive(reactVals$formatList), reactive(reactVals$pathTemplatesGiven), 
  #            reactive(reactVals$pathToTmpFolder))
  

}

shinyApp(ui, server)
