library(shiny)
library(DT)
library(exams)
library(tth)
#library(tidyverse)

chooseTabUI <- function(id){
  
  ns = NS(id)
  
  tabPanel("Choose and Arrange",
           
           tagList(
             
             fluidRow(
               column(9,
                      DT::dataTableOutput(ns("exerciseSelector"))
                      )
             ),
             
             fluidRow(
               br(),
               column(7),
               column(2,
                      actionButton(ns("addExerciseToList"), label = "Choose Exercises")
                      )
             ),
             br(),
             br(),
             fluidRow(
               column(9,
                      DT::dataTableOutput(ns("choosenExercisesTable"))
               )
             ),
             
             fluidRow(
               column(4),
               column(1,
                      actionButton(ns("blockExercises"), label = "Block")
               ),
               column(2,
                      actionButton(ns("unblockExercises"), label = "Unblock")
               ),
               column(2,
                      actionButton(ns("deleteExerciseFromList"), label = "Delete Exercise")
               )
             ),
             br(),
             br(),
             fluidRow(
               checkboxInput(ns("arrangeExercises"), label = "arrange the exercises in different exams", value = FALSE),
               
               conditionalPanel(condition = "input.arrangeExercises == 1",
                                ns = ns,
                                checkboxInput(ns("randomNumbering"), label = "Generate Random Numbering of Exercises")
                                )
             ),
             fluidRow(
               column(4),
               column(5,
                      tags$head(
                        tags$style(type="text/css", "#inline label{ display: table-cell; text-align: center; vertical-align: middle; } 
                                  #inline .form-group { display: table-row;}")
                      ),
                      tags$div(id = "inline", textInput(inputId = ns("examName"), label = "Name of the exam:"))
                      #textInput(ns("examName"), label = "Name of the exam: ")
               ),
               column(3,
                      actionButton(ns("saveExam"), label = "Save exam")
                      )
             )
             
           )
  )
}

chooseTabLogic <- function(input, output, session, pathToFolder, possibleExerciseList, selectedExerciseList){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL,
    possibleExercises = data.frame(Foldername=character(), Filename=character()),
    tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric()),
    listExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character()),
    numberExercises = 1,
    randomNumbering = FALSE
  )
  
  observe({
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$possibleExercises = possibleExerciseList()
    reactVals$listExamExercises = selectedExerciseList()
    reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, reactVals$listExamExercises[,1:3])
    #reactVals$tmpExamExercises = reactVals$tmpExamExercises[!duplicated(reactVals$tmpExamExercises)]
  })
  
  observeEvent(input$addExerciseToList, {
    rowNumbers = input$exerciseSelector_rows_selected
    #print(rowNumbers)
    if(length(rowNumbers) > 0){
      for(i in 1:length(rowNumbers)){
        if(!(reactVals$possibleExercises[rowNumbers[i],2] %in% reactVals$tmpExamExercises$Filename)){
          #print(reactVals$possibleExercises[rowNumbers[i],2])
          reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, data.frame(Foldername = reactVals$possibleExercises[rowNumbers[i],1],
                                                                            Filename = reactVals$possibleExercises[rowNumbers[i],2],
                                                                            Number = reactVals$numberExercises))
          reactVals$numberExercises = reactVals$numberExercises + 1
        }
      }
    }
    else{
      showNotification("You have to choose at least one exercise.", type = c("error"))
    }
  })
  
  observeEvent(input$deleteExerciseFromList, {
    rowNumbers = input$choosenExercisesTable_rows_selected
    reactVals$tmpExamExercises = reactVals$tmpExamExercises[-rowNumbers, ]
    reactVals$numberExercises = reactVals$numberExercises - length(rowNumbers)
  })
  
  output$exerciseSelector <- renderDataTable({
    reactVals$possibleExercises
  })
  
  output$choosenExercisesTable <- renderDataTable({
    reactVals$tmpExamExercises
  })
  
}