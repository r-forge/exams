library(shiny)
library(shinyBS)
library(DT)
library(exams)
library(tth)
library(tools)
#library(tidyverse)

## TODO Julia Petz: 
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
               column(6,#textOutput(ns("showReturn")),
                      fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                               column(4,
                                      selectInput(ns("examDropDown"), label = "Choose your Exam:", choices = c("make new exam"))
                               ),
                               column(4,
                                      textInput(inputId = ns("examName"), label = "Name of the exam:")
                                      ),
                               column(4,align="right",
                                      actionButton(ns("saveExam"), label = "Save exam", style = 'margin-top:25px')
                               )
                      ),
                      br(),
                      br(),
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
                fluidRow(style='margin:5px',
                         column(3,align="left",
                                numericInput(ns("pointsExercise"), label = "Points:", min = 0.1, max = 1000, step = 0.1, value = 1)),
                         column(3,align="left",style="margin-top: 25px",
                                actionButton(ns("setPoints"), label = "Set Points")
                                ),
                         column(6,align="right",style="margin-top: 15px",
                         actionButton(ns("blockExercises"), label = "Block",style='margin-top:10px'),
                         actionButton(ns("unblockExercises"), label = "Unblock",style='margin-top:10px'),
                         actionButton(ns("deleteExerciseFromList"), label = "Delete Exercise",style='margin-top:10px')
                        ))
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

chooseTabServer <-function(id, pathToFolder, pathToExams, tabChanged) {
  stopifnot(is.reactive(pathToFolder))
  stopifnot(is.reactive(pathToExams))
  stopifnot(is.reactive(tabChanged))
  
  moduleServer(id, function(input, output, session) {

  ## FS: necessary for renderUI ?!?
  ns <- session$ns
  
  reactVals <- reactiveValues(
    # path to the temporary folder of the user
    pathToFolderLocal = NULL,
    # selected or adapted or new exam
    currentExam = data.frame(File=character(), Number=numeric(), Points=numeric(), Seed=numeric()),
    # counter for the numeration of exercises
    numberExercises = 1,
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
    # all available exercises, i.e. all files in or added to tmp/exercises
    availableExercises = NULL,
    # all available exams, i.e. all files in or added to tmp/exams
    availableExams = NULL
  )
  
  # ## only for debugging
  # output$showReturn <- renderText({
  #      paste("Output:",paste(reactVals$availableExercises[input$exerciseSelector_rows_selected],collapse = "; "))})
  # 
  
  # Observer to store the parameters given by the function chooseTabLogic(...) in reactive values ##### 
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardizesed pattern to call the data is given  
  observe({
    reactVals$pathToFolderLocal = pathToFolder()
    reactVals$seedList = sample(0L:1e8L,3) #seedList() 
  })
  

  ## Observe: available exercises, i.e. all files in or added to tmp/exercises
  observe({
    e1 <- tabChanged()
    reactVals$availableExercises  <- getExercises(reactVals$pathToFolderLocal)
  })

  ## Observe: available exams, i.e. all files in or added to tmp/exams
  observe({
    e1 <- tabChanged()
    e2 <- input$saveExam
    reactVals$availableExams <- getExams(reactVals$pathToFolderLocal)
  })
  
  ## Oberse: updates the dropdown menu, when new exams are saved or copied into the folder exams
  observe({
  updateSelectInput(session, "examDropDown", choices = c("make new exam",tools::file_path_sans_ext(reactVals$availableExams)),selected = input$examName)
  })
  
  
  ## Reads data from exams json file and updates the numberExercises counter
  observeEvent(input$examDropDown,{
    if (input$examDropDown != "make new exam") {
      reactVals$currentExam <- jsonlite::fromJSON(paste0(file.path(reactVals$pathToFolderLocal,"exams",input$examDropDown),".json"))
      sapply(c("File","Number","Points","Seed"),function(x) if (!(x %in% colnames(reactVals$currentExam))) reactVals$currentExam[,x] <<- NA)
      } else  {reactVals$currentExam = data.frame(File=character(), Number=numeric(), Points=numeric(), Seed=numeric()) }
      
    reactVals$numberExercises <- if(nrow(reactVals$currentExam)>0) reactVals$currentExam$Number[nrow(reactVals$currentExam)]+1 else 1
  })
  
  
  # Observer: Click on Button "New seeds" #####
  observeEvent(input$newSeeds, {
    reactVals$seedList <- sample(0L:1e8L,3)
  })
  

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
        exfiles <- reactVals$availableExercises[rowNumbers[i]]
        reactVals$currentExam <- rbind(reactVals$currentExam,
                                            data.frame(File = exfiles,
                                                       Number = reactVals$numberExercises,
                                                       Points = 1,
                                                       Seed = NA))
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
        exfiles <- reactVals$availableExercises[rowNumbers[i]]
        reactVals$currentExam <- rbind(reactVals$currentExam,
                                       data.frame(File = exfiles,
                                                  Number = reactVals$numberExercises,
                                                  Points = 1,
                                                  Seed = as.numeric(input$chooseSeed[i])))

        reactVals$numberExercises = reactVals$numberExercises + 1
      }
    }
    else{
      #error message if no exercise is selected
      showNotification("You have to choose at least one seed", type = c("error"))
    }
    })
  
  
  # Observer: Click on "Save Exam" 
  observeEvent(input$saveExam, {
    req(input$examName)
    if(!(input$examName %in% tools::file_path_sans_ext(reactVals$availableExams))) {
      exportJson <- jsonlite::toJSON(reactVals$currentExam)
      write(exportJson,paste0(reactVals$pathToFolderLocal,"/exams/",input$examName,".json"))
    }
    else{
      showNotification("The name already exists. Please choose another name.",type = c("error"))
    }
  })
  
  
  

  # Observer: Click on "Delete Exercises" #####
  # one or more exercises should be selected
  observeEvent(input$deleteExerciseFromList, {
    rowNumbers = as.vector(input$choosenExercisesTable_rows_selected)
    if(!is.null(rowNumbers)){
      baseData = reactVals$currentExam
      # the selected exercises are removed
      baseData = baseData[-rowNumbers,]
      # updating the numeration of the exercises, the blocking is not deleted
      if (nrow(baseData)>0) {
      if(baseData$Number[1] != 1) baseData$Number = baseData$Number - baseData$Number[1] + 1
      if (nrow(baseData)>1) {
      for(i in 2:(nrow(baseData))){
        if ((baseData$Number[i]-baseData$Number[i-1])>1) {
          baseData$Number = as.vector(baseData$Number) - c(rep(0,i-1),rep((baseData$Number[i]-baseData$Number[i-1]-1),nrow(baseData)-i+1))
        }
      }
      }
      reactVals$currentExam = baseData 
      reactVals$numberExercises = baseData$Number[nrow(baseData)]+1
      } else {
        ## if all exercises have been deleted
        reactVals$currentExam <- data.frame(File=character(), Number=numeric(), Points=numeric(), Seed=numeric())
        reactVals$numberExercises <- 1
        }
      row.names(reactVals$currentExam) = NULL
    }
  })
  

  
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
      baseData = reactVals$currentExam[-rowNumbers[2:len],]
      # tmp dataframe for the blocked exercises
      blockExercises = reactVals$currentExam[rowNumbers[2:len],]
      # blocked exercises get the lowest exercise number
      blockExercises$Number = rep(baseData$Number[rowNumbers[1]],len-1)
      # insert the rows to dataframe
      for(i in 1:(len-1)){
        baseData = insertRow(baseData, blockExercises[i,], rowNumbers[1]+i)
      }
      # baseData = na.omit(baseData)
      # check the numbering of the exam exercises
      for(i in 1:(nrow(baseData)-1)){
        # adopt the numbering of the exercises by subtracting the difference of two following elements
        if((i == 1) && (baseData$Number[i] != 1)){
          baseData$Number = baseData$Number - (baseData[i,3] - 1)
        }
        if((baseData$Number[i+1]-baseData$Number[i])>=2){
          baseData$Number = as.vector(baseData$Number) - c(rep(0,i),rep((baseData$Number[i+1]-baseData$Number[i]-1),nrow(baseData)-i))
        }
      }
      reactVals$currentExam = baseData
      row.names(reactVals$currentExam) = NULL
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
      baseData = reactVals$currentExam
      # check if only blocked exercises are selected
      if(length(unique(baseData$Number[rowNumbers])) == 1){
        # compute vector to add to numeration of exercises
        for(i in 2:len){
          baseData$Number = baseData$Number + c(rep(0,rowNumbers[i]-1),rep(1,nrow(baseData)-rowNumbers[i]+1))
        }
        reactVals$numberExercises = baseData$Number[nrow(baseData)]+1
        reactVals$currentExam = baseData
        row.names(reactVals$currentExam) = NULL
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
  
  
  # Observer: Click on "Set Points"
  # the points from the numeric input are assigned to the selected exercises
  # blocked exercises get automatically the same amount of points, even if they are not all selected
  observeEvent(input$setPoints, {
    req(input$pointsExercise)
    if(is.null(input$pointsExercise) || !is.numeric(input$pointsExercise)){
      showNotification("Please enter a positive number as points.", type = c("error"))
    }
    else{
      rowNumbers = as.vector(input$choosenExercisesTable_rows_selected)
      if(length(rowNumbers)>0){
        tmpNumberExercises = reactVals$currentExam$Number[rowNumbers]
        rowNumbersUpdate = which(reactVals$currentExam$Number %in% tmpNumberExercises)
        reactVals$currentExam$Points[rowNumbersUpdate] = rep(as.numeric(input$pointsExercise),length(rowNumbersUpdate))
      }
      else{
        showNotification("Please choose at least one exercise.", type = c("error"))
      }
    }
  })
  
  ################### OUTPUT
  
  # Table-Output: All exercises in folder: exercises
  output$exerciseSelector <- renderDataTable({
    exfiles <- reactVals$availableExercises
    reactVals$possibleExercises <- data.frame("Folder" = dirname(exfiles), "File" = basename(exfiles))
    return(reactVals$possibleExercises)
  }, selection = ifelse(reactVals$setSeedSelection,'single','multiple'))
  
 
  # Table-Output: selected exercises (including numeration and blocking) #####
  output$choosenExercisesTable <- DT::renderDataTable({
    data.frame("Folder" = dirname(reactVals$currentExam$File), 
               "File" = basename(reactVals$currentExam$File),
               "Number" = reactVals$currentExam$Number,
               "Points" = reactVals$currentExam$Points,
               "Seed" = reactVals$currentExam$Seed)}
    # editable = TRUE, 
    # rownames = TRUE,
    # extensions = 'RowReorder',
    # options = list(order = list(list(0, 'asc')),rowReorder = TRUE)
  )
  
  
  
  # Seed preview: all-in-one solution #####
  file2htmlOutput <- function(file,seed=0) {
    tmpFilename <- paste0("preview",seed)
    # generating the html-outputs of the exercise
    # fromFile = file.path(reactVals$pathToFolderLocal,"exercises", file)
    # toFile = file.path(reactVals$pathToFolderLocal, "tmp")
    # fileDest = file.path(reactVals$pathToFolderLocal, "tmp", file)
    # file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    
    fileDest <- file
    fileHTML <- try(exams2html(fileDest, n = 1, name = tmpFilename, dir = file.path(reactVals$pathToFolderLocal, "tmp"), 
                               edir = file.path(reactVals$pathToFolderLocal, "tmp"), seed=seed, solution=FALSE,
                               base64 = TRUE, mathjax = TRUE), silent = TRUE)
    
    if(!inherits(fileHTML, "try-error")){
      hf = paste0(tmpFilename,"1.html")
      html = readLines(file.path(reactVals$pathToFolderLocal, "tmp", hf))
      n = c(which(html == "<body>"), length(html))
      html = c(
        html[1L:n[1L]],                  ## header
        '<div style="border: 1px solid #5e5e5e;border-radius:5px;padding:8px;margin:8px">', ## border
        html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
        '</div>', '</br>',               ## border
        html[(n[2L] - 1L):(n[2L])]       ## footer
      )
      writeLines(html, file.path(reactVals$pathToFolderLocal, "tmp", hf))
      return(includeHTML(file.path(reactVals$pathToFolderLocal, "tmp", hf)))
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
      # selectedRow = reactVals$possibleExercises[input$exerciseSelector_rows_selected[1],]
      # file <- selectedRow$Filename
      selectedFile <- reactVals$availableExercises[input$exerciseSelector_rows_selected]
      ## hier weiter
      fileDest = file.path(reactVals$pathToFolderLocal, "exercises", selectedFile)
      tagList(
        fluidRow(
          column(12,br(),        
                 checkboxGroupInput(ns("chooseSeed"), "Choose seed:",
                                    choiceNames =
                                      list(file2htmlOutput(fileDest,seed = reactVals$seedList[1]),
                                           file2htmlOutput(fileDest,seed = reactVals$seedList[2]),
                                           file2htmlOutput(fileDest,seed = reactVals$seedList[3])),
                                    choiceValues =
                                      list(reactVals$seedList[1], reactVals$seedList[2], reactVals$seedList[3]),width='100%')
                 # div(checkboxInput("cbSeed1", file2htmlOutput(file,seed = 2),width='100%'),style='max-height: 250px;overflow-y: auto;'),
                 # div(checkboxInput("cbSeed2", file2htmlOutput(file,seed = 20),width='100%'),style='max-height: 250px;overflow-y: auto;'),
                 # div(checkboxInput("cbSeed3", file2htmlOutput(file,seed = 200),width='100%'),style='max-height: 250px;overflow-y: auto;'),
                 # 
          )))
    }
  })
  
  

  
})
}