library(shiny)
library(exams)
library(jsonlite)

### Stand 2021-08-16

exportFormatInput <- function(id) {
  uiOutput(NS(id, "exportFormatSelection"))
}
exportFormatServer <- function(id,pathToFolder) {
  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      # path to the temporary folder of the user
      pathToFolderLocal = NULL,
      selectedCommand = NULL,
      selectedArgument = NULL,
      exportFormatNames = NULL)
    
    observe({
      reactVals$pathToFolderLocal = pathToFolder()
      listOfAllExportFormats <- lapply(list.files(file.path(reactVals$pathToFolderLocal,"exportConfig"),glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
      reactVals$exportFormatNames <- sapply(listOfAllExportFormats,function(x) x$name)
      reactVals$selectedCommand = listOfAllExportFormats[[1]]$command
      reactVals$selectedArgument = listOfAllExportFormats[[1]]$argument
    })
    
    output$exportFormatSelection <- renderUI({
      selectInput(NS(id, "exportFormat"), "Pick an output format", choices = reactVals$exportFormatNames)
    })
    
    observeEvent(input$exportFormat,{
      listOfAllExportFormats <- lapply(list.files(file.path(reactVals$pathToFolderLocal,"exportConfig"),glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
      names <- sapply(listOfAllExportFormats,function(x) x$name)
      reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
    })
    
    
    reactive(list(
      command = reactVals$selectedCommand,
      argument = reactVals$selectedArgument
    )
    )
  })
}


##
exportFormatApp <- function() {
  ui <- fluidPage(column(4,
                         verbatimTextOutput("showReturnDebug"),
                         fluidPage(exportFormatInput("exportFormat")))
  )
                         
  
  server <- function(input, output, session) {
    
    exportFormat <- exportFormatServer("exportFormat",reactive("."))
    output$showReturnDebug <- renderPrint(print(exportFormat()$command))

    
  }
  shinyApp(ui, server)
}

exportFormatApp()          

