library(shiny)
library(shinyBS)
library(DT)
library(exams)
library(tth)
#library(tidyverse)

## TODO: 
## - seeds matrix for mixed types: chosen seeds and random seeds
## - row reorder for : https://rstudio.github.io/DT/extensions.html, 
##   problem in  https://community.rstudio.com/t/getting-the-rowreorder-extension-to-work-in-a-shiny-datatable/71414
##   possible solution in https://atchen.me/code/2019/04/09/datatables-rowreorder.html

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
               column(12,
                 fluidRow(
               column(6,
                      fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                      column(12,
                             DT::dataTableOutput(ns("exerciseSelector")),
                             fluidRow(style='margin-right:5px',align="right",
                                      conditionalPanel(condition = "input.seedSelection == 0",ns = ns,actionButton(ns("addExerciseToList"), label = "Add to list ",style='margin-top:10px')),
                                      conditionalPanel(condition = "input.seedSelection == 1",ns = ns,actionButton(ns("addExerciseWithSeedToList"), label = "Add to list with seed",style='margin-top:10px'))
                      ))
             ),
             br(),
             br(),
             fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
               column(12,
                      DT::dataTableOutput(ns("choosenExercisesTable"))
               ),
                fluidRow(style='margin-right:5px',align="right",
                         actionButton(ns("blockExercises"), label = "Block",style='margin-top:10px'),
                         actionButton(ns("unblockExercises"), label = "Unblock",style='margin-top:10px'),
                         actionButton(ns("deleteExerciseFromList"), label = "Delete Exercise",style='margin-top:10px')
                        )
             ),
             br(),
             br(),
            #  fluidRow(
            #    checkboxInput(ns("arrangeExercises"), label = "arrange the exercises in different exams", value = FALSE),
               
            #    conditionalPanel(condition = "input.arrangeExercises == 1",
            #                     ns = ns,
            #                     checkboxInput(ns("randomNumbering"), label = "Generate Random Numbering of Exercises")
            #                     )
            #  ),
             fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
               column(4,
                      selectInput(ns("examNameDropDown"), label = "Choose your Exam:", choices = c("make new exam"))
                      ),
                column(4,                     
                      conditionalPanel(condition = "input.examNameDropDown == 'make new exam'",
                                       ns = ns,
                                      #  tags$head(
                                      #    tags$style(type="text/css", "#inline label{ display: table-cell; text-align: center; vertical-align: middle; } 
                                      #                 #inline .form-group { display: table-row;}")
                                      #  ),
                                      #tags$div(id = "inline", textInput(inputId = ns("examName"), label = "Name of the exam:"))
                                      textInput(inputId = ns("examName"), label = "Name of the exam:")
                                      )
                      
               ),
               column(4,align="right",
                      actionButton(ns("saveExam"), label = "Save exam", style = 'margin-top:25px')
                      )
             )
             
           ),
           column(6,
                  fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                   checkboxInput(ns("seedSelection"), label = "Choose specific seeds (implies single file selection)",width = "100%"),
   #                actionButton(ns("myButton"), label = "My  Button"),verbatimTextOutput(ns("outFlorian"), placeholder = T),
                   conditionalPanel(condition = "input.seedSelection == 1",
                                    ns = ns, actionButton(ns("newSeeds"), label = "New Seeds")),
                  conditionalPanel(condition = "input.seedSelection == 1",
                                   ns = ns, uiOutput(ns("playerSeed"), inline = TRUE, container = div))
                  
               ))
          )
           )
          )))
}

chooseTabLogic <- function(input, output, session, pathToFolder, possibleExerciseList, selectedExerciseList, seedList){
  
  ## FS: necessary for renderUI ?!?
  ns <- session$ns
  
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
    # list of three seeds, which are stated in the app.R
    seedList = c(),
    # html output of a exercise with seed 1
    ex1 = NULL,
    # html output of a exercise with seed 2
    ex2 = NULL,
    # html output of a exercise with seed 3
    ex3 = NULL,
    # flag to allow seed selection
    setSeedSelection = FALSE,
    florian = "Standard"
  )
  
  # Observer to store the parameters given by the function chooseTabLogic(...) in reactive values ##### 
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardizesed pattern to call the data is given  
  observe({
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$possibleExercises = possibleExerciseList()
    reactVals$listExamExercises = selectedExerciseList()
    reactVals$seedList = seedList()
  })
  
  # Observer: Click on Button "New seeds" #####
  observeEvent(input$newSeeds, {
    reactVals$seedList <- sample(0L:1e8L,3)
  })
  
  ##############
  # 
  # observeEvent(input$myButton, {
  #   reactVals$florian <- paste0("Hallo 2: ",paste(input$chooseSeed, collapse = ", "))
  # })
  # 
  # output$outFlorian <- renderText({ paste0(reactVals$florian) })
  # 
  
  ##############
  
  
  # Observer: Click on Button "Choose specific seeds" #####
  # TRUE "Choose specific seeds" implies single file selection in "Choose Exercise" and in "Added Exercises"
  observeEvent(input$seedSelection, {
    reactVals$setSeedSelection = input$seedSelection == 1
  })
  
  # Observer: Click on Button "Add to list" #####
  # the exercise is added to the temporary exam list (it is the default case with random seed)
  observeEvent(input$addExerciseToList, {
    rowNumbers = input$exerciseSelector_rows_selected
    if(length(rowNumbers) > 0){
      for(i in 1:length(rowNumbers)){
        # add the exercise to list, if they are unique
        #if(!(reactVals$possibleExercises[rowNumbers[i],2] %in% reactVals$tmpExamExercises$Filename)){
          reactVals$tmpExamExercises = rbind(reactVals$tmpExamExercises, data.frame(Foldername = reactVals$possibleExercises[rowNumbers[i],1],
                                                                                    Filename = reactVals$possibleExercises[rowNumbers[i],2],
                                                                                    Number = reactVals$numberExercises, Seed = NA))
          #increment number of exercises
          reactVals$numberExercises = reactVals$numberExercises + 1
        #}
      }
    }
    else{
      #error message if no exercise is selected
      showNotification("You have to choose at least one exercise.", type = c("error"))
    }
  })
  
  # Observer: Click on Button "Add to list with seed" #####
  # the exercise(s) are added to the temporary exam list and the chosen seed is listed
  observeEvent(input$addExerciseWithSeedToList,{
    rowNumbers = input$exerciseSelector_rows_selected
    numberChosenSeeds <- length(input$chooseSeed)
    if(numberChosenSeeds > 0){
      for(i in 1:numberChosenSeeds){
        reactVals$tmpExamExercises <- rbind(reactVals$tmpExamExercises,
                                        data.frame(Foldername = reactVals$possibleExercises[rowNumbers[1],1],
                                                   Filename = reactVals$possibleExercises[rowNumbers[1],2],
                                                   Number = reactVals$numberExercises, 
                                                   Seed = input$chooseSeed[i]))
        #increment number of exercises
        reactVals$numberExercises = reactVals$numberExercises + 1
      }
    }
    else{
      #error message if no exercise is selected
      showNotification("You have to choose at least one seed", type = c("error"))
    }
  
    
    })
  

  # Observer: Click on "Delete Exercises" #####
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
  

  # Seed preview: all-in-one solution #####

  
  file2htmlOutput <- function(file,seed=0) {
    tmpFilename <- paste0("preview",seed)
    # generating the html-outputs of the exercise
    fromFile = file.path(reactVals$pathToTmpFolder,"exercises", file)
    toFile = file.path(reactVals$pathToTmpFolder, "tmp")
    fileDest = file.path(reactVals$pathToTmpFolder, "tmp", file)
    file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    fileHTML <- try(exams2html(fileDest, n = 1, name = tmpFilename, dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                                    edir = file.path(reactVals$pathToTmpFolder, "tmp"), seed=seed, solution=FALSE,
                                    base64 = TRUE, mathjax = TRUE), silent = TRUE)
    
    if(!inherits(fileHTML, "try-error")){
      hf = paste0(tmpFilename,"1.html")
      html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid #5e5e5e;border-radius:5px;padding:8px;margin:8px">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToTmpFolder, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToTmpFolder, "tmp", hf)))
    }
    else {
      return(HTML(paste('<div>', fileHTML, '</div>')))
    }
  }
  
  # Output: HTML Output of exercises with seeds
  
  output$playerSeed <- renderUI({
    rowNumber = input$exerciseSelector_rows_selected
    if(length(rowNumber)!=1){
      tagList(br(),p("Please select an exercise!"))
      #showNotification("Please select only one exercise!", type = c("error"))
    } else {
    selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
    file <- selectedRow$Filename
    tagList(
      fluidRow(
        column(12,br(),        
               checkboxGroupInput(ns("chooseSeed"), "Choose seed:",
                                  choiceNames =
                                    list(file2htmlOutput(file,seed = reactVals$seedList[1]),
                                         file2htmlOutput(file,seed = reactVals$seedList[2]),
                                         file2htmlOutput(file,seed = reactVals$seedList[3])),
                                  choiceValues =
                                    list(reactVals$seedList[1], reactVals$seedList[2], reactVals$seedList[3]),width='100%')
               # div(checkboxInput("cbSeed1", file2htmlOutput(file,seed = 2),width='100%'),style='max-height: 250px;overflow-y: auto;'),
               # div(checkboxInput("cbSeed2", file2htmlOutput(file,seed = 20),width='100%'),style='max-height: 250px;overflow-y: auto;'),
               # div(checkboxInput("cbSeed3", file2htmlOutput(file,seed = 200),width='100%'),style='max-height: 250px;overflow-y: auto;'),
               # 
        )))
    }
    })
  


  # Observer: Click on "Save Exam" #####
  # either a new exam is generated or a existing exam is overwritten with the new exercises, points, blockings...
  # it is stored in a datatable
  observeEvent(input$saveExam, {
    # a existing exam is selected
    if(input$examNameDropDown != "make new exam"){
      reactVals$listExamExercises = reactVals$listExamExercises[!(reactVals$listExamExercises$ExamName %in% input$examNameDropDown),]
      ExamName = rep(input$examNameDropDown, nrow(reactVals$tmpExamExercises)) 
      Points = rep(0, nrow(reactVals$tmpExamExercises))
      reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
    }
    # a new exam is generated - name must be unique
    else{
      req(input$examName)
      if(!(input$examName %in% reactVals$examNames)){
        reactVals$examNames = c(reactVals$examNames, input$examName)
        ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises)) 
        Points = rep(0, nrow(reactVals$tmpExamExercises))
        reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
        
        # updating the Drop Down List with the new exam name
        updateSelectInput(session, "examNameDropDown", choices = reactVals$examNames, selected = input$examName)
        updateTextInput(session, "examName", value = "")
      }
      else{
        showNotification("The name already exists. Please choose another name or select the Exam in the Drop Down List.",type = c("error"))
      }
    }
  })

  # observeEvent(input$saveExam, {
  #   # a existing exam is selected
  #   if(input$examNameDropDown != "make new exam"){
  #     reactVals$listExamExercises = reactVals$listExamExercises[!(reactVals$listExamExercises$ExamName %in% input$examNameDropDown),]
  #     ExamName = rep(input$examNameDropDown, nrow(reactVals$tmpExamExercises)) 
  #     Points = rep(0, nrow(reactVals$tmpExamExercises))
  #     reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
  #     if(input$examNameDropDown %in% reactVals$randomNumberingExams$Examname){
  #       reactVals$randomNumberingExams[which(reactVals$randomNumberingExams$Examname == input$examNameDropDown), 2] = input$randomNumbering
  #     }
  #     else{
  #       reactVals$randomNumberingExams = rbind(reactVals$randomNumberingExams, data.frame(Examname=input$examNameDropDown, RandomNumber=input$randomNumbering))
  #     }
  #     print(reactVals$randomNumberingExams)
  #   }
  #   # a new exam is generated - name must be unique
  #   else{
  #     req(input$examName)
  #     if(!(input$examName %in% reactVals$examNames)){
  #       reactVals$examNames = c(reactVals$examNames, input$examName)
  #       ExamName = rep(input$examName, nrow(reactVals$tmpExamExercises)) 
  #       Points = rep(0, nrow(reactVals$tmpExamExercises))
  #       reactVals$listExamExercises = rbind(reactVals$listExamExercises, cbind(reactVals$tmpExamExercises, ExamName, Points))
  #       reactVals$randomNumberingExams = rbind(reactVals$randomNumberingExams, data.frame(Examname=input$examName, RandomNumber=input$randomNumbering))
  #       print(reactVals$randomNumberingExams)
        
  #       # updating the Drop Down List with the new exam name
  #       updateSelectInput(session, "examNameDropDown", choices = reactVals$examNames, selected = input$examName)
  #       updateTextInput(session, "examName", value = "")
  #     }
  #     else{
  #       showNotification("The name already exists. Please choose another name or select the Exam in the Drop Down List.",type = c("error"))
  #     }
  #   }
  # })
  
  # function inserts a row into a existing dataframe on given rownumber #####
  # @param existingDF: existing Dataframe
  # @param newrow: new row with equal columns to existing dataframe
  # @param rowNum: row number of the new row in the existing dataframe
  # return: the dataframe including the new row
  insertRow <- function(existingDF, newrow, rowNum){
    if (rowNum > nrow(existingDF)) {
      existingDF <- rbind(existingDF,newrow)
    } else {
      existingDF[seq(rowNum+1,nrow(existingDF)+1),] = existingDF[seq(rowNum,nrow(existingDF)),]
      existingDF[rowNum,] = newrow
    }
    return(existingDF)
  }
  
  # Observer: Click on "Block" #####
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
      # baseData = na.omit(baseData)
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
  
  # Observer: Click on "Unblock" #####
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
  
  # Table-Output: possible exercises (pre-selected exercises from load tab) #####
  output$exerciseSelector <- renderDataTable({
    reactVals$possibleExercises
  }, selection = ifelse(reactVals$setSeedSelection,'single','multiple'))
  
  # Table-Output: selected exercises (including numeration and blocking) #####
  output$choosenExercisesTable <- DT::renderDataTable({
    reactVals$tmpExamExercises[,c("Foldername","Filename","Number","Seed")]}
    # editable = TRUE, 
    # rownames = TRUE,
    # extensions = 'RowReorder',
    # options = list(order = list(list(0, 'asc')),rowReorder = TRUE)
  )

  
  # Return-Value of the module  #####
  # the saved exams (dataframe) will be returned
  return(
    listExamExercises = reactive({reactVals$listExamExercises})#,
    #randomNumbering = reactive({reactVals$randomNumberingExams})
  )
}