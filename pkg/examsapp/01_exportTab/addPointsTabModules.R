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
    selectedExerciseDF = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    #examExercisesList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    examNames = c("---")
  )
  
  observe({
    reactVals$selectedExerciseDF = selectedExerciseList()
    reactVals$examNames = as.vector(unique(c(reactVals$examNames, as.vector(unique(reactVals$selectedExerciseDF$ExamName)))))
    tmpExam = input$selectExercise
    updateSelectInput(session, "selectExercise", choices = reactVals$examNames, selected = tmpExam)
  })
  
  observeEvent(input$setPoints, {
    req(input$pointsExercise)
    if(is.null(input$pointsExercise)){
      showNotification("Please enter a positive number as points.", type = c("error"))
    }
    else{
      rowNumbers = as.vector(input$exerciseSelector_rows_selected)
      if(length(rowNumbers)>0){
        tmpNumberExercises = reactVals$tmpExamExercises[rowNumbers,3]
        rowNumbersUpdate = which(reactVals$tmpExamExercises$Number %in% tmpNumberExercises)
        reactVals$tmpExamExercises[rowNumbersUpdate,5] = rep(as.numeric(input$pointsExercise),length(rowNumbersUpdate))
      }
      else{
        showNotification("Please choose at least one exercise.", type = c("error"))
      }
    }
  })
  
  observeEvent(input$selectExercise, {
    if(input$selectExercise != "---"){
      examName = input$selectExercise
      reactVals$tmpExamExercises = reactVals$selectedExerciseDF[which(reactVals$selectedExerciseDF$ExamName == examName),]
    }
    else{
      reactVals$tmpExamExercises = matrix(c("","","","",""), nrow = 1, ncol=5, byrow = TRUE)
      colnames(reactVals$tmpExamExercises) = c("Foldername", "Filename", "Number", "ExamName", "Points")
    }
  })
  
  observeEvent(input$saveExam, {
    examName = input$selectExercise
    reactVals$selectedExerciseDF[which(reactVals$selectedExerciseDF$ExamName == examName),5] = reactVals$tmpExamExercises$Points
    #print(reactVals$selectedExerciseDF)
  })
  
  output$exerciseSelector <- renderDataTable({
    reactVals$tmpExamExercises[,c(1,2,3,5)]
  })
  
  return(
    selectedExerciseDF = reactive({reactVals$selectedExerciseDF})
  )
  
}