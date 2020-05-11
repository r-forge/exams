library(shiny)
library(DT)

ui <- fluidPage(
  
  titlePanel("Load Exercises"),
  
  fluidRow(
    column(6,
           DT::dataTableOutput(outputId = "folderSelector")
           ),
    column(6,
           DT::dataTableOutput(outputId = "fileSelector")
           )
  ),
  br(),
  br(),
  fluidRow(
    column(6),
    column(6,
           
           column(6,
                  actionButton(inputId = "previewShow", label = "Show Preview")
           ),
           column(6,
                  actionButton(inputId = "addExcerciseToList", label = "Add Exercise(s)")
           ),
           br(),
           br(),
           uiOutput("player", inline = TRUE, container = div)
           
    )
  ),
  fluidRow(
    checkboxInput(inputId = "addedExerciseShow", label = "Show added exercise(s)", value = FALSE),
    
    conditionalPanel(condition = "input.addedExerciseShow == 1",
                     
                     DT::dataTableOutput(outputId = "outputAddedFiles")
                     
    ),
    
    checkboxInput(inputId = "loadSingleFile", label = "load exercise from local storage"),
    
    conditionalPanel(condition = "input.loadSingleFile == 1",
                     
                     column(9,
                            fileInput(inputId = "inputLocalFile", label="", multiple = FALSE, accept = c(".Rmd", ".Rnw"))
                            ),
                     column(3,
                            br(),
                            actionButton(inputId = "addLocalExercise", label = "Add exercise")
                            )
                     
    )
    
    
  )
  
  
)
