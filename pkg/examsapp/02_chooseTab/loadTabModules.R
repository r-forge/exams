library(shiny)
library(DT)
library(exams)
library(tth)

loadTabUI <- function(id){
  
  ns = NS(id)
  tabPanel("Load Exercises",
    tagList(
      fluidRow(
        column(6,
               DT::dataTableOutput(ns("folderSelector"))
        ),
        column(6,
               DT::dataTableOutput(ns("fileSelector"))
        )
      ),
      br(),
      br(),
      fluidRow(
        column(6),
        column(6,
               
               column(6,
                      actionButton(ns("previewShow"), label = "Show Preview")
               ),
               column(6,
                      actionButton(ns("addExcerciseToList"), label = "Add Exercise(s)")
               ),
               br(),
               br(),
               uiOutput(ns("player"), inline = TRUE, container = div)
               
        )
      ),
      fluidRow(
        checkboxInput(ns("addedExerciseShow"), label = "Show added exercise(s)", value = FALSE),
        
        conditionalPanel(condition = "input.addedExerciseShow == 1",
                         ns = ns,
                         DT::dataTableOutput(ns("outputAddedFiles"))
                         
        ),
        
        checkboxInput(ns("loadSingleFile"), label = "load exercise from local storage"),
        
        conditionalPanel(condition = "input.loadSingleFile == 1",
                         ns = ns,
                         column(9,
                                fileInput(ns("inputLocalFile"), label="", multiple = FALSE, accept = c(".Rmd", ".Rnw"))
                         ),
                         column(3,
                                br(),
                                actionButton(ns("addLocalExercise"), label = "Add exercise")
                         )
                         
        )
        
        
      )
    )
  )
}


loadTabLogic <- function(input, output, session, pathExercisesGiven, pathToFolder, possibleExerciseList, givenExercises){
  reactVals <- reactiveValues(
    path = NULL,
    dirFileList = NULL,
    pathToTmpFolder = NULL,
    currentFiles = c(),
    selectedFiles = data.frame(Foldername=character(), Filename=character()),
    selectedFolder = NULL,
    initOpen = TRUE,
    tmpFileFlag = TRUE,
    setPreview = FALSE
  )
  
  observe({
    reactVals$path = pathExercisesGiven()
    reactVals$dirFileList = givenExercises()
    reactVals$pathToTmpFolder = pathToFolder()
    reactVals$selectedFiles = possibleExerciseList()
  })
  
  savingExercisesToTmp <- function(dataframeFiles){
    #print(reactVals$pathToTmpFolder)
    for(i in 1:length(dataframeFiles[,1])){
      file.copy(from=file.path(reactVals$path, dataframeFiles[,1][i], dataframeFiles[,2][i]), 
                to=file.path(reactVals$pathToTmpFolder, "exercises"), overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    }
  }
  
  observeEvent(input$addExcerciseToList, {
    #print("hello")
    if(length(input$fileSelector_rows_selected) > 0){
      selectedFiles = reactVals$currentFiles[input$fileSelector_rows_selected]
      for(i in 1:length(selectedFiles)){
        if(!(selectedFiles[i] %in% reactVals$selectedFiles$Filename)){
          reactVals$selectedFiles = rbind(reactVals$selectedFiles, data.frame(Foldername = reactVals$selectedFolder, 
                                                                              Filename = selectedFiles[i]))
        }
      }
    }
    savingExercisesToTmp(reactVals$selectedFiles)
  })
  
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
  
  observeEvent(input$previewShow, {
    reactVals$setPreview = as.numeric(input$previewShow) %% 2 == 1
  })
  
  output$folderSelector <- renderDataTable({
    m = matrix(names(reactVals$dirFileList))
    colnames(m) = c("Choose a folder")
    return(m)
  }, selection = 'single', option = list(pageLength = 5))
  
  output$fileSelector <- renderDataTable({
    
    reactVals$selectedFolder = names(reactVals$dirFileList[input$folderSelector_rows_selected])
    if(length(input$folderSelector_rows_selected) <= 0){
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
    else{
      #print(reactVals$path)
      reactVals$currentFiles = list.files(path = file.path(reactVals$path,reactVals$selectedFolder))
      m = matrix(reactVals$currentFiles)
      colnames(m) = c("Choose exercises")
      return(m)
    }
  }, option = list(pageLength = 5))
  
  output$outputAddedFiles <- renderDataTable({
    reactVals$selectedFiles
  })
  
  output$player <- renderUI({
    if(reactVals$setPreview){
      if(length(input$fileSelector_rows_selected) != 1){
        showNotification("You have to choose one exercise to show the preview.", type = c("error"))
        return(NULL)
      }
      else{
        selectedFile = reactVals$currentFiles[input$fileSelector_rows_selected[1]]
        fromFile = file.path(reactVals$path, reactVals$selectedFolder, selectedFile)
        toFile = file.path(reactVals$pathToTmpFolder, "tmp")
        fileDest = file.path(reactVals$pathToTmpFolder, "tmp", selectedFile)
        file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
        encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
        ex <- try(exams2html(fileDest, n = 1, name = "preview", dir = file.path(reactVals$pathToTmpFolder, "tmp"), 
                             edir = file.path(reactVals$pathToTmpFolder, "tmp"),
                             base64 = TRUE, encoding = encoding, mathjax = TRUE), silent = TRUE)
        if(!inherits(ex, "try-error")){
          hf = "preview1.html"
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
      }
    }
    else return(NULL)
  })
  
  return(
    selectedFiles = reactive({reactVals$selectedFiles})
  )
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