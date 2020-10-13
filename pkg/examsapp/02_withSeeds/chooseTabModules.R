library(shiny)
library(shinyBS)
library(DT)
library(exams)
library(tth)
#library(tidyverse)

chooseTabUI <- function(id){
  
  ns = NS(id)
  
  tabPanel("Choose and Arrange",
           tags$head(tags$style(HTML('
              .modal-lg{
                width: 95%;
              }
           '))),
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
             #trigger = ns("selectSeedOfExercise")
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
    # path to the temporary folder of the user
    pathToTmpFolder = NULL,
    # possible exercise list - the exercises selected in the load tab
    possibleExercises = data.frame(Foldername=character(), Filename=character()),
    # temporary exam exercises - are already selected but not yet saved 
    tmpExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric()),
    # saved exam exercises
    listExamExercises = data.frame(Foldername=character(), Filename=character(), Number=numeric(), Seed=numeric(), ExamName=character(), Points=numeric()),
    # counter for the numeration of exercises
    numberExercises = 1,
    # list for all of the exam names
    examNames = c("make new exam"),
    # flag for the selected seed
    selectedSeed = 0,
    # flag for random numbering
    randomNumbering = FALSE,
    # dataframe to specify for every exam if a random numbering should be executed or not
    randomNumberingExams = data.frame(Examname=character(), RandomNumber=logical()),
    # list of three seeds, which are statet in the app.R
    seedList = c(),
    # html output of a exercise with seed 1
    ex1 = NULL,
    # html output of a exercise with seed 2
    ex2 = NULL,
    # html output of a exercise with seed 3
    ex3 = NULL
  )
  
  # Observer to store the parameters given by the function chooseTabLogic(...) in reactive values
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardizesed pattern to call the data is given  
  observe({
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$possibleExercises = possibleExerciseList()
    reactVals$listExamExercises = selectedExerciseList()
    reactVals$seedList = seedList()
  })
  
  # Observer: Click on Button "Choose Exercise"
  # the exercise is added to the temporary exam list (it is the default case with random seed)
  observeEvent(input$addExerciseToList, {
    rowNumbers = input$exerciseSelector_rows_selected
    if(length(rowNumbers) > 0){
      for(i in 1:length(rowNumbers)){
        # add the exercise to list, if they are unique
        if(!(reactVals$possibleExercises[rowNumbers[i],2] %in% reactVals$tmpExamExercises$Filename)){
          reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, data.frame(Foldername = reactVals$possibleExercises[rowNumbers[i],1],
                                                                                    Filename = reactVals$possibleExercises[rowNumbers[i],2],
                                                                                    Number = reactVals$numberExercises, Seed = 0))
          #increment number of exercises
          reactVals$numberExercises = reactVals$numberExercises + 1
        }
      }
    }
    else{
      #error message if no exercise is selected
      showNotification("You have to choose at least one exercise.", type = c("error"))
    }
    
    
  })
  
  # Observer: Click on "Choose Exercise" - in the Pop-Up-Window
  # adds a exercise with selected seed to the list or changes the seed if the exercises is already in the list
  observeEvent(input$addExercisesSeed, {
    rowNumber = input$exerciseSelector_rows_selected
    # append the exercise to the list
    if(!(reactVals$possibleExercises[rowNumber,2] %in% reactVals$tmpExamExercises$Filename)){
      reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, data.frame(Foldername = reactVals$possibleExercises[rowNumber,1],
                                                                                Filename = reactVals$possibleExercises[rowNumber,2],
                                                                                Number = reactVals$numberExercises, Seed = reactVals$selectedSeed))
      reactVals$numberExercises = reactVals$numberExercises + 1
    }
    # change the seed (exercise is already in list)
    else{
      reactVals$tmpExamExercises[which(reactVals$tmpExamExercises$Filename == reactVals$possibleExercises[rowNumber,2] && 
                                         reactVals$tmpExamExercises$Foldername == reactVals$possibleExercises[rowNumber,1]), 4] = reactVals$selectedSeed
    }
  })
  
  # Observer: Checkbox "Seed 1"
  # controls that only this checkbox is true
  observeEvent(input$cbSeed1, {
    if(input$cbSeed1 == TRUE && reactVals$selectedSeed != 1){
      reactVals$selectedSeed = 1
      updateCheckboxInput(session = session, "cbSeed2", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed1", value = TRUE)
    }
  })
  
  # Observer: Checkbox "Seed 2"
  # controls that only this checkbox is true
  observeEvent(input$cbSeed2, {
    if(input$cbSeed2 == TRUE && reactVals$selectedSeed != 2){
      reactVals$selectedSeed = 2
      updateCheckboxInput(session = session, "cbSeed1", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed2", value = TRUE)
    }
  })
  
  # Observer: Checkbox "Seed 3"
  # controls that only this checkbox is true
  observeEvent(input$cbSeed3, {
    if(input$cbSeed3 == TRUE && reactVals$selectedSeed != 3){
      reactVals$selectedSeed = 3
      updateCheckboxInput(session = session, "cbSeed2", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed1", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = TRUE)
    }
  })
  
  # Observer: Click on "Delete Exercises"
  # one or more exercises should be selected
  observeEvent(input$deleteExerciseFromList, {
    rowNumbers = as.vector(input$choosenExercisesTable_rows_selected)
    if(!is.null(rowNumbers)){
      baseData = reactVals$tmpExamExercises
      # the selected exercises are removed
      baseData = baseData[-rowNumbers,]
      # updating the numeration of the exercises
      # the blocking is not deleted
      for(i in 1:(nrow(baseData)-1)){
        if((i == 1) && (baseData[i,3] != 1)){
          baseData$Number = baseData$Number - (baseData[i,3] - 1)
        }
        if((baseData[i+1,3]-baseData[i,3])>=2 && (i+1 < (nrow(baseData)-1))){
          baseData$Number = as.vector(baseData$Number) - c(rep(0,i),rep((baseData[i+1,3]-baseData[i,3]-1),nrow(baseData)-i))
        }
      }
      reactVals$numberExercises = baseData[nrow(baseData),3]+1
      reactVals$tmpExamExercises = baseData
      row.names(reactVals$tmpExamExercises) = NULL
    }
  })
  
  # Observer: Click on "Select Seed"
  # Problem: the Pop Up opens always
  observeEvent(input$selectSeedOfExercise, {
    rowNumber = input$exerciseSelector_rows_selected
    if(length(rowNumber)>1){
      showNotification("Please select only one exercise!", type = c("error"))
    }
    else{
      # the function toggleModal surpresses all other functions in the app
      # toggleModal(session, "seedPopUp", toggle = "open")
    
      updateCheckboxInput(session = session, "cbSeed2", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed3", value = FALSE)
      updateCheckboxInput(session = session, "cbSeed1", value = FALSE)
      
      # generating the html-outputs of the exercise
      selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
      fromFile = file.path(reactVals$pathToTmpFolder,"exercises", selectedRow$Filename)
      toFile = file.path(reactVals$pathToTmpFolder, "tmp")
      fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedRow$Filename)
      file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
      reactVals$ex1 <- try(exams2html(fileDest, n = 1, name = "preview1", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                                      edir = file.path(reactVals$pathToTmpFolder, "tmp"), seed=reactVals$seedList[1], solution=FALSE,
                                      base64 = TRUE, mathjax = TRUE), silent = TRUE)
      reactVals$ex2 <- try(exams2html(fileDest, n = 1, name = "preview2", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                                      edir = file.path(reactVals$pathToTmpFolder, "tmp"), seed=reactVals$seedList[2], solution=FALSE,
                                      base64 = TRUE, mathjax = TRUE), silent = TRUE)
      reactVals$ex3 <- try(exams2html(fileDest, n = 1, name = "preview3", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                                      edir = file.path(reactVals$pathToTmpFolder, "tmp"), seed=reactVals$seedList[3], solution=FALSE,
                                      base64 = TRUE, mathjax = TRUE), silent = TRUE)
    }
  })
  
  # Output: HTML Output of exercise with seed 1
  output$playerSeed1 <- renderUI({
    if(is.null(reactVals$ex1)){}
    else if(!inherits(reactVals$ex1, "try-error")){
      hf = "preview11.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:3px;margin:3px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    } 
    else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  
  # Output: HTML Output of exercise with seed 2
  output$playerSeed2 <- renderUI({
    if(is.null(reactVals$ex2)){}
    else if(!inherits(reactVals$ex2, "try-error")){
      hf = "preview21.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:3px;margin:3px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    } 
    else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  
  # Output: HTML Output of exercise with seed 3
  output$playerSeed3 <- renderUI({
    if(is.null(reactVals$ex3)){}
    else if(!inherits(reactVals$ex3, "try-error")){
      hf = "preview31.html"
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid black;border-radius:5px;padding:3px;margin:3px;">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    }
    else {
      return(HTML(paste('<div>', ex, '</div>')))
    }
  })
  

  # Observer: Click on "Save Exam"
  # either a new exam is generated or a existing exam is overwritten with the new exercises, points, blockings...
  # it is stored in a datatable
  observeEvent(input$saveExam, {
    # a exisiting exam is selected
    if(input$examNameDropDown != "make new exam"){
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
    }
    # a new exam is generated - name must be unique
    else{
      req(input$examName)
      if(!(input$examName %in% reactVals$examNames)){
        reactVals$examNames = c(reactVals$examNames, input$examName)
        ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises)) 
        Points = rep(0, nrow(reactVals$tmpExamExercises))
        reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
        reactVals$randomNumberingExams = rbind(reactVals$randomNumberingExams, data.frame(Examname=input$examName, RandomNumber=input$randomNumbering))
        print(reactVals$randomNumberingExams)
        
        # updating the Drop Down List with the new exam name
        updateSelectInput(session, "examNameDropDown", choices = reactVals$examNames, selected = input$examName)
        updateTextInput(session, "examName", value = "")
      }
      else{
        showNotification("The name already exists. Please choose another name or select the Exam in the Drop Down List.",type = c("error"))
      }
    }
  })
  
  # function inserst a row into a existing dataframe on given rownumber
  # @param existingDF: existing Dataframe
  # @param newrow: new row with equal columns to existing dataframe
  # @param rowNum: row number of the new row in the existing dataframe
  # return: the dataframe including the new row
  insertRow <- function(existingDF, newrow, rowNum){
    existingDF[seq(rowNum+1,nrow(existingDF)+1),] = existingDF[seq(rowNum,nrow(existingDF)),]
    existingDF[rowNum,] = newrow
    return(existingDF)
  }
  
  # Observer: Click on "Block"
  # the blocked exercises get the lowest exercise number
  # if exercises 2, 5 and 7 are blocked -> they all get number 2
  observeEvent(input$blockExercises, {
    rowNumbers = sort(as.vector(input$choosenExercisesTable_rows_selected))
    len = length(rowNumbers)
    # decrement the number of exercises
    reactVals$numberExercises = reactVals$numberExercises - (len-1)
    if(len >= 2){
      # tmp dataframe; blocked exercises are deleted (but not first selected exercises <- orientation point)
      baseData = reactVals$tmpExamExercises[-rowNumbers[2:len],]
      # tmp dataframe for the blocked exercises
      blockExercises = reactVals$tmpExamExercises[rowNumbers[2:len],]
      # blocked exercises get the lowest exercise number
      blockExercises$Number = rep(baseData[rowNumbers[1],3],len-1)
      # insert the rows to dataframe
      for(i in 1:(len-1)){
        baseData = insertRow(baseData, blockExercises[i,], rowNumbers[1]+i)
      }
      baseData = na.omit(baseData)
      # check the numbering of the exam exercises
      for(i in 1:(nrow(baseData)-1)){
        # adopt the numbering of the exercises by subtracting the difference of two following elements
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
    # error message if no exercise or only one exercise is selected
    else{
      showNotification("You have to choose at least two exercises.", type = c("error"))
    }
  })
  
  # Observer: Click on "Unblock"
  # blocked exercises can be unblocked
  # only the numeration of the exercises is changed
  observeEvent(input$unblockExercises, {
    rowNumbers = sort(as.vector(input$choosenExercisesTable_rows_selected))
    len = length(rowNumbers)
    if(len >= 2){
      baseData = reactVals$tmpExamExercises
      # check if only blocked exercises are selected
      if(length(unique(baseData[rowNumbers,3])) == 1){
        # compute vector to add to numeration of exercises
        for(i in 2:len){
          baseData$Number = baseData$Number + c(rep(0,rowNumbers[i]-1),rep(1,nrow(baseData)-rowNumbers[i]+1))
        }
        reactVals$numberExercises = baseData[nrow(baseData),3]+1
        reactVals$tmpExamExercises = baseData
        row.names(reactVals$tmpExamExercises) = NULL
      }
      # error message if not blocked exercises are selected
      else{
        showNotification("You have to choose blocked exercises.", type = c("error"))
      }
    }
    # error message if only one or zero exercises are selected
    else{
      showNotification("You have to choose at least two blocked exercises.", type = c("error"))
    }
  })
  
  # Table-Output: possible exercises (pre-selected exercises from load tab)
  output$exerciseSelector <- renderDataTable({
    reactVals$possibleExercises
  })
  
  # Table-Output: selected exercises (including numeration and blocking)
  output$choosenExercisesTable <- renderDataTable({
    reactVals$tmpExamExercises[,c(1,2,3)]
  })
  
  # Return-Value of the module
  # the saved exams (dataframe) will be returned
  return(
    listExamExercises = reactive({reactVals$listExamExercises})#,
    #randomNumbering = reactive({reactVals$randomNumberingExams})
  )
}