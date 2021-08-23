library(shiny)
library(tools)

source("auxfunctions.R")

source("loadTabModules.R")
source("chooseTabModules.R")
# source("addPointsTabModules.R")
source("exportTabModules.R")
source("editTabModules.R")

locationExercises <- "testExercises"

# user interface of the app
# using the user interface elements defined in the modules
ui <- navbarPage(id="tabs",
  title = "R examsApp",
  loadTabUI("loadTab"),
  chooseTabUI("chooseTab"),
#  addPointsTabUI("addPointsTab"),
  exportTabUI("exportTab"),
  editTabUI("editTab")
)

server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    # path to the temporary folder
    pathToTmpFolder = NULL,
    # path to the existing exercises
    pathToExercisesGiven = NULL
  )
 
  # Observer to store the parameters given to the app in reactive values 
  # using the values directly in the reactive values did not work in all cases
  observe({
    reactVals$pathToTmpFolder = makeTmpPath()
    reactVals$pathToExercisesGiven = file.path(locationExercises)
  })
  

  # load tab module (and store the returned value)
  loadTabServer("loadTab", reactive(reactVals$pathToTmpFolder), reactive(reactVals$pathToExercisesGiven),reactive(input$tabs))
 
  # load choose module (and store the returned value)
  chooseTabServer("chooseTab", reactive(reactVals$pathToTmpFolder),reactive(input$tabs))

  # load export module
  exportTabServer("exportTab", reactive(reactVals$pathToTmpFolder),reactive(input$tabs))
  
  # # call the server logic of the export tab
  # callModule(exportTabLogic, "exportTab", reactive(reactVals$selectedExerciseList), reactive(reactVals$formatList), reactive(reactVals$pathTemplatesGiven), 
  #            reactive(reactVals$pathToTmpFolder))
  
# edit task module
  editTabServer("editTab", reactive(reactVals$pathToTmpFolder),reactive(input$tabs))
  
}

shinyApp(ui, server)
