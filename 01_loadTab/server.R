library(shiny)
library(exams)
library(tth)

tmpFileFlag = TRUE

getDirFilesOneLevel <- function(path){
  dirList = list.dirs(path = path, recursive=FALSE);
  dirFileList = list();
  for(i in 1:length(dirList)){
    dirFileList[[i]] = list.files(path = dirList[i]);
  }
  names(dirFileList) = gsub("^.*/","",dirList);
  return(dirFileList)
}
#onStart?
server <- function(input, output, session){
  
  reactVals <- reactiveValues(
    path = "../testExercises",
    dirFileList = getDirFilesOneLevel("../testExercises"),
    pathToExercises = NULL,
    pathToTmp = NULL,
    currentFiles = c(),
    selectedFiles = data.frame(Foldername=character(), Filename=character()),
    selectedFolder = NULL,
    initOpen = TRUE,
    tmpFileFlag = TRUE,
    setPreview = FALSE
  )
  
  savingExercisesToTmp <- function(dataframeFiles){
    #print(reactVals$tmpFileFlag)
    if(reactVals$tmpFileFlag == TRUE){
      reactVals$tmpFileFlag = FALSE
      owd <- getwd()
      dir = NULL
      if(is.null(dir)) {
        dir.create(dir <- tempfile())
        on.exit(unlink(dir))
      }
      dir <- path.expand(dir)
      print(dir)
      if(!file.exists(file.path(dir, "exercises"))) {
        dir.create(file.path(dir, "exercises"))
        reactVals$pathToExercises = file.path(dir, "exercises")
      }
      if(!file.exists(file.path(dir, "tmp"))) {
        dir.create(file.path(dir, "tmp"))
        reactVals$pathToTmp = file.path(dir, "tmp")
      }
      
    }
    #print(reactVals$pathToExercises)
    for(i in 1:length(dataframeFiles[,1])){
      #print(dataframeFiles[,2][i])
      file.copy(from=paste0(reactVals$path,"/", dataframeFiles[,1][i],"/", dataframeFiles[,2][i]), to=reactVals$pathToExercises, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
    }
  }
  
  observeEvent(input$addExcerciseToList, {
    if(length(input$fileSelector_rows_selected) > 0){
      selectedFiles = reactVals$currentFiles[input$fileSelector_rows_selected]
      for(i in 1:length(selectedFiles)){
        #tmp = c(reactVals$selectedFolder, selectedFiles[i])
        #print(tmp)
        #append(reactVals$selectedFiles, tmp)
        #df %>% add_row(hello = "hola", goodbye = "ciao")
        #print(selectedFiles[i] %in% reactVals$selectedFiles$Filename)
        if(!(selectedFiles[i] %in% reactVals$selectedFiles$Filename)){
          reactVals$selectedFiles = rbind(reactVals$selectedFiles, data.frame(Foldername = reactVals$selectedFolder, Filename = selectedFiles[i]))
          #reactVals$selectedFiles %>% add_row(Foldername = reactVals$selectedFolder, Filename = selectedFiles[i])
        }
      }
    }
    #print(reactVals$selectedFiles)
    savingExercisesToTmp(reactVals$selectedFiles)
    #print(reactVals$selectedFiles)
  })
  
  observeEvent(input$addLocalExercise, {
    #inFile = input$inputLocalFile
    req(input$inputLocalFile)
    if(!is.null(input$inputLocalFile)){
      tmpFilePath = input$inputLocalFile
      reactVals$selectedFiles = rbind(reactVals$selectedFiles, data.frame(Foldername = "from local storage", Filename = input$inputLocalFile$name))
      file.copy(from=input$inputLocalFile$datapath, to=reactVals$pathToExercises, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
      file.rename(input$inputLocalFile$datapath,paste0(reactVals$pathToExercises, "/", input$inputLocalFile$name))
      #file.remove(paste0(reactVals$pathToExercise, "/O.Rmd"))
    }
    #print(tmpFilePath$datapath)
    #file.copy(from=input$loadSingleFile$datapath, to=reactVals$pathToExercises, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
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
      reactVals$currentFiles = list.files(path = paste0(reactVals$path,"/",reactVals$selectedFolder))
      m = matrix(reactVals$currentFiles)
      colnames(m) = c("Choose exercises")
      return(m)
    }
  }, option = list(pageLength = 5))
  
  output$outputAddedFiles <- renderDataTable({
    reactVals$selectedFiles
  })
  
  output$player <- renderUI({
    #print(as.numeric(input$previewShow))
    if(reactVals$setPreview){
      #print(length(as.vector(input$fileSelector_rows_selected)))
      if(length(input$fileSelector_rows_selected) != 1){
        showNotification("You have to choose one exercise to show the preview.", type = c("error"))
        return(NULL)
      }
      else{
        selectedFile = reactVals$currentFiles[input$fileSelector_rows_selected[1]]
        fromFile = file.path(reactVals$path, reactVals$selectedFolder, selectedFile)
        toFile = file.path(reactVals$pathToTmp)
        fileDest = file.path(reactVals$pathToTmp, selectedFile)
        file.copy(from=fromFile, to=toFile, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
        encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
        ex <- try(exams2html(fileDest, n = 1, name = "preview", dir = reactVals$pathToTmp, edir = reactVals$pathToTmp,
                             base64 = TRUE, encoding = encoding, mathjax = TRUE), silent = TRUE)
        if(!inherits(ex, "try-error")){
          hf = "preview1.html"
          html = readLines(file.path(reactVals$pathToTmp, hf))
          n = c(which(html == "<body>"), length(html))
          html = c(
            html[1L:n[1L]],                  ## header
            '<div style="border: 1px solid black;border-radius:5px;padding:8px;margin:8px;">', ## border
            html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
            '</div>', '</br>',               ## border
            html[(n[2L] - 1L):(n[2L])]       ## footer
          )
          writeLines(html, file.path(reactVals$pathToTmp, hf))
          return(includeHTML(file.path(reactVals$pathToTmp, hf)))
        } else {
          return(HTML(paste('<div>', ex, '</div>')))
        }
      }
    }
    else return(NULL)
  })
  
  
}
