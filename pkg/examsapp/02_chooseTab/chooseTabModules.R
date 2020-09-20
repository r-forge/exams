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
                      selectInput(ns("examNameDropDown"), label = "Choose your Exam:", choices = c("make new exam")),
                      
                      conditionalPanel(condition = "input.examNameDropDown == 'make new exam'",
                                       ns = ns,
                                       tags$head(
                                         tags$style(type="text/css", "#inline label{ display: table-cell; text-align: center; vertical-align: middle; } 
                                                      #inline .form-group { display: table-row;}")
                                       ),
                                       tags$div(id = "inline", textInput(inputId = ns("examName"), label = "Name of the exam:"))
                                       #textInput(ns("examName"), label = "Name of the exam: ")
                                       )
                      
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
    examNames = c("make new exam"),
    randomNumbering = FALSE,
    randomNumberingExams = data.frame(Examname=character(), RandomNumber=logical())
  )
  
  observe({
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$possibleExercises = possibleExerciseList()
    reactVals$listExamExercises = selectedExerciseList()
    #reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, reactVals$listExamExercises[,1:3])
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
    rowNumbers = as.vector(input$choosenExercisesTable_rows_selected)
    if(!is.null(rowNumbers)){
      #reactVals$tmpExamExercises = reactVals$tmpExamExercises[-rowNumbers, ]
      #reactVals$numberExercises = reactVals$numberExercises - length(unique(rowNumbers))
      baseData = reactVals$tmpExamExercises
      baseData = baseData[-rowNumbers,]
      #print(rowNumbers)
      #rowNumbers = rowNumbers[rowNumbers <= nrow(tmpData)]
      #print(rowNumbers)
      # for(i in 1:length(rowNumbers)){
      #   if(rowNumbers[i] <= nrow(tmpData)){
      #     if(rowNumbers[i] == nrow(tmpData)){
      #       tmpData[rowNumbers[i],3] = reactVals$numberExercises - 1
      #       ## passt noch nicht :(
      #     }
      #     else if((rowNumbers[i] == 1) && (tmpData[rowNumbers[i]+1, 3] != 1)){
      #       #print(tmpData$Number)
      #       tmpData$Number = tmpData$Number - 1
      #       #print(tmpData$Number)
      #     }
      #     else if(!((tmpData[rowNumbers[i], 3] == tmpData[rowNumbers[i]+1, 3]) || (tmpData[rowNumbers[i], 3] == tmpData[rowNumbers[i]-1, 3]))){
      #       tmpData[seq(rowNumbers[i], nrow(tmpData)),3] = tmpData[seq(rowNumbers[i], nrow(tmpData)),3]-1
      #     }
      #   }
      # }
      #print(reactVals$numberExercises)
      for(i in 1:(nrow(baseData)-1)){
        if((i == 1) && (baseData[i,3] != 1)){
          baseData$Number = baseData$Number - (baseData[i,3] - 1)
        }
        if((baseData[i+1,3]-baseData[i,3])>=2){
          baseData$Number = as.vector(baseData$Number) - c(rep(0,i),rep((baseData[i+1,3]-baseData[i,3]-1),nrow(baseData)-i))
        }
      }
      reactVals$numberExercises = baseData[nrow(baseData),3]+1
      reactVals$tmpExamExercises = baseData
      row.names(reactVals$tmpExamExercises) = NULL
    }
  })
  
  observeEvent(input$saveExam, {
    #req(input$examName)
    if(input$examNameDropDown != "make new exam"){
      #print(reactVals$listExamExercises$ExamName)
      reactVals$listExamExercises = reactVals$listExamExercises[!(reactVals$listExamExercises$ExamName %in% input$examNameDropDown),]
      ExamName = rep(input$examNameDropDown, nrow(reactVals$tmpExamExercises)) 
      reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName))
      #print(reactVals$listExamExercises)
      #updateSelectInput(session, "examNameDropDown", selected = input$examNameDropDown)
      print("case1")
    }
    else{
      req(input$examName)
      print("case2")
      if(!(input$examName %in% reactVals$examNames)){
        reactVals$examNames = c(reactVals$examNames, input$examName)
        ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises)) 
        reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName))
        # reactVals$listExamExercises = rbind(reactVals$listExamExercises,
        #                                     data.frame(Foldername = reactVals$tmpExamExercises[,1],
        #                                                Filename = reactVals$tmpExamExercises[,2],
        #                                                Number = reactVals$tmpExamExercises[,3],
        #                                                ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises))))
        
        #print(reactVals$tmpExamExercises)
        print(reactVals$listExamExercises)
        #print(nrow(reactVals$listExamExercises))
       
        updateSelectInput(session, "examNameDropDown", choices = reactVals$examNames, selected = input$examName)
        updateTextInput(session, "examName", value = "")
      }
      else{
        showNotification("The name already exists. Please choose another name or select the Exam in the Drop Down List.",type = c("error"))
      }
    }
    if(input$randomNumbering){
      # random numbering is missing
    }
  })
  
  insertRow <- function(existingDF, newrow, rowNum){
    existingDF[seq(rowNum+1,nrow(existingDF)+1),] = existingDF[seq(rowNum,nrow(existingDF)),]
    existingDF[rowNum,] = newrow
    return(existingDF)
  }
  
  observeEvent(input$blockExercises, {
    rowNumbers = sort(as.vector(input$choosenExercisesTable_rows_selected))
    len = length(rowNumbers)
    reactVals$numberExercises = reactVals$numberExercises - (len-1)
    if(len >= 2){
      baseData = reactVals$tmpExamExercises[-rowNumbers[2:len],]
      # for(i in 2:len){
      #    baseData[c(rowNumbers[i]:nrow(baseData)),3] = baseData[c(rowNumbers[i]:nrow(baseData)),3]-1
      # }
      # baseData = na.omit(baseData)
      # print(baseData)
      # tmpData1 = baseData[-c(rowNumbers[1]+1:nrow(baseData)),]
      # tmpData2 = baseData[-c(1:rowNumbers[1]+1),]
      # if(rowNumbers[1] == 1){
      #   tmpData2$Number = na.omit(baseData[c(rowNumbers[1]+2:nrow(baseData)-1),3])
      # }
      # 
      # else if(rowNumbers[len] >= nrow(reactVals$tmpExamExercises)){
      #   tmpData2 = NULL
      # }
      # else {
      #   tmpData2$Number = na.omit(baseData[c(rowNumbers[1]+3:nrow(baseData)-2),3])
      # }
      # tmpData1 = rbind(tmpData1, blockExercises, tmpData2)
      blockExercises = reactVals$tmpExamExercises[rowNumbers[2:len],]
      blockExercises$Number = rep(baseData[rowNumbers[1],3],len-1)
      for(i in 1:(len-1)){
        baseData = insertRow(baseData, blockExercises[i,], rowNumbers[1]+i)
      }
      baseData = na.omit(baseData)
      for(i in 1:(nrow(baseData)-1)){
        if((i == 1) && (baseData[i,3] != 1)){
          baseData$Number = baseData$Number - (baseData[i,3] - 1)
        }
        if((baseData[i+1,3]-baseData[i,3])>=2){
          baseData$Number = as.vector(baseData$Number) - c(rep(0,i),rep((baseData[i+1,3]-baseData[i,3]-1),nrow(baseData)-i))
        }
      }
      reactVals$tmpExamExercises = baseData
      row.names(reactVals$tmpExamExercises) = NULL
    }
    else{
      showNotification("You have to choose at least two exercises.", type = c("error"))
    }
  })
  
  observeEvent(input$unblockExercises, {
    rowNumbers = sort(as.vector(input$choosenExercisesTable_rows_selected))
    len = length(rowNumbers)
    if(len >= 2){
      baseData = reactVals$tmpExamExercises
      if(length(unique(baseData[rowNumbers,3])) == 1){
        for(i in 2:len){
          print(baseData$Number)
          print(c(rep(0,rowNumbers[i]-1),rep(1,nrow(baseData)-rowNumbers[i]+1)))
          baseData$Number = baseData$Number + c(rep(0,rowNumbers[i]-1),rep(1,nrow(baseData)-rowNumbers[i]+1))
        }
        reactVals$numberExercises = baseData[nrow(baseData),3]+1
        reactVals$tmpExamExercises = baseData
        row.names(reactVals$tmpExamExercises) = NULL
      }
      else{
        showNotification("You have to choose blocked exercises.", type = c("error"))
      }
    }
    else{
      showNotification("You have to choose at least two blocked exercises.", type = c("error"))
    }
  })
  
  output$exerciseSelector <- renderDataTable({
    reactVals$possibleExercises
  })
  
  output$choosenExercisesTable <- renderDataTable({
    reactVals$tmpExamExercises
  })
  
}