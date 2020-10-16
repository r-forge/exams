library(shiny)
library(DT)

exportTabUI <- function(id){
  
  ns = NS(id)
  
  tabPanel("Export",
           tagList(
             fluidPage(
             fluidRow(
                      selectInput(ns("examDropDown"), label = "Select an Exam: ", choices = c("---"))
             ),
             fluidRow(
                       column(4,
                              selectInput(ns("formatDropDown"), label = "Select a format: ", choices = c("---"))
                       ),
                       column(4, offset = 1,
                              conditionalPanel(condition = "input.formatDropDown == 'HTML' || input.formatDropDown == 'PDF'",
                                               ns = ns,
                                               selectInput(ns("templateDropDown"), label = "Select a template: ", choices = c("---"))
                              )
                       )
             ),
             fluidRow(
                      conditionalPanel(condition = "input.formatDropDown == 'Blackboard' || input.formatDropDown == 'OpenOLAT' || input.formatDropDown == 'Canvas' || input.formatDropDown == 'QTI12' || input.formatDropDown == 'QTI21'",
                                       #|| input.formatDropDown == 'OpenOLAT' || input.formatDropDown == 'Canvas' || input.formatDropDown == 'QTI12' || input.formatDropDown == 'QTI21'
                                       ns = ns,
                                       numericInput(ns("maxAttempts"), label = "max. attempts: ", min = 1, max = 1000000, value = 1)
                      ),
                      conditionalPanel(condition = "input.formatDropDown == 'OpenOLAT' || input.formatDropDown == 'Canvas' || input.formatDropDown == 'QTI12' || input.formatDropDown == 'QTI21'",
                                       ns = ns,
                                       numericInput(ns("durationMin"), label = "duration (in min): ", min = 1, max = 10000000, value = 60)
                      ),
                      numericInput(ns("numberCopies"), label = "number of copies", min = 1, max = 100000, value = 1)
             ),
             fluidRow(
                      column(9),
                      column(3,
                             actionButton(ns("compile"), label = "Compile")
                      )
             ),
             fluidRow(
                      checkboxGroupInput(ns("additionalDocs"), label = "Download additional documents: ", inline = TRUE, choices = c("Exercises","Template","R Code"))
             ),
             fluidRow(
               column(9),
               column(3,
                      downloadButton(ns("downloadExam"), label = "Download Exam (.zip)")
               )
             )
             
           )
           )
           
           
  )
  
}

exportTabLogic <- function(input, output, session, selectedExerciseList, formatList, pathToTemplates, pathToTmp){
  
  reactVals <- reactiveValues(
    examExerciseList = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    exercisesToExam = data.frame(Foldername=character(), Filename=character(), Number=numeric(), ExamName=character(), Points=numeric()),
    formats = c("---"),
    examNames = c("---"),
    templateNames = c("---"),
    pathToTemplates = NULL,
    pathToTmp = NULL
  )
  
  observe({
    
    reactVals$examExerciseList = selectedExerciseList()
    reactVals$formatList = formatList()
    reactVals$pathToTemplates = pathToTemplates()
    reactVals$pathToTmp = pathToTmp()
    
    reactVals$examNames = as.vector(unique(c(reactVals$examNames, as.vector(unique(reactVals$examExerciseList$ExamName)))))
    tmp = input$examDropDown
    updateSelectInput(session, "examDropDown", choices = reactVals$examNames, selected = tmp)
    
    reactVals$formats = as.vector(unique(c(reactVals$formats, as.vector(unique(reactVals$formatList)))))
    tmp = input$formatDropDownDropDown
    updateSelectInput(session, "formatDropDown", choices = reactVals$formats, selected = tmp)
    
    reactVals$templateNames = as.vector(unique(c(reactVals$templateNames, list.files(path = reactVals$pathToTemplates))))
    tmp = input$templateDropDown
    updateSelectInput(session, "templateDropDown", choices = reactVals$templateNames, selected = tmp)
  })
  
  observeEvent(input$examDropDown, {
    if(input$examDropDown != "---"){
      examName = input$examDropDown
      reactVals$exercisesToExam = reactVals$examExerciseList[which(reactVals$examExerciseList$ExamName == examName),]
      row.names(reactVals$exercisesToExam) = NULL
    }
    else{
      reactVals$exercisesToExam = NULL
    }
    print(reactVals$exercisesToExam)
  })
  
  observeEvent(input$compile, {
    if(!is.null(reactVals$exercisesToExam)){
      if(!file.exists(file.path(reactVals$pathToTmp, "exams", "current"))) {
        dir.create(file.path(reactVals$pathToTmp, "exams", "current"))
      }
      else {
        cfiles = dir(file.path(reactVals$pathToTmp, "exams", "current"))
        if(length(cfiles)){
          unlink(cfiles)
        }
      }
      cdir = file.path(reactVals$pathToTmp, "exams", "current")
      seed = as.integer(runif(1, 1, 1e+08))
      examName = input$examDropDown
      format = input$formatDropDownDropDown
      template = input$templateDropDown
      n = input$numberCopies
      maxAttempts = input$maxAttempts
      duration = input$durationMin
      points = unlist(sapply(split(reactVals$exercisesToExam$Points, as.factor(reactVals$exercisesToExam$Number)), function(x) { x[1] }))
      exlist = split(as.vector(reactVals$exercisesToExam$Filename), as.factor(reactVals$exercisesToExam$Number))
      #print(exlist)
      set.seed(seed)
      if(input$formatDropDown == "ARSnova"){
        ex <- try(exams2arsnova(exlist, n = n,
                                dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName), silent = TRUE)
      }
      if(input$formatDropDown == "Blackboard"){
        ex <- try(exams2blackboard(exlist, n = n,
                                   dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                                   maxattempts = maxAttempts), silent = TRUE)
      }
      if(input$formatDropDown == "HTML"){
        ex <- try(exams2html(exlist, n = n,
                             dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName,
                             template = template), silent = TRUE)
      }
      if(input$formatDropDown == "NOPS"){
        ex <- try(exams2nops(exlist, n = n,
                             dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points), silent = TRUE)
      }
      if(input$formatDropDown == "OpenOLAT"){
        ex <- try(exams2openolat(exlist, n = n,
                                 dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                                 maxattempts = maxAttempts, duration = duration), silent = TRUE)
      }
      if(input$formatDropDown == "DOCX"){
        ex <- try(exams2pandoc(exlist, n = n,
                               dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points), silent = TRUE)
      }
      if(input$formatDropDown == "PDF"){
        ex <- try(exams2pdf(exlist, n = n,
                            dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                            template = template), silent = TRUE)
      }
      if(input$formatDropDown == "Canvas"){
        ex <- try(exams2canvas(reactVals$exercisesToExam$Filename, n = n,
                               dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                               maxattempts = maxAttempts, duration = duration), silent = TRUE)
      }
      if(input$formatDropDown == "QTI12"){
        ex <- try(exams2qti12(exlist, n = n,
                              dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                              maxattempts = maxAttempts, duration = input$duration), silent = TRUE)
      }
      if(input$formatDropDown == "QTI21"){
        ex <- try(exams2qti12(exlist, n = n,
                              dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points,
                              maxattempts = maxAttempts, duration = duration), silent = TRUE)
      }
      if(input$formatDropDown == "Moodle"){
        ex <- try(exams2moodle(exlist, n = n,
                               dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points), silent = TRUE)
      }
      if(input$formatDropDown == "TCExam"){
        ex <- try(exams2tcexam(exlist, n = n,
                               dir = cdir, edir = file.path(reactVals$pathToTmp, "exercises"), name = examName, points = points), silent = TRUE)
      }
      if(inherits(ex, "try-error")){
        writeLines(ex)
        showNotification("Error: could not compile exam!", duration = 2, closeButton = FALSE, type = "error")
        ex <- NULL
      } else {
        output$exams <- renderText({
          basename(grep(input$selected_exam, dir(cdir, full.names = TRUE), fixed = TRUE, value = TRUE))
        })
        showNotification(paste("Compiled", input$selected_exam, "using", input$formatDropDown), duration = 1, closeButton = FALSE)
      }
    }
    else {
      showNotification("Please select an exam.", type = c("error"))
    }
  })
  
  # observeEvent(input$additionalDocs, {
  #   print(as.vector(input$additionalDocs))
  # })
  
  output$downloadExam <- downloadHandler(
    filename = function(){
      time <- Sys.time()
      time <- gsub(" ", ".", time, fixed = TRUE)
      time <- gsub("-", "_", time, fixed = TRUE)
      time <- gsub(":", "_", time, fixed = TRUE)
      paste0(input$examDropDown, "_", time, ".zip")
    },
    content = function(file){
      dir.create(tdir <- tempfile())
      print(tdir)
      dir.create(file.path(tdir, "exams"))
      listOfExams = list.files(file.path(reactVals$pathToTmp, "exams", "current"))
      file.copy(from=file.path(reactVals$pathToTmp, "exams", "current",listOfExams),
                to=file.path(tdir, "exams",listOfExams))
      if("Exercises" %in% as.vector(input$additionalDocs)){
        dir.create(file.path(tdir, "exercises"))
        file.copy(from=file.path(reactVals$pathToTmp,"exercises",reactVals$exercisesToExam$Filename),
                  to=file.path(tdir,"exercises",reactVals$exercisesToExam$Filename))
      }
      if("Template" %in% as.vector(input$additionalDocs)){
        dir.create(file.path(tdir,"templates"))
        file.copy(from=file.path(reactVals$pathToTemplates, input$templateDropDown),
                  to=file.path(tdir,"templates", input$templateDropDown))
      }
      if("R Code" %in% as.vector(input$additionalDocs)){
        showNotification("Work in progress", type=c("warning"))
      }
      owd=getwd()
      setwd(tdir)
      if(length(files <- dir(include.dirs = TRUE)))
        zip(zipfile = paste(input$examDropDown, "zip", sep = "."), files = files)
      setwd(owd)
      if(length(files))
        file.copy(file.path(tdir, paste(input$examDropDown, "zip", sep = ".")), file)
      unlink(tdir)
    },
    contentType = "application/zip"
  )
  
  
  
  
  
  
}