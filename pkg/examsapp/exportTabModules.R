library(shiny)
library(DT)


###### Aux-Modules #####
## module exportFormat: the ui shows the selection of an export format; the server reads all json files in "exportConfig" (structure: list with name, command (exams2xyz), argument), output of server is the command and argument-list of the selected export format
exportFormatUI <- function(id) {
  ns <- NS(id)
  uiOutput(ns("exportFormatSelection"))
}
exportFormatServer <- function(id,pathToFolder) {
  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      # path to the temporary folder of the user
      pathToFolderLocal = NULL,
      selectedCommand = NULL,
      selectedArgument = NULL,
      exportFormatNames = NULL)
    
    observe({
      reactVals$pathToFolderLocal = pathToFolder()
    })
    
    observe({
      listOfAllExportFormats <- lapply(list.files(file.path(reactVals$pathToFolderLocal,"exportConfig"),glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
      #reactVals$exportFormatNames <- sapply(listOfAllExportFormats,function(x) x$name)
      reactVals$exportFormatNames <- basename(list.files(file.path(reactVals$pathToFolderLocal,"exportConfig"),glob2rx("*.json"),full.names = F))
      #reactVals$selectedCommand = listOfAllExportFormats[[1]]$command
      #reactVals$selectedArgument = listOfAllExportFormats[[1]]$argument
    })
    

    output$exportFormatSelection <- renderUI({
      ns <- session$ns
      selectInput(ns("exportFormat"), "Pick an output format", choices = setNames(reactVals$exportFormatNames, tools::file_path_sans_ext(reactVals$exportFormatNames)))
    })
    
    observeEvent(input$exportFormat,{
      reactVals$selectedCommand = jsonlite::fromJSON(file.path(reactVals$pathToFolderLocal,"exportConfig",input$exportFormat))$command
      reactVals$selectedArgument = jsonlite::fromJSON(file.path(reactVals$pathToFolderLocal,"exportConfig",input$exportFormat))$argument
      # listOfAllExportFormats <- lapply(list.files(file.path(reactVals$pathToFolderLocal,"exportConfig"),glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
      # names <- sapply(listOfAllExportFormats,function(x) x$name)
      # reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      # reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
    })
    
    
    reactive(list(
      command = reactVals$selectedCommand,
      argument = reactVals$selectedArgument,
      name = tools::file_path_sans_ext(input$exportFormat)
    )
    )
  })
}
## module examsArgument: the ui shows shiny input elements for all names (description) of namedList (except userControl = FALSE) where the input type is given by type; the server build the ui elements from the input (namedList) and returns as output a named list with the inputs from th ui
examsArgumentUI <- function(id) {
  ns <- NS(id)
  uiOutput(ns("controls"))
}
make_ui <- function(x, id, var) {
  argumentLabel <- paste0(x$description," (",var,")")
  argumentValue <- x$default
  if (x$shinyInputType == "integer") {
    if (is.null(argumentValue)) argumentValue = 0
    sliderInput(id, label = argumentLabel, min = x$range[1], max = x$range[2], value = argumentValue,step=1)
  } else if (x$shinyInputType == "numeric") {
    numericInput(id, label = argumentLabel, min = x$range[1], max = x$range[2], value = argumentValue)
  } else if (x$shinyInputType == "logical") {
    checkboxInput(id, label = argumentLabel, value = argumentValue)
  } else if(x$shinyInputType %in% c("character","list")) {
    textInput(id, label=argumentLabel, value = argumentValue)
  } else if (x$shinyInputType == c("selection")) {
    selectInput(id, label=argumentLabel,choices = x$range, selected = argumentValue)
  } else {
    selectInput(id, label=argumentLabel,choices = x$shinyInputType, selected = argumentValue)
    # Not supported
    # NULL
  }
}
getArgumentValues <- function(x, val) {
  if (x$shinyInputType %in% c("numeric","logical","selection")) {
    val
  } else if (x$shinyInputType == "integer") {
    if(!is.null(val)) {if (val == "0") NULL else val} else val
  } else if (x$shinyInputType == "character") {
    as.character(val)
  } else if (x$shinyInputType == "list") {
    eval(parse(text=as.character(val)))
  } else {
    # Not supported
    val
  }
}
examsArgumentServer <- function(id, namedList) {
  stopifnot(is.reactive(namedList))
  
  moduleServer(id, function(input, output, session) {
    vars <- reactive(names(namedList()))
    
    output$controls <- renderUI({
      ns <- session$ns
      # purrr::map(vars(), function(var) make_ui(namedList()[[var]], NS(id, var), var))
      lapply(vars(), function(var) {
        if (namedList()[[var]]$userControl == TRUE) make_ui(namedList()[[var]], ns(var), var)
      })
    })
    
    reactive({
      #each_var <- purrr::map(vars(), function(var) getArgumentValues(namedList()[[var]], input[[var]]))
      each_var <- lapply(vars(), function(var) {
        if (namedList()[[var]]$userControl == TRUE) getArgumentValues(namedList()[[var]], input[[var]]) else namedList()[[var]]$default}
      )
      names(each_var) <- vars()
      each_var
    })
  })
}
## module examsTemplate: the ui shows a selectInput for all available templates and all available template-specific header arguments; the server extracts from an exportFormat the folder of all available templates, the auxiliary function getTemplateOptions extracts from a selected template all available template-specific header arguments by matching templateSubstitute, the oupput of the sever ist the selectedTemplate and the selectedTemplateOptions (NULL if not available)
examsTemplateUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    #verbatimTextOutput(ns("showReturn")),
    uiOutput(ns("controlsTemplate")),
    uiOutput(ns("controlsTemplateOptions")),
    tags$br()
  )
}
getTemplateOptions <- function(templateName,templateSubstitute) {
  # templateName <- "templates/tex/exam-FS.tex"
  # templateName <-"defaultStructure/templates/pandoc/pandoc-exam.tex"
  # templateName <-"templates/pandoc/plain.html"
  # templateSubstitute <- c("\\def\\@","{#")
  # templateSubstitute <- c("##","##")
  # getTemplateOptions(templateName,templateSubstitute)
  
  if (is.null(templateName) | is.null(templateSubstitute)) NULL else {
    
    fileExtension <- tools::file_ext(templateName)
    
    ## remove uncommented tags
    uncommentedTemplate <- switch(fileExtension,
                                  "tex" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *%",x,value = FALSE)))==0],
                                  "html" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *<!--",x,value = FALSE)))==0],
                                  "md" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *<!--",x,value = FALSE)))==0]
    )
    
    # FIXME: use base R only !
    # x <- unlist(lapply(readLines(templateName), function(x)qdapRegex::ex_between(x, "\\\\def\\\\@", "{#")))
    prefix <- gsub("\\\\","\\\\\\\\",templateSubstitute[1])
    suffix <- gsub("\\\\","\\\\\\\\",templateSubstitute[2])
    x <- unlist(lapply(uncommentedTemplate, function(x)qdapRegex::ex_between(x, prefix, suffix)))
    x <- setdiff(x,c("Questionheader", "Question", "Questionlist", "Solutionheader", "Solution", "Solutionlist"))
    x <- if (all(is.na(x))) NA else x[!is.na(x)]
    
    # TODO: default values or remove NULL values at the end
    if (all(is.na(x))) NULL else setNames(vector("list", length(x)), x)
    
  }}
examsTemplateServer <- function(id, pathToFolder,exportFormat) {
  stopifnot(is.reactive(exportFormat))
  
  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      pathToFolderLocal = NULL,
      selectedTemplate = NULL, # is returned 
      selectedTemplateOptions = NULL, # is returned
      availableTemplateOptions = NULL, ## locates in a template file all available arguments 
      templateFile = NULL,
      templateChoices = NULL,
      exportFormatLocal = NULL
    )
    
    # ## only for debugging
    # output$showReturn <- renderPrint(print(list(reactVals$availableTemplateOptions,reactVals$selectedTemplate,reactVals$availableTemplateOptions)))
    
    # Oberver: updates the pathToFolder when is changed outside this module (perhaps not necessary)
    observe({
      reactVals$pathToFolderLocal = pathToFolder()
    })
    
    # Oberver: updates the exportFormat when is changed outside this module (perhaps not necessary)
    observe({
      reactVals$exportFormatLocal = exportFormat()
    })
    
    
    # Oberver: when exportFormat is changed to a format with 
    # - template NULL, or
    # - template folder NULL, or
    # - no templates in folder,
    # the returned variables are set to NULL
    observe({
      if ( (is.null(reactVals$exportFormatLocal$argument$template)) | (is.null(reactVals$exportFormatLocal$argument$template$folder)) | (length(reactVals$templateFile)==0)) {
        reactVals$selectedTemplate = NULL
        reactVals$selectedTemplateOptions = NULL
        reactVals$availableTemplateOptions = NULL #2
      }
    })
    
    # Oberserver: is needed for selectInput for the template files, if something is not available both reactive values are NULL 
    observe({
      reactVals$templateFile = grep("",dir(file.path(reactVals$pathToFolderLocal,"templates", reactVals$exportFormatLocal$argument$template$folder), full.names = TRUE),fixed = T,value = T)
      
      reactVals$templateChoices = grep("",dir(file.path(reactVals$pathToFolderLocal,"templates", reactVals$exportFormatLocal$argument$template$folder), full.names = FALSE),fixed = T,value = T)
    })
    
    # Output: shows available templates
    output$controlsTemplate <- renderUI({
      ns <- session$ns
      if (is.null(reactVals$exportFormatLocal$argument$template)) {
        tags$b("template is NULL.")
      } else {
        if (!reactVals$exportFormatLocal$argument$template$userControl) {
          tags$b("Template already set.")
        } else if ((is.null(reactVals$exportFormatLocal$argument$template$folder)) | (length(reactVals$templateFile)==0)) {
          tags$b("No template available.")
        } else {
          selectInput(ns("templateFile"), "Pick a template file", choices = setNames(reactVals$templateFile, reactVals$templateChoices))
          # selectInput(ns("templateFile"), "Pick a template file", choices = reactVals$templateChoices)
          }}
    })

    ##########################
    

    ## in the case of  template userControl TRUE and at least one available template file the selectedTemplate is updated to the selected one, and the availableTemplateOptions are located
    observeEvent(input$templateFile, {
      reactVals$selectedTemplate = input$templateFile
      reactVals$availableTemplateOptions = names(getTemplateOptions(reactVals$selectedTemplate,reactVals$exportFormatLocal$argument$template$substitute)) #3
    })
    

    ## Observer: if template userControl is FALSE the availableTemplateOptions are located directly
    observe({
      if (!is.null(reactVals$exportFormatLocal$argument$template$userControl)) {
        if (!reactVals$exportFormatLocal$argument$template$userControl) {
        reactVals$selectedTemplate <- file.path(reactVals$pathToFolderLocal,"templates",reactVals$exportFormatLocal$argument$template$default) 
        reactVals$availableTemplateOptions <- names(getTemplateOptions(reactVals$selectedTemplate,reactVals$exportFormatLocal$argument$template$substitute)) #4
      }}
    })

    # Output: shows for a specific  template file all available arguments
    output$controlsTemplateOptions <- renderUI({
      ns <- session$ns
      if (is.null(reactVals$exportFormatLocal$argument$header)) {
        #p("template is NULL.")
      } else {
        if (!reactVals$exportFormatLocal$argument$header$userControl) {
          tags$b("Further template options already set")
        } else if ( (is.null(reactVals$exportFormatLocal$argument$template$folder)) | (length(reactVals$templateFile)==0)) {} else {
          if (is.null(reactVals$availableTemplateOptions)) {
            tags$b("No further template options available")
          } else {
            tagList(
              tags$b("Further template options:"),
              lapply(reactVals$availableTemplateOptions, function(var) {
                textInput(ns(var),
                          label=as.character(var),
                          value = if (var %in% names(reactVals$exportFormatLocal$argument$header$default)) reactVals$exportFormatLocal$argument$header$default[[var]] else NULL)
              })
            )
          }
        }}
    })



    ## Oberserve: monitors an evaluates the available arguments in the template file
    observe({
      if (!is.null(reactVals$exportFormatLocal$argument$header)) {
        if ( (!reactVals$exportFormatLocal$argument$header$userControl) |
             (is.null(reactVals$exportFormatLocal$argument$template))) {
          reactVals$selectedTemplateOptions <- reactVals$exportFormatLocal$argument$header$default
        } else {
          each_var <- lapply(reactVals$availableTemplateOptions, function(var) {
            if (length(grep("^ *Rfun",input[[var]],value = F))==1) {
              if (inherits(try(eval(parse(text=gsub("Rfun ","",input[[var]]))),silent = T),"try-error")) NULL else eval(parse(text=gsub("Rfun ","",input[[var]])))
            } else input[[var]]
          })
          names(each_var) <- reactVals$availableTemplateOptions
          reactVals$selectedTemplateOptions <- each_var
        }
      }
    })

    reactive(list(
      template = reactVals$selectedTemplate,
      header = reactVals$selectedTemplateOptions
    ))

  })
}
##


######

exportTabUI <- function(id){
  ns <- NS(id)
  tabPanel("Export",
           tagList(
             fluidRow(column(12,style='margin:5px; padding:10px; padding-top: 15px;',
                             p("Select an existing exams, choose the output format and select the available settings."))),
             fluidRow(
                       column(2,style='margin:10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e;border-radius: 5px;',
                              selectInput(ns("examDropDown"), label = "Select an Exam: ", choices = c("---")),
                              exportFormatUI(ns("exportFormat")),
                              br(),
                              p("Template and options:"),
                              br(),
                              examsTemplateUI(ns("examsTemplate"))
                              ),
                       column(2,style='margin:10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e;border-radius: 5px;',
                              examsArgumentUI(ns("examsArgument"))
                              ),
                       column(6,style='margin:10px; padding:10px; padding-top: 15px; border: 2px solid #5e5e5e;border-radius: 5px;',
                              p("Generate the exam with the selected settings."),
                              actionButton(ns("compile"), label = "Compile"),
                              br(),
                              br(),
                              checkboxGroupInput(ns("additionalDocs"), label = "Choose additional documents for the download: ", inline = TRUE, choices = c("Exercises","Template","R Code")),
                              verbatimTextOutput(ns("compiledExams")),
                              downloadButton(ns("downloadExam"), label = "Download Exam (.zip)"),
                              # br(),
                              # br(),
                              # verbatimTextOutput(ns("showReturn")),
                              
                              )
             )
           )
  )
}

exportTabServer <- function(id, pathToFolder, tabChanged){
  
  stopifnot(is.reactive(pathToFolder))
  stopifnot(is.reactive(tabChanged))
  
  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      # path to the temporary folder of the user
      pathToFolderLocal = NULL,
      # selected or adapted or new exam
      currentExam = data.frame(File=character(), Number=numeric(), Points=numeric(), Seed=numeric()),
      # counter for the numeration of exercises
      # all available exercises, i.e. all files in or added to tmp/exercises
      availableExercises = NULL,
      # all available exams, i.e. all files in or added to tmp/exams
      availableExams = NULL,
      examsArgument = list(),
      debug = NULL,
      exportFormatLocal = NULL
    )
    


    ## only for debugging
    #output$showReturn <- renderText({paste("Output:",reactVals$examsFullArgument)})
    #output$showReturn <- renderPrint(print(exportFormat()$command))
    #output$showReturn <- renderPrint(print(names(append(reactVals$examsArgument,additionalArgument()))))
    #output$showReturn <- renderPrint(print(reactVals$debug))
    #output$showReturn <- renderPrint(print(reactVals$exportFormatLocal))
    #output$showReturn <- renderPrint(print(append(reactVals$examsArgument,additionalArgument())))
    
    # Observer to store the parameters given by the function chooseTabLogic(...) in reactive values ##### 
    # using reactive values for the data was in the test cases more convenient and furthermore a
    # standardizesed pattern to call the data is given  
    observe({
      reactVals$pathToFolderLocal = pathToFolder()
    })
    

    ########## 

    exportFormat <- exportFormatServer("exportFormat",reactive(reactVals$pathToFolderLocal))
    
    
    ## uncertain if really necessary
    observe({
      reactVals$exportFormatLocal = exportFormat()
    })
    
    ## if available, the arguments template and header are set in Module examsTemplate 
    withoutTemplate <- reactive({exportFormat()$argument[!(names(exportFormat()$argument) %in% c("template","header"))]})
    
    examsArgument <- examsArgumentServer("examsArgument", withoutTemplate)
    
    examsTemplate <- examsTemplateServer("examsTemplate", reactive(reactVals$pathToFolderLocal),reactive(reactVals$exportFormatLocal))
  
    
    ## the arguments from the Modules examsArgument and examsTemplate are combined and then reduced to those available in exportConfig file; this is a workaround because examsTemplate always returns a template and a header, at leart NULL and NULL
    additionalArgument = reactive({
      argumentAllowed <- names(exportFormat()$argument)
      argumentSet <- names(c(examsArgument(),examsTemplate()))
      c(examsArgument(),examsTemplate())[intersect(argumentAllowed,argumentSet)]
    })
    
    #####

    ## Observe: available exams, i.e. all files in or added to tmp/exams
    observe({
      e1 <- tabChanged()
      reactVals$availableExams <- getExams(reactVals$pathToFolderLocal)
    })
    
    observe({
      updateSelectInput(session, "examDropDown", choices = c(tools::file_path_sans_ext(reactVals$availableExams)))
    })
    
    ## Reads data from exams json file and updates the numberExercises counter
    observeEvent(input$examDropDown,{
      if (input$examDropDown %in% tools::file_path_sans_ext(reactVals$availableExams)) {
        reactVals$currentExam <- jsonlite::fromJSON(paste0(file.path(reactVals$pathToFolderLocal,"exams",input$examDropDown),".json"))
        sapply(c("File","Number","Points","Seed"),function(x) if (!(x %in% colnames(reactVals$currentExam))) reactVals$currentExam[,x] <<- NA)
        
        exam <- reactVals$currentExam
        
        ## how are same filenames in different subfolder handled (... ask Achim)?!?
        exam$File <- basename(exam$File)
        
        exam <- list(file = split(exam$File, as.factor(exam$Number)),
                                            points = unlist(sapply(split(exam$Points, as.factor(exam$Number)), function(x) { x[1] })),
                                            seed = exam$Seed)

        reactVals$examsArgument <- exam
        
      } else  {
        showNotification("You have to choose an exam.", type = c("error"))
      }
    })
    
    
    
    # from exams_shiny()
    # exlist <- split(basename(exam$Exercises), as.factor(exam$Number))
    # points <- unlist(sapply(split(exam$Points, as.factor(exam$Number)), function(x) { x[1] }))
    # set.seed(seed)
    
    # hier weiter:     input$compile von exams_shiny()
    
    # Observer: Click on "Compile"
    # # compiles the exercises to the selected format
    observeEvent(input$compile, {
      
      if(!file.exists(file.path(reactVals$pathToFolderLocal,"exams", "current"))) {
        dir.create(file.path(reactVals$pathToFolderLocal,"exams", "current"))
      } else {
        cfiles <- dir(file.path(reactVals$pathToFolderLocal,"exams", "current"), full.names = TRUE)
        if(length(cfiles))
          unlink(cfiles)
      }
      
      command <- exportFormat()$command
      fullArgument <- append(reactVals$examsArgument,additionalArgument())
      ## remove column points if this argument is not available in exams2xyz
      if (command %in% c("exams2arsnova","exams2html")) fullArgument <- fullArgument[setdiff(names(fullArgument),"points")]
      
      
      fullArgument$dir <- file.path(reactVals$pathToFolderLocal,"exams", "current")
      fullArgument$edir <- file.path(reactVals$pathToFolderLocal,"exercises")
      #fullArgument$name <- paste0("EX",input$examDropDown,ifelse(is.null(fullArgument$template),"",paste0("-TEMP",tools::file_path_sans_ext(basename(fullArgument$template)))))
      fullArgument$name <- paste0("EXM",input$examDropDown,"-FORMAT",reactVals$exportFormatLocal$name)
      
      # if (!(is.null(fullArgument$template))) fullArgument$template <- file.path(reactVals$pathToFolderLocal,fullArgument$template)
      
      ## replicate seed for all n>1
      if (fullArgument$n > 1) {
        seedtmp <- rep(fullArgument$seed,each=fullArgument$n)
        attr(seedtmp,"dim") <- c(fullArgument$n,length(fullArgument$seed))
        fullArgument$seed <- seedtmp
      }
      
      ## replace NA in seed by random seeds
      fullArgument$seed[is.na(fullArgument$seed)] <- sample(0L:1e8L,sum(is.na(fullArgument$seed)),replace = T)
      
      #reactVals$debug <- fullArgument
      
       ex <- try(do.call(command,fullArgument), silent = TRUE)
       reactVals$debug <- ex
       
       
      
       if(inherits(ex, "try-error")) {
         writeLines(ex)
         showNotification("Error: could not compile exam!", duration = 2, closeButton = FALSE, type = "error")
         ex <- NULL
       } else {
         output$compiledExams <- renderText({
           basename(grep(input$examDropDown, dir(fullArgument$dir, full.names = TRUE), fixed = TRUE, value = TRUE))
         })
         showNotification(paste("Compiled", input$examDropDown, "using", reactVals$exportFormatLocal$name), duration = 1, closeButton = FALSE)
       }
       if(!is.null(ex))
         save(ex, file = file.path(fullArgument$dir, paste(fullArgument$name, "rda", sep = ".")))

    })

    
    # Output: Download Data
    # downloads the exam and additional documents by using the downloadHandler
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
            dir.create(file.path(tdir, "exams"))
            listOfExams = list.files(file.path(reactVals$pathToFolderLocal, "exams", "current"))
            file.copy(from=file.path(reactVals$pathToFolderLocal, "exams", "current",listOfExams),
                      to=file.path(tdir, "exams",listOfExams))
            
            if("Exercises" %in% as.vector(input$additionalDocs)){
              dir.create(file.path(tdir, "exercises"))
              
              for (myfile in reactVals$currentExam$File) {
                newdir <- file.path(tdir,"exercises",dirname(myfile))
                if (!dir.exists(newdir)) dir.create(newdir,recursive=T)
                file.copy(file.path(reactVals$pathToFolderLocal,"exercises",myfile),newdir)
              }
            } 
            
            if("Template" %in% as.vector(input$additionalDocs)){
              showNotification("Work in progress", type=c("warning"))
            }
            
            if("R Code" %in% as.vector(input$additionalDocs)){
              showNotification("Work in progress", type=c("warning"))
            }
            
            
            owd=getwd()
            setwd(tdir)
            if(length(files <- dir(include.dirs = TRUE)))
              zip(zipfile = paste("Hallo", "zip", sep = "."), files = files)
            setwd(owd)
            if(length(files))
              file.copy(file.path(tdir, paste("Hallo", "zip", sep = ".")), file)
            unlink(tdir)
        },
      contentType = "application/zip"
    )


  })
}