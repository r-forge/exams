library(shiny)
library(shinyBS)
library(DT)
library(exams)
library(tth)
#library(tidyverse)

chooseTabUI <- function(id){
  
  ns = NS(id)
  
  tabPanel("Choose and Arrange",
           
           tagList(
             fluidRow(
                      radioButtons(ns("seedSelectorRadio"), label = "Wich seed do you prefer?", choices = c("set seed randomly", "select a seed for every exercise"),
                                   inline = TRUE, selected = "set seed randomly")
             ),
             fluidRow(
               column(9,
                      DT::dataTableOutput(ns("exerciseSelector"))
                      )
             ),
             
             fluidRow(
               br(),
               column(7),
               column(2,
                      conditionalPanel(condition = "input.seedSelectorRadio == 'set seed randomly'",
                                       ns = ns,
                                       actionButton(ns("addExerciseToList"), label = "Choose Exercises")
                      ),
                      conditionalPanel(condition = "input.seedSelectorRadio == 'select a seed for every exercise'",
                                       ns = ns,
                                       actionButton(ns("selectSeedOfExercise"), label = "Select Seed")
                      )
                      )
             ),
             bsModal(ns("seedPopUp"), title = "Choose your seed", trigger = ns("selectSeedOfExercise"), size = "large",
                     fluidRow(
                              column(4,
                                     
                                     uiOutput(ns("playerSeed1"), inline = TRUE, container = div),
                                     checkboxInput(ns("cbSeed1"), "Seed 1")
                                     ),
                              column(4,
                                     
                                     uiOutput(ns("playerSeed2"), inline = TRUE, container = div),
                                     checkboxInput(ns("cbSeed2"), "Seed 2")
                              ),
                              column(4,
                                     
                                     uiOutput(ns("playerSeed3"), inline = TRUE, container = div),
                                     checkboxInput(ns("cbSeed3"), "Seed 3"),
                                     actionButton(ns("addExercisesSeed"), label = "Choose Exercise")
                              )
                     )),
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

chooseTabLogic <- function(input, output, session, pathToFolder, possibleExerciseList, selectedExerciseList, seedList){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL,
    possibleExercises = data.frame(Foldername=character(), Filename=character()),
    tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric()),
    listExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    numberExercises = 1,
    examNames = c("make new exam"),
    selectedSeed = -1,
    randomNumbering = FALSE,
    randomNumberingExams = data.frame(Examname=character(), RandomNumber=logical()),
    seedList = c()
  )
  
  observe({
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$possibleExercises = possibleExerciseList()
    reactVals$listExamExercises = selectedExerciseList()
    reactVals$seedList = seedList()
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
                                                                                    Number = reactVals$numberExercises, Seed = -1))
          reactVals$numberExercises = reactVals$numberExercises + 1
        }
      }
    }
    else{
      showNotification("You have to choose at least one exercise.", type = c("error"))
    }
    
    
  })
  
  observeEvent(input$addExercisesSeed, {
    rowNumber = input$exerciseSelector_rows_selected
    if(!(reactVals$possibleExercises[rowNumber,2] %in% reactVals$tmpExamExercises$Filename)){
      reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, data.frame(Foldername = reactVals$possibleExercises[rowNumber,1],
                                                                                Filename = reactVals$possibleExercises[rowNumber,2],
                                                                                Number = reactVals$numberExercises, Seed = reactVals$selectedSeed))
      reactVals$numberExercises = reactVals$numberExercises + 1
    }
    else{
      reactVals$tmpExamExercises[which(reactVals$tmpExamExercises$Filename == reactVals$possibleExercises[rowNumber,2] && 
                                         reactVals$tmpExamExercises$Foldername == reactVals$possibleExercises[rowNumber,1]), 4] = reactVals$selectedSeed
    }
  })
  
  observeEvent(input$cbSeed1, {
    if(input$cbSeed1 == TRUE && reactVals$selectedSeed != 1){
      reactVals$selectedSeed = 1
      updateCheckboxInput(session = session, "cbSeed2", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed1", value = TRUE)
    }
  })
  
  observeEvent(input$cbSeed2, {
    if(input$cbSeed2 == TRUE && reactVals$selectedSeed != 2){
      reactVals$selectedSeed = 2
      updateCheckboxInput(session = session, "cbSeed1", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed2", value = TRUE)
    }
  })
  
  observeEvent(input$cbSeed3, {
    if(input$cbSeed3 == TRUE && reactVals$selectedSeed != 3){
      reactVals$selectedSeed = 3
      updateCheckboxInput(session = session, "cbSeed2", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed1", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = TRUE)
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
  
  observeEvent(input$selectSeedOfExercise, {
    rowNumber = input$exerciseSelector_rows_selected
    if(length(rowNumber)>1){
      showNotification("Please select only one exercise!", type = c("error"))
    }
  })
  
  output$playerSeed1 <- renderUI({
    selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
    print(reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],])
    fromFile = file.path(reactVals$pathToTmpFolder,"exercises", selectedRow$Filename)
    print(fromFile)
    toFile = file.path(reactVals$pathToTmpFolder, "tmp")
    fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedRow$Filename)
    file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    #encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
    # encoding = encoding,
    ex <- try(exams2html(fileDest, n = 1, name = "preview1", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                         edir = file.path(reactVals$pathToTmpFolder, "tmp"),
                         base64 = TRUE, mathjax = TRUE), silent = TRUE)
    if(!inherits(ex, "try-error")){
      hf = "preview11.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:8px;margin:8px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    } else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  
  output$playerSeed2 <- renderUI({
    selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
    print(reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],])
    fromFile = file.path(reactVals$pathToTmpFolder,"exercises", selectedRow$Filename)
    print(fromFile)
    toFile = file.path(reactVals$pathToTmpFolder, "tmp")
    fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedRow$Filename)
    file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    #encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
    # encoding = encoding,
    ex <- try(exams2html(fileDest, n = 1, name = "preview2", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                         edir = file.path(reactVals$pathToTmpFolder, "tmp"),
                         base64 = TRUE, mathjax = TRUE), silent = TRUE)
    if(!inherits(ex, "try-error")){
      hf = "preview21.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:8px;margin:8px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    } else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  
  output$playerSeed3 <- renderUI({
    selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
    print(reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],])
    fromFile = file.path(reactVals$pathToTmpFolder,"exercises", selectedRow$Filename)
    print(fromFile)
    toFile = file.path(reactVals$pathToTmpFolder, "tmp")
    fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedRow$Filename)
    file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    #encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
    # encoding = encoding,
    ex <- try(exams2html(fileDest, n = 1, name = "preview3", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                         edir = file.path(reactVals$pathToTmpFolder, "tmp"),
                         base64 = TRUE, mathjax = TRUE), silent = TRUE)
    if(!inherits(ex, "try-error")){
      hf = "preview31.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:8px;margin:8px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    } else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  

  
  observeEvent(input$saveExam, {
    #req(input$examName)
    if(input$examNameDropDown != "make new exam"){
      #print(reactVals$listExamExercises$ExamName)
      reactVals$listExamExercises = reactVals$listExamExercises[!(reactVals$listExamExercises$ExamName %in% input$examNameDropDown),]
      ExamName = rep(input$examNameDropDown, nrow(reactVals$tmpExamExercises)) 
      Points = rep(0, nrow(reactVals$tmpExamExercises))
      reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
      if(input$examNameDropDown %in% reactVals$randomNumberingExams$Examname){
        reactVals$randomNumberingExams[which(reactVals$randomNumberingExams$Examname == input$examNameDropDown), 2] = input$randomNumbering
      }
      else{
        reactVals$randomNumberingExams = rbind(reactVals$randomNumberingExams, data.frame(Examname=input$examNameDropDown, RandomNumber=input$randomNumbering))
      }
      print(reactVals$randomNumberingExams)
      #print(reactVals$listExamExercises)
      #updateSelectInput(session, "examNameDropDown", selected = input$examNameDropDown)
      #print("case1")
    }
    else{
      req(input$examName)
      #print("case2")
      if(!(input$examName %in% reactVals$examNames)){
        reactVals$examNames = c(reactVals$examNames, input$examName)
        ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises)) 
        Points = rep(0, nrow(reactVals$tmpExamExercises))
        reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
        # reactVals$listExamExercises = rbind(reactVals$listExamExercises,
        #                                     data.frame(Foldername = reactVals$tmpExamExercises[,1],
        #                                                Filename = reactVals$tmpExamExercises[,2],
        #                                                Number = reactVals$tmpExamExercises[,3],
        #                                                ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises))))
        reactVals$randomNumberingExams = rbind(reactVals$randomNumberingExams, data.frame(Examname=input$examName, RandomNumber=input$randomNumbering))
        print(reactVals$randomNumberingExams)
        #print(reactVals$tmpExamExercises)
        #print(reactVals$listExamExercises)
        #print(nrow(reactVals$listExamExercises))
        
        updateSelectInput(session, "examNameDropDown", choices = reactVals$examNames, selected = input$examName)
        updateTextInput(session, "examName", value = "")
      }
      else{
        showNotification("The name already exists. Please choose another name or select the Exam in the Drop Down List.",type = c("error"))
      }
    }
    #if(input$randomNumbering){
    
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
    reactVals$tmpExamExercises[,c(1,2,3)]
  })
  
  return(
    listExamExercises = reactive({reactVals$listExamExercises})#,
    #randomNumbering = reactive({reactVals$randomNumberingExams})
  )
}