library(shiny)
library(DT)
library(exams)
library(tth)

## FIXME: clicking to fast results in an infinity loop jumping between selected exercises 
## TODO: delete empty folders in exercises
## TODO: do not show subfolders in "Choose exercises" table

loadTabUI <- function(id){
  
  ns = NS(id)
  tabPanel("Load Exercises",
   # tags$head(tags$style(HTML(".checkbox {margin-left:15px}"))),
    tagList(
      fluidRow(column(12,style='margin:5px; padding:10px; padding-top: 15px;',
                      p("Add exercises from your local storage or from the exercises repository to your project."))),
      fluidRow(
        column(6,
               fluidRow(style='margin-left:-10px;margin-right:-10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                               p("Import exercises in", strong('.Rnw'), ",", strong(".Rmd"),
                                 "format, also provided as", strong(".zip"), "or", strong(".tar.gz"), "files from your local storage!"),
                               fileInput(ns("uploadExercises"), NULL, multiple = TRUE,
                                         accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd", "zip", "tar.gz",
                                                    "jpg", "JPG", "png", "PNG"))
               ),
               br(),
               br(),
               fluidRow(style='margin:-10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                        p("Choose exercises from the",strong("exercises repository")," and add them to your project."),br(),
                        ## FS: Option shinyTree
                        column(6,#textOutput(ns("showReturn")),
                               DT::dataTableOutput(ns("folderSelector"))
                        ),
                        column(6,
                               DT::dataTableOutput(ns("fileSelector"))
                               ),
                        column(12,align="right",
                               actionButton(ns("addExcerciseToList"), label = "Add Exercise(s)",style='margin-top:10px')
                        )
               )
        ),
        column(6,
               fluidRow(style='margin-left:-10px;margin-right:-10px; padding:-10px; padding-top: 15px;padding-bottom: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
                        column(12,
                               p("Added exercise(s) to your project."),
                               column(12,DT::dataTableOutput(ns("outputAddedFiles"))),
                                                br(),
                                                column(12,align="right",actionButton(ns("deleteExercises"), label = "Delete Exercise",style='margin-top:10px'))
                               )
               ),
               br(),
               fluidRow(style='margin-left:-10px;margin-right:-10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e; border-radius: 5px;',
               column(12,
                      checkboxInput(ns("previewShow"), label = "Show Preview (implies single file selection)", value = FALSE),
                      uiOutput(ns("player"), inline = TRUE, container = div)
               ))
        )
      ),
      br(),
      br(),

  )
  )
}

loadTabServer <- function(id, pathToFolder,pathToExercisesGiven) {
  stopifnot(is.reactive(pathToExercisesGiven))
  stopifnot(is.reactive(pathToFolder))

  moduleServer(id, function(input, output, session) {
  reactVals <- reactiveValues(
    # path to the temporary folder, on which the user has access
    pathToFolderLocal = NULL,
    # path to the given exercises (pre-stored data)
    pathToExercisesGivenLocal = NULL,
    # the selected folder (or all selected folders), relative path in pathToExercisesGiven
    currentFolder = c(),
    # all exercises/files in the selected folder (selectedFolder)
    currentFiles = c(),
    # flag to supress the warnings by opening the app (did not work appropriately)
    initOpen = TRUE,
    # flag to show or hide the preview
    setPreview = FALSE,
    #  flag after a file is deleted
    fileDeleted = FALSE
  )
  
  # output$showReturn <- renderText({
  #   paste("You have selected", reactVals$currentFiles[input$fileSelector_rows_selected]," and  and ", paste(reactVals$currentFiles[input$fileSelector_rows_selected],collapse="; "))
  #   #paste("You have selected",reactVals$currentFolder)
  # })
  # 
  
  ## Reactive: available exercises, i.e. all files in or added to tmp/exercises
  availableExercises <- reactive({
    e1 <- input$addExcerciseToList
    e2 <- input$uploadExercises
    e3 <- reactVals$fileDeleted
    exfiles <- getExercises(reactVals$pathToFolderLocal)
    return(exfiles)
  })

  # Observer to store the parameters given by the function loadTabLogic(...) in reactive values
  # using reactive values for the data was in the test cases more convenient and furthermore a
  # standardized pattern to call the data is given
  observe({
    reactVals$pathToExercisesGivenLocal = pathToExercisesGiven()
    reactVals$pathToFolderLocal = pathToFolder()
  })    
  
  # Observer to store the selected/current folder
  observe({
    reactVals$currentFolder = setdiff(list.dirs(path = reactVals$pathToExercisesGivenLocal, full.names = FALSE, recursive = TRUE),"")[input$folderSelector_rows_selected]
  })   
  

  ## Observer: Exercises can only be selected in "Choose Exercise" OR in "Added Exercises"
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
  
  
  # Observer: Click on Button "Add Exercise(s)"
  # the selected exercises are copied to the exercise folder
  observeEvent(input$addExcerciseToList, {
    if(length(input$fileSelector_rows_selected) > 0){
      ## creates folder structure from GivenExercises and copy all selected files
      for (myfile in reactVals$currentFiles[input$fileSelector_rows_selected]) {
        newdir <- file.path(reactVals$pathToFolderLocal,"exercises",dirname(myfile))
        if (!dir.exists(newdir)) dir.create(newdir,recursive=T)
        file.copy(myfile,newdir)
      }
    }
  })
  
  # Observer: Exercises from local storage
  ## from exams_shiny.R: the uploaded exercises are copied automatically to the tmp folder
  observeEvent(input$uploadExercises, {
    if(!is.null(input$uploadExercises$datapath)) {
      for(i in seq_along(input$uploadExercises$name)) {
        fext <- tolower(file_ext(input$uploadExercises$name[i]))
        if(fext %in% c("rnw", "rmd")) {
          file.copy(input$uploadExercises$datapath[i], file.path(reactVals$pathToFolderLocal,"exercises", input$uploadExercises$name[i]))
        } else {
          tdir <- tempfile()
          dir.create(tdir)
          owd <- getwd()
          setwd(tdir)
          file.copy(input$uploadExercises$datapath[i], input$uploadExercises$name[i])
          if(fext == "zip") {
            unzip(input$uploadExercises$name[i], exdir = ".")
          } else {
            untar(input$uploadExercises$name[i], exdir = ".")
          }
          file.remove(input$uploadExercises$name[i])
          cf <- dir(tdir)
          file.copy(cf, file.path(reactVals$pathToFolderLocal, "exercises"), recursive = TRUE)
          setwd(owd)
          unlink(tdir)
        }
      }
    }
  })
 
  
  # Observer: Click on Button "Show Preview"
  # TRUE "Show Preview" implies single file selection in "Choose Exercise" and in "Added Exercises"
  observeEvent(input$previewShow, {
    reactVals$setPreview = input$previewShow == 1
  })
  

  # Observer: Click on "Delete Exercises"
  # one or more exercises should be selected
  ## from exams_shiny.R 
  observeEvent(input$deleteExercises, {
    id <- input$outputAddedFiles_rows_selected
    if(length(id)) {
      ex <- availableExercises()
      rmfile <- ex[id]
      if(all(file.exists(file.path(reactVals$pathToFolderLocal,"exercises", rmfile))))
        file.remove(file.path(reactVals$pathToFolderLocal,"exercises", rmfile))
      ex <- ex[-id] 
      reactVals$fileDeleted <- !reactVals$fileDeleted } else {
        NULL
      }
  })
  
  
##### OUTPUT
  
  # Table-Output: shows all of the folder from given exercises
  # only a single choice is possible
  output$folderSelector <- renderDataTable({
    m = matrix(setdiff(list.dirs(path = reactVals$pathToExercisesGivenLocal, full.names = FALSE, recursive = TRUE),""))
    colnames(m) = c("Choose a folder")
    return(m)
  }, selection = 'single', option = list(pageLength = 5))
  

  # Table-Output: shows all of the exercises in selected/current folder
  output$fileSelector <- renderDataTable({
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
      reactVals$currentFiles <- setdiff(list.files(path=file.path(reactVals$pathToExercisesGivenLocal,reactVals$currentFolder),full.names = T),list.dirs(path=file.path(reactVals$pathToExercisesGivenLocal,reactVals$currentFolder),full.names = T))
      m = matrix(basename(reactVals$currentFiles))
      colnames(m) = c("Choose exercises")
      return(m)
    }
  }, selection = ifelse(reactVals$setPreview,'single','multiple'), option = list(pageLength = 5))
 
  
   
  # Table-Output: selected exercises are displayed
  output$outputAddedFiles <- renderDataTable({
    exfiles <- availableExercises()
    data.frame("Folder" = dirname(exfiles), "File" = basename(exfiles))
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
        # for selected files copy file to tmp folder without folder structure
        if (length(input$fileSelector_rows_selected) == 1) {
          selectedFile = reactVals$currentFiles[input$fileSelector_rows_selected]
          fileDest = file.path(reactVals$pathToFolderLocal, "tmp", basename(selectedFile))
          file.copy(from=selectedFile, fileDest, overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
        } 
        # for added files use file in tmp/exercises folder structure
        else {
          selectedFile <- availableExercises()[input$outputAddedFiles_rows_selected]
          fileDest = file.path(reactVals$pathToFolderLocal, "exercises", selectedFile)
        }
        # get encoding of the file
        encoding = stringi::stri_enc_detect(fileDest)[[1]][1,1]
        # trying to get the html format of the exercise
        ex <- try(exams2html(fileDest, n = 1, name = "preview", dir = file.path(reactVals$pathToFolderLocal, "tmp"), 
                             edir = file.path(reactVals$pathToFolderLocal, "tmp"),
                             base64 = TRUE, encoding = encoding, mathjax = TRUE), silent = TRUE)
        # if no error occures the preview is shown
        if(!inherits(ex, "try-error")){
          hf = "preview1.html"
          html = readLines(file.path(reactVals$pathToFolderLocal, "tmp", hf))
          n = c(which(html == "<body>"), length(html))
          html = c(
            html[1L:n[1L]],                  ## header
            '<div style="border: 1px solid #5e5e5e;border-radius:5px;padding:8px;margin:8px;">', ## border
            html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
            '</div>', '</br>',               ## border
            html[(n[2L] - 1L):(n[2L])]       ## footer
          )
          writeLines(html, file.path(reactVals$pathToFolderLocal, "tmp", hf))
          return(includeHTML(file.path(reactVals$pathToFolderLocal, "tmp", hf)))
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
  # return(
  #   selectedFiles = reactive({reactVals$selectedFiles})
  # )
})
}
