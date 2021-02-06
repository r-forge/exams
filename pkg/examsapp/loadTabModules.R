library(shiny)
library(DT)
library(exams)
library(tth)

loadTabUI <- function(id){
  
  ns = NS(id)
  tabPanel("Load Exercises",
   # tags$head(tags$style(HTML(".checkbox {margin-left:15px}"))),
    tagList(
      fluidRow(style='margin:-10px; padding:5px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
        ## FS: Option shinyTree
        column(6,
               DT::dataTableOutput(ns("folderSelector"))
        ),
        column(6,
               DT::dataTableOutput(ns("fileSelector")),
               align="right",
               actionButton(ns("addExcerciseToList"), label = "Add Exercise(s)",style='margin-top:10px')
        )
      ),
      br(),
      br(),
      fluidRow(
        column(6,
          fluidRow(column(12,style='margin: 5px; border: 2px solid #5e5e5e; border-radius: 5px;',checkboxInput(ns("loadSingleFile"), label = "Load exercise from local storage"),
                   conditionalPanel(condition = "input.loadSingleFile == 1",
                                    ns = ns,
                                    column(6,
                                           fileInput(ns("inputLocalFile"), label="", multiple = FALSE, accept = c(".Rmd", ".Rnw"))
                                    ),
                                    column(6,align="right",
                                           br(),
                                           actionButton(ns("addLocalExercise"), label = "Add exercise")
                                    )
                                    
                   ))),
          fluidRow(column(12,style='margin: 5px; padding:5px; border: 2px solid #5e5e5e; border-radius: 5px;',
               checkboxInput(ns("addedExerciseShow"), label = "Show added exercise(s)", value = TRUE),
               conditionalPanel(condition = "input.addedExerciseShow == 1",
                                ns = ns,
                                column(12,DT::dataTableOutput(ns("outputAddedFiles"))),
                                br(),
                                column(12,align="right",actionButton(ns("deleteAddedExerciseFromList"), label = "Delete Exercise",style='margin-top:10px'))
               )
               ))
          ),
        column(6,
               
               column(12,style='margin: 5px; padding:5px; border: 2px solid #5e5e5e; border-radius: 5px;',
                     checkboxInput(ns("previewShow"), label = "Show Preview (implies single file selection)", value = TRUE),
                     uiOutput(ns("player"), inline = TRUE, container = div)
               )
               # column(6,align="right",
               #        actionButton(ns("addExcerciseToList"), label = "Add Exercise(s)")
               # )
               
        )
    )
  )
  )
}

loadTabServer <- function(id, pathExercisesGiven, pathToFolder, possibleExerciseList, givenExercises) {
  stopifnot(is.reactive(pathExercisesGiven))
  stopifnot(is.reactive(pathToFolder))
  stopifnot(is.reactive(possibleExerciseList))
  stopifnot(is.reactive(givenExercises))
  
  moduleServer(id, function(input, output, session) {
  reactVals <- reactiveValues(
    # path to the given exercises (pre-stored data)
    path = NULL,
    # the list of given exercises
    dirFileList = NULL,
    # path to the temporary folder, on which the user has access
    pathToTmpFolder = NULL,
    # all exercises/files in the selected folder (selectedFolder)
    currentFiles = c(),
    # dataframe: stores the folder- and filename of the selected exercises
    selectedFiles = data.frame(Foldername=character(), Filename=character()),
    # store the temporary selected foldername
    selectedFolder = NULL,
    # flag to supress the warnings by opening the app (did not work appropriately)
    initOpen = TRUE,
    # flag to show or hide the preview
    setPreview = FALSE
  )
  
  # Observer to store the parameters given by the function loadTabLogic(...) in reactive values
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardizesed pattern to call the data is given
  observe({
    reactVals$path = pathExercisesGiven()
    reactVals$dirFileList = givenExercises()
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$selectedFiles = possibleExerciseList()

  })    
  
  ## Observer: Exercises can pnly be selected in "Choose Exercise" or in "Added Exercises"
  observe({    
    if (length(input$fileSelector_rows_selected)>0) {
      selectRows(dataTableProxy("fileSelector"), input$fileSelector_rows_selected)
      selectRows(dataTableProxy("outputAddedFiles"), NULL)
    }
  })
  observe({ 
    if (length(input$outputAddedFiles_rows_selected)>0) {
      selectRows(dataTableProxy("outputAddedFiles"), input$outputAddedFiles_rows_selected)
      selectRows(dataTableProxy("fileSelector"), NULL)
    }
})  
  
  
  # function copies all the files in dataframeFiles into the exercises folder in the tmp folder
  # @param dataframeFiles: Dataframe, with foldernames and filenames of the selected exercises
  # return: no return value
  savingExercisesToTmp <- function(dataframeFiles){
    for(i in 1:length(dataframeFiles[,1])){
      file.copy(from=file.path(reactVals$path, dataframeFiles[,1][i], dataframeFiles[,2][i]), 
                to=file.path(reactVals$pathToTmpFolder, "exercises"), overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    }
  }
  
  # Observer: Click on Button "Add Exercise(s)"
  # the selected exercises are appended at the dataframe
  # the dataframe acts like a set - an exercise can only be once in the list
  # the selected exercises are copied automatically to the tmp folder
  observeEvent(input$addExcerciseToList, {
    if(length(input$fileSelector_rows_selected) > 0){
      selectedFiles = reactVals$currentFiles[input$fileSelector_rows_selected]
      for(i in 1:length(selectedFiles)){
        # check if exercise is unique in the selected exercises dataframe
        if(!(selectedFiles[i] %in% reactVals$selectedFiles$Filename)){
          reactVals$selectedFiles = rbind(reactVals$selectedFiles, data.frame(Foldername = reactVals$selectedFolder, 
                                                                              Filename = selectedFiles[i]))
        }
      }
    }
    savingExercisesToTmp(reactVals$selectedFiles)
  })
  
  # Observer: Click on Button "Add exercise" - exercises from local storage
  # the exercise from local storage is uploaded an appended to the dataframe
  # the uploaded exercise is copied automatically to the tmp folder
  observeEvent(input$addLocalExercise, {
    req(input$inputLocalFile)
    if(!is.null(input$inputLocalFile)){
      tmpFilePath = input$inputLocalFile
      reactVals$selectedFiles = rbind(reactVals$selectedFiles, data.frame(Foldername = "from local storage", 
                                                                          Filename = input$inputLocalFile$name))
      file.copy(from=input$inputLocalFile$datapath, to=file.path(reactVals$pathToTmpFolder, "exercises"),
                overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
      file.rename(input$inputLocalFile$datapath,file.path(reactVals$pathToTmpFolder, "exercises", input$inputLocalFile$name))
    }
  })
  
  # Observer: Click on Button "Show Preview"
  # TRUE "Show Preview" implies single file selection in "Choose Exercise" and in "Added Exercises"
  observeEvent(input$previewShow, {
    reactVals$setPreview = input$previewShow == 1
  })
  
  # Observer: Click on "Delete Exercises"
  # one or more exercises should be selected
  observeEvent(input$deleteAddedExerciseFromList, {
    rowNumbers = as.vector(input$outputAddedFiles_rows_selected)
    if(!is.null(rowNumbers)){
      baseData = reactVals$selectedFiles
      # the selected exercises are removed
      baseData = baseData[-rowNumbers,]
      reactVals$selectedFiles = baseData
      row.names(reactVals$selectedFiles) = NULL
    }
  })
  

  # Table-Output: shows all of the folder from given exercises
  # only a single choice is possible
  output$folderSelector <- renderDataTable({
    m = matrix(names(reactVals$dirFileList))
    colnames(m) = c("Choose a folder")
    return(m)
  }, selection = 'single', option = list(pageLength = 5))
  
  # Table-Output: shows all of the exercises in pre-selected folder
  output$fileSelector <- renderDataTable({
    reactVals$selectedFolder = names(reactVals$dirFileList[input$folderSelector_rows_selected])
    # catching the error, if no folder is selected
    if(length(input$folderSelector_rows_selected) <= 0){
      # checking if it is the start of the app - did not work appropriately
      if(reactVals$initOpen == TRUE){
        reactVals$initOpen = FALSE
      }
      else{
        showNotification("You have to choose a folder.", type = c("error"))
      }
      m = matrix("no folder selected", nrow = 1)
      colnames(m) = c("Choose exercises")
      return(m)
    }
    # showing all of the exercises from selected folder
    else{
      reactVals$currentFiles = list.files(path = file.path(reactVals$path,reactVals$selectedFolder))
      m = matrix(reactVals$currentFiles)
      colnames(m) = c("Choose exercises")
      return(m)
    }
  }, selection = ifelse(reactVals$setPreview,'single','multiple'), option = list(pageLength = 5))
  
  # Table-Output: selected exercises are displayed
  output$outputAddedFiles <- renderDataTable({
    reactVals$selectedFiles
  }, selection = ifelse(reactVals$setPreview,'single','multiple'))
  
  # HTML-Output: the preview of a selected exercise is displayed
  output$player <- renderUI({
    # code is only executed if preview should be shown; this implies that maximum one exercises can be selected
    if(reactVals$setPreview){
      if ((length(input$fileSelector_rows_selected) != 1)&(length(input$outputAddedFiles_rows_selected) != 1)){
        showNotification("You have to choose one exercise to show the preview.", type = c("error"))
        return(NULL)
      }
      else{
        # for selected files copy file to tmp folder
        # for added files use file in tmp/exercises folder
        if (length(input$fileSelector_rows_selected) == 1) {
          selectedFile = reactVals$currentFiles[input$fileSelector_rows_selected]
          fromFile = file.path(reactVals$path, reactVals$selectedFolder, selectedFile)
          toFile = file.path(reactVals$pathToTmpFolder, "tmp")
          fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedFile)
          file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
        } 
        else {
          selectedFile <- reactVals$selectedFiles[input$outputAddedFiles_rows_selected,2]
          fileDest = file.path(reactVals$pathToTmpFolder, "exercises", selectedFile)
        }
        # get encoding of the file
        encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
        # trying to get the html format of the exercise
        ex <- try(exams2html(fileDest, n = 1, name = "preview", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                             edir = file.path(reactVals$pathToTmpFolder, "tmp"),
                             base64 = TRUE, encoding = encoding, mathjax = TRUE), silent = TRUE)
        # if no error occures the preview is shown
        if(!inherits(ex, "try-error")){
          hf = "preview1.html"
          html = readLines(file.path(reactVals$pathToTmpFolder, "tmp", hf))
          n = c(which(html == "<body>"), length(html))
          html = c(
            html[1L:n[1L]],                  ## header
            '<div style="border: 1px solid #5e5e5e;border-radius:5px;padding:8px;margin:8px;">', ## border
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
      }
    }
    else return(NULL)
  })
  
  # Return-Value of the module
  # the selected files (dataframe) will be returned
  return(
    selectedFiles = reactive({reactVals$selectedFiles})
  )
})
}

getDirFilesOneLevel <- function(path){
  dirList = list.dirs(path = path, recursive=FALSE);
  dirFileList = list();
  for(i in 1:length(dirList)){
    dirFileList[[i]] = list.files(path = dirList[i]);
  }
  names(dirFileList) = gsub("^.*/","",dirList);
  return(dirFileList)
}