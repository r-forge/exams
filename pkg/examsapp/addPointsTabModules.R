library(shiny)
library(DT)
#library(exams)
#library(tth)

addPointsTabUI <- function(id){
  
  ns = NS(id)
  
  tabPanel("Add Points",
           
           tagList(
             
             fluidRow(
               column(9,
                      selectInput(ns("selectExercise"), label = "Choose your Exam: ", choices = c("---")),
                      DT::dataTableOutput(ns("exerciseSelector"))
                      
               )
             ),
             fluidRow(
               column(4,
                      tags$head(
                        tags$style(type="text/css", "#inline label{ display: table-cell; text-align: center; vertical-align: middle; } 
                                                      #inline .form-group { display: table-row;}")
                      ),
                      tags$div(id = "inline", numericInput(ns("pointsExercise"), label = "Points:", min = 0.1, max = 1000000, step = 0.1, value = 1))
                      
                ),
                column(3, offset = 1,
                       actionButton(ns("setPoints"), label = "Set Points")
                )
             ),
             fluidRow(
               column(9),
               column(2, offset = 1,
                      actionButton(ns("saveExam"), label = "Save Exam")
               )
             )
             
           )
           
  )
  
}

addPointsTabLogic <- function(input, output, session, selectedExerciseList){
  
  reactVals <- reactiveValues(
    # dataframe which holds all saved exams (including numeration, seeds, blocking and points)
    selectedExerciseDF = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    # temporary dataframe to do not corrupt the real data, before the points are stored
    tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    # list of exam names for the drop down (is built dynamically)
    examNames = c("---")
  )
  
  # Observer to store the parameters given by the function addPointsTabLogic(...) in reactive values
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardizesed pattern to call the data is given 
  observe({
    reactVals$selectedExerciseDF = selectedExerciseList()
    reactVals$examNames = as.vector(unique(c(reactVals$examNames, as.vector(unique(reactVals$selectedExerciseDF$ExamName)))))
    tmpExam = input$selectExercise
    updateSelectInput(session, "selectExercise", choices = reactVals$examNames, selected = tmpExam)
  })
  
  # Observer: Click on "Set Points"
  # the points from the numeric input are assigned to the selected exercises
  # blocked exercises get automatically the same amount of points, even if they are not all selected
  observeEvent(input$setPoints, {
    req(input$pointsExercise)
    if(is.null(input$pointsExercise) || !is.numeric(input$pointsExercise)){
      showNotification("Please enter a positive number as points.", type = c("error"))
    }
    else{
      rowNumbers = as.vector(input$exerciseSelector_rows_selected)
      if(length(rowNumbers)>0){
        tmpNumberExercises = reactVals$tmpExamExercises[rowNumbers,3]
        rowNumbersUpdate = which(reactVals$tmpExamExercises$Number %in% tmpNumberExercises)
        reactVals$tmpExamExercises[rowNumbersUpdate,6] = rep(as.numeric(input$pointsExercise),length(rowNumbersUpdate))
      }
      else{
        showNotification("Please choose at least one exercise.", type = c("error"))
      }
    }
  })
  
  # Observer: Drop Down to select an exam
  # the data of the selected exam is copied to the temporary dataframe to work on this
  observeEvent(input$selectExercise, {
    if(input$selectExercise != "---"){
      examName = input$selectExercise
      reactVals$tmpExamExercises = reactVals$selectedExerciseDF[which(reactVals$selectedExerciseDF$ExamName == examName),]
    }
    else{
      reactVals$tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric())
    }
  })
  
  # Observer: Click on "Save Exam"
  # the points from the temporary dataframe are used to update the "exam-dataframe"
  observeEvent(input$saveExam, {
    examName = input$selectExercise
    reactVals$selectedExerciseDF[which(reactVals$selectedExerciseDF$ExamName == examName),6] = reactVals$tmpExamExercises$Points
  })
  
  # Table-Output: the exercises of the selected exam are shown
  output$exerciseSelector <- renderDataTable({
    reactVals$tmpExamExercises[,c(1,2,3,6)]
  })
  
  # Return-Value of the module
  # the saved exams with points (dataframe) will be returned
  return(
    selectedExerciseDF = reactive({reactVals$selectedExerciseDF})
  )
  
}