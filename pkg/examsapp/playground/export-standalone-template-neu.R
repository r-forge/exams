library(shiny)
library(exams)
library(jsonlite)

list.files("templates",full.names = T,recursive = T)
## ToDo: 
# - [OK?!?] default values instead of initial values of shiny inputs, but see https://github.com/rstudio/shiny/issues/559; perhaps workaround 0 -> NULL ?!?
# - template-dependent input list: search in template between "\def\@" and "{"


##############
exportFormatUI <- function(id) {
  uiOutput(NS(id, "exportFormatSelection"))
}
exportFormatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    listOfAllExportFormats <- lapply(list.files("./exportConfig/",glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
    names <- sapply(listOfAllExportFormats,function(x) x$name)
    
    reactVals <- reactiveValues(
      selectedCommand = listOfAllExportFormats[[1]]$command,
      selectedArgument = listOfAllExportFormats[[1]]$argument,
      selectedTemplate = listOfAllExportFormats[[1]]$template
    )
    
    output$exportFormatSelection <- renderUI({
      selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
    })
    
    observeEvent(input$exportFormat,{
      reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
      reactVals$selectedTemplate <- listOfAllExportFormats[[which(names == input$exportFormat)]]$template
      })
    
    
    reactive(list(
      command = reactVals$selectedCommand,
      template = reactVals$selectedTemplate,
      argument = reactVals$selectedArgument
      )
    )
  })
}
##
examsArgumentUI <- function(id) {
  uiOutput(NS(id, "controls"))
}
make_ui <- function(x, id, var) {
  argumentLabel <- paste0(x$description," (",var,")")
  argumentValue <- x$default
  if (x$type == "integer") {
    if (is.null(argumentValue)) argumentValue = 0
    sliderInput(id, label = argumentLabel, min = x$range[1], max = x$range[2], value = argumentValue,step=1)
  } else if (x$type == "numeric") {
    numericInput(id, label = argumentLabel, min = x$range[1], max = x$range[2], value = argumentValue)
  } else if (x$type == "logical") {
    checkboxInput(id, label = argumentLabel, value = argumentValue)
  } else if(x$type %in% c("character","list")) {
    textInput(id, label=argumentLabel, value = argumentValue)
  } else if (x$type == c("selection")) {
    selectInput(id, label=argumentLabel,choices = x$range, selected = argumentValue)
    } else {
    selectInput(id, label=argumentLabel,choices = x$type, selected = argumentValue)
    # Not supported
    # NULL
    }
}
getArgumentValues <- function(x, val) {
  if (x$type %in% c("numeric","logical","selection")) {
    val
  } else if (x$type == "integer") {
    if(!is.null(val)) {if (val == "0") NULL else val} else val
  } else if (x$type == "character") {
    as.character(val)
  } else if (x$type == "list") {
    eval(parse(text=as.character(val)))
  } else {
    # Not supported
    val
  }
}
examsArgumentServer <- function(id, df) {
  stopifnot(is.reactive(df))
  
  moduleServer(id, function(input, output, session) {
    vars <- reactive(names(df()))
    
    output$controls <- renderUI({
      # purrr::map(vars(), function(var) make_ui(df()[[var]], NS(id, var), var))
      lapply(vars(), function(var) {
        if (df()[[var]]$userSetable == TRUE) make_ui(df()[[var]], NS(id, var), var)
      })
    })
    
    reactive({
      #each_var <- purrr::map(vars(), function(var) getArgumentValues(df()[[var]], input[[var]]))
      each_var <- lapply(vars(), function(var) {
        if (df()[[var]]$userSetable == TRUE) getArgumentValues(df()[[var]], input[[var]]) else df()[[var]]$default}
        )
      #each_var <- map(vars(), function(var) input[[var]])
      names(each_var) <- vars()
      #print(each_var)
      #paste0(each_var,collapse = ";; ")
      each_var
    })
  })
}
## ALT
# examsTemplateUI <- function(id) {
#   fluidPage(
#     uiOutput(NS(id, "controlsTemplate")),
#     uiOutput(NS(id, "controlsTemplateOptions"))
#   )
# }
# getTemplateOptions <- function(templateName,templateSubstitute) {
#   # templateName <- "templates/tex/exam-FS.tex"
#   # templateName <-"templates/pandoc/pandoc-exam.tex"
#   # templateName <-"templates/pandoc/plain.html"
#   # templateSubstitute <- c("\\def\\@","{#")
#   # templateSubstitute <- c("##","##")
#   # getTemplateOptions(templateName,templateSubstitute)
#   
#   fileExtension <- tools::file_ext(templateName)
#   
#   ## remove uncommented tags
#   uncommentedTemplate <- switch(fileExtension,
#                                 "tex" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *%",x,value = FALSE)))==0],
#                                 "html" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *<!--",x,value = FALSE)))==0],
#                                 "md" = readLines(templateName)[lapply(readLines(templateName), function(x) length(grep("^ *<!--",x,value = FALSE)))==0]
#   )
#   
#   # FIXME: use base R only !
#   # x <- unlist(lapply(readLines(templateName), function(x)qdapRegex::ex_between(x, "\\\\def\\\\@", "{#")))
#   prefix <- gsub("\\\\","\\\\\\\\",templateSubstitute[1])
#   suffix <- gsub("\\\\","\\\\\\\\",templateSubstitute[2])
#   x <- unlist(lapply(uncommentedTemplate, function(x)qdapRegex::ex_between(x, prefix, suffix)))
#   x <- setdiff(x,c("Questionheader", "Question", "Questionlist", "Solutionheader", "Solution", "Solutionlist"))
#   x <- if (all(is.na(x))) NA else x[!is.na(x)]
#   
#   # TODO: default values or remove NULL values at the end
#   if (all(is.na(x))) NULL else setNames(vector("list", length(x)), x)
# }
# examsTemplateServer <- function(id, selectedTemplateFolder,selectedTemplateSubstitute) {
#   stopifnot(is.reactive(selectedTemplateFolder))
#   stopifnot(is.reactive(selectedTemplateSubstitute))
#   
#   moduleServer(id, function(input, output, session) {
#     
#     reactVals <- reactiveValues(
#       selectedTemplate = NULL,
#       selectedTemplateOptions = NULL
#     )
#     
#     #selectedTemplateFolder <- reactive("pandoc")
#     #selectedTemplateFolder <- reactive("tex")
#     
#       templateFile = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = TRUE),fixed = T,value = T))
#       
#       templateChoices = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = FALSE),fixed = T,value = T))
#       
#     
#     output$controlsTemplate <- renderUI({
#       if ( (is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {
#         p("No template available.")
#       } else {
#         selectInput(NS(id, "templateFile"), "Pick a template file", choices = setNames(templateFile(), templateChoices()))}
#       })
#     
#     observeEvent(input$templateFile, {
#       reactVals$selectedTemplate = input$templateFile
#     })
#     
#     setableTemplateOptionsFS = reactive({
#       req(input$templateFile)
#       names(getTemplateOptions(input$templateFile,selectedTemplateSubstitute()))
#     })
#  
#     
#     output$controlsTemplateOptions <- renderUI({
#       if ( (is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {} else {
#         #  wait until input$templateFile is available 
#         #req(input$templateFile)
#         #setableTemplateOptions <- names(getTemplateOptions(input$templateFile,selectedTemplateSubstitute()))
#         #setableTemplateOptions <- names(getTemplateOptions("templates/tex/exam-FS.tex",selectedTemplateSubstitute()))
#         if (is.null(setableTemplateOptionsFS())) {
#           p("No further options available.")
#           } else {
#           tagList(
#             p("Further options for the template:"),
#             lapply(setableTemplateOptionsFS(), function(var) {
#               textInput(NS(id, var), label=as.character(var), value = NULL)
#             })
#             )
#           }
#       }
#     })
#     
#     observe({
#       req(input$templateFile)
#       each_var <- lapply(setableTemplateOptionsFS(), function(var) {
#         input[[var]]
#       })
#       names(each_var) <- setableTemplateOptionsFS()
#       reactVals$selectedTemplateOptions <- each_var
#     })
#     
#       # list(
#       #   selectedTemplate = reactive({reactVals$selectedTemplate}),
#       #   selectedTemplateOptions = reactive({reactVals$selectedTemplateOptions})
#       #   
#       # )
#       reactive(list(
#         selectedTemplate = reactVals$selectedTemplate,
#         selectedTemplateOptions = reactVals$selectedTemplateOptions
#       ))
#       
#   })
# }
# ## NEU
examsTemplateUI <- function(id) {
  fluidPage(
    uiOutput(NS(id, "controlsTemplate")),
    uiOutput(NS(id, "controlsTemplateOptions"))
  )
}
getTemplateOptions <- function(templateName,templateSubstitute) {
  # templateName <- "templates/tex/exam-FS.tex"
  # templateName <-"templates/pandoc/pandoc-exam.tex"
  # templateName <-"templates/pandoc/plain.html"
  # templateSubstitute <- c("\\def\\@","{#")
  # templateSubstitute <- c("##","##")
  # getTemplateOptions(templateName,templateSubstitute)
  
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
}
examsTemplateServer <- function(id, exportFormat) {
  stopifnot(is.reactive(exportFormat))
 # stopifnot(is.reactive(selectedTemplateSubstitute))
  
  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      selectedTemplate = NULL,
      selectedTemplateOptions = NULL
    )
    
    selectedTemplateFolder <- reactive({
      exportFormat()$template$folder
    })
    selectedTemplateSubstitute <- reactive({
       exportFormat()$template$substitute
    })
    
    # if (!is.null(exportFormat()$template)) 
    #selectedTemplateFolder <- reactive("pandoc")
    #selectedTemplateFolder <- reactive("tex")
    
    templateFile = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = TRUE),fixed = T,value = T))
    
    templateChoices = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = FALSE),fixed = T,value = T))
    
    
    output$controlsTemplate <- renderUI({
      if (is.null(exportFormat()$template)) {
        #p("template is NULL.")
        } else if ((is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {
        p("No template available.")
      } else {
        selectInput(NS(id, "templateFile"), "Pick a template file", choices = setNames(templateFile(), templateChoices()))}
    })
    
    observeEvent(input$templateFile, {
      reactVals$selectedTemplate = input$templateFile
    })
    
    observe({
      if (is.null(exportFormat()$template)) reactVals$selectedTemplate = NULL
    })
    

    setableTemplateOptionsFS = reactive({
      req(input$templateFile)
      names(getTemplateOptions(input$templateFile,selectedTemplateSubstitute()))
    })


    output$controlsTemplateOptions <- renderUI({
      if (is.null(exportFormat()$template)) {
        #p("template is NULL.")
      } else if ( (is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {} else {
        if (is.null(setableTemplateOptionsFS())) {
          p("No further options available.")
        } else {
          tagList(
            p("Further options for the template:"),
            lapply(setableTemplateOptionsFS(), function(var) {
              textInput(NS(id, var), label=as.character(var), value = NULL)
            })
          )
        }
      }
    })

    ## hier liegt das Problem !!!
    observe({
      req(input$templateFile)
      if (!is.null(exportFormat()$template)) {
      each_var <- lapply(setableTemplateOptionsFS(), function(var) {
        input[[var]]
      })
      names(each_var) <- setableTemplateOptionsFS()
      reactVals$selectedTemplateOptions <- each_var
      } else reactVals$selectedTemplateOptions <- NULL
        
    })
    

    # list(
    #   selectedTemplate = reactive({reactVals$selectedTemplate}),
    #   selectedTemplateOptions = reactive({reactVals$selectedTemplateOptions})
    #   
    # )
    
    
    reactive(list(
      template = reactVals$selectedTemplate,
      header = reactVals$selectedTemplateOptions
    ))
    
  })
}
##
examsExportApp <- function() {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        exportFormatUI("exportFormat"),
        examsArgumentUI("examsArgument")
      ),
      mainPanel(
        fluidPage(
          column(4,
                 #uiOutput("TemplateWithOptions")
                 examsTemplateUI("examsTemplate")
                 #examsTemplateOptionsUI("examsTemplateOptions"),
                # p("Template options:"),
                 #verbatimTextOutput("templateOptions")
                 ),
          column(8,
        #textOutput("compileCommand")
        p("My Test:"),
        verbatimTextOutput("mytest"),
        p("Selected exams2xyz:"),
        verbatimTextOutput("selectedCommand"),
        p("List of arguments:"),
        verbatimTextOutput("compileCommand"),
        actionButton("compileExam",label = "Compile Exam"),
        p("Temp Dir:"),
        verbatimTextOutput("tempDirectory"),
        p("Generated Exams:"),
        verbatimTextOutput("generatedExams")
      )))
    )
  )
  server <- function(input, output, session) {
    
    exportFormat <- exportFormatServer("exportFormat")
    
    withoutTemplate <- reactive({exportFormat$selectedArgument()[!(names(exportFormat$selectedArgument()) %in% c("template","header"))]})
    
    examsArgument <- examsArgumentServer("examsArgument", withoutTemplate)
    
    examsTemplate <- examsTemplateServer("examsTemplate", exportFormat$selectedTemplateFolder,exportFormat$selectedTemplateSubstitute)
     

    dir.create(tdir <- tempfile())
    
    mylist <-reactive({
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      ll$template <- examsTemplate()
      #ll$header <- examsTemplateOptions()
      ll
    })
    
    output$selectedCommand <- renderPrint(print(exportFormat$selectedCommand()))
    output$compileCommand <- renderPrint(print(mylist()))
    #output$compileCommand <- renderPrint(print(examsArgument()))
    output$tempDirectory <- renderPrint(print(tdir))
    #output$templateOptions <- renderPrint(print(examsTemplateOptions()))
    output$mytest <- renderPrint(print(examsTemplate()))
    
    

    
    observeEvent(input$compileExam, {
      #message("running exams2xyz")
      # exams2pdf("dist.Rmd")
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      ll$template <- examsTemplate()
      #ll$header <- examsTemplateOptions()
      do.call(exportFormat$selectedCommand(),ll)
      output$generatedExams <- renderPrint(print(list.files(tdir)))
    })
  }
  shinyApp(ui, server)
}

examsExportAppTest <- function() {
  ui <- fluidPage(column(6,
         checkboxInput("einschalten","Template ein/aus:"),
         p("My Test App:"),
         uiOutput("template")
  ))
  
  server <- function(input, output, session) {

    observeEvent(input$einschalten,{
      if (input$einschalten) {
        #examsReturn <- examsTemplateServer("examsTemplate", reactive("tex"),reactive(c("\\def\\@","{#")))
        # examsReturn <- examsTemplateServer("examsTemplate", reactive("pandoc"),reactive(c("##","##")))
        mylist = list(template=list("folder"="tex","substitute" = c("\\def\\@","{#")))
        #mylist = list(template=NULL)
        examsReturn <- examsTemplateServer("examsTemplate", reactive(mylist))
        output$template <- renderUI({
          tagList(
            examsTemplateUI("examsTemplate"),
            renderPrint(print(examsReturn()))#$selectedTemplateOptions()))
            )
          }) 
      } else {
        output$template <- renderUI({p("Nix da.")})
      }
        
    })
    
  }
  shinyApp(ui, server)
}

# examsExportAppTest()






exportFormatApp <- function() {
  ui <- fluidPage(column(4,
                         exportFormatUI("exportFormat"),
                         examsArgumentUI("examsArgument")),
                  column(4,
                         examsTemplateUI("examsTemplate")),
                  column(4,
                         verbatimTextOutput("showReturn")
  ))
  
  server <- function(input, output, session) {
    
    exportFormat <- exportFormatServer("exportFormat")
    
    withoutTemplate <- reactive({exportFormat()$argument[!(names(exportFormat()$argument) %in% c("template","header"))]})
    
    examsArgument <- examsArgumentServer("examsArgument", withoutTemplate)
    
    examsTemplate <- examsTemplateServer("examsTemplate", exportFormat)
    
    fullArgument = reactive({
      argumentAllowed <- names(exportFormat()$argument)
      argumentSet <- names(c(examsArgument(),examsTemplate()))
      c(examsArgument(),examsTemplate())[intersect(argumentAllowed,argumentSet)]
    })

    output$showReturn <- renderPrint(print(fullArgument()))

    
  }
  shinyApp(ui, server)
}

exportFormatApp()          

# examsExportAppTest()