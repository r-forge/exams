library(shiny)
library(exams)
library(jsonlite)

## ToDo: 
# - [OK?!?] default values instead of initial values of shiny inputs, but see https://github.com/rstudio/shiny/issues/559; perhaps workaround 0 -> NULL ?!?


#####
## module exportFormat: the ui shows the selection of an export format; the server reads all json files in "exportConfig" (structure: list with name, command (exams2xyz), argument), output of server is the command and argument-list of the selected export format
exportFormatInput <- function(id) {
  uiOutput(NS(id, "exportFormatSelection"))
}
exportFormatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    listOfAllExportFormats <- lapply(list.files("./exportConfig/",glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
    names <- sapply(listOfAllExportFormats,function(x) x$name)
    
    reactVals <- reactiveValues(
      selectedCommand = listOfAllExportFormats[[1]]$command,
      selectedArgument = listOfAllExportFormats[[1]]$argument
    )
    
    output$exportFormatSelection <- renderUI({
      selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
    })
    
    observeEvent(input$exportFormat,{
      reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
      })
    
    
    reactive(list(
      command = reactVals$selectedCommand,
      argument = reactVals$selectedArgument
      )
    )
  })
}
#####
## module examsArgument: the ui shows shiny input elements for all names (description) of namedList (except userSetable = FALSE) where the input type is given by type; the server build the ui elements from the input (namedList) and returns as output a named list with the inputs from th ui
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
examsArgumentServer <- function(id, namedList) {
  stopifnot(is.reactive(namedList))
  
  moduleServer(id, function(input, output, session) {
    vars <- reactive(names(namedList()))
    
    output$controls <- renderUI({
      # purrr::map(vars(), function(var) make_ui(namedList()[[var]], NS(id, var), var))
      lapply(vars(), function(var) {
        if (namedList()[[var]]$userSetable == TRUE) make_ui(namedList()[[var]], NS(id, var), var)
      })
    })
    
    reactive({
      #each_var <- purrr::map(vars(), function(var) getArgumentValues(namedList()[[var]], input[[var]]))
      each_var <- lapply(vars(), function(var) {
        if (namedList()[[var]]$userSetable == TRUE) getArgumentValues(namedList()[[var]], input[[var]]) else namedList()[[var]]$default}
        )
      names(each_var) <- vars()
      each_var
    })
  })
}
#####
## module examsTemplate: the ui shows a selectInput for all available templates and all available template-specific header arguments; the server extracts from an exportFormat the folder of all available templates, the auxiliary function getTemplateOptions extracts from a selected template all available template-specific header arguments by matching templateSubstitute, the oupput of the sever ist the selectedTemplate and the selectedTemplateOptions (NULL if not available)
examsTemplateUI <- function(id) {
  fluidPage(
    uiOutput(NS(id, "controlsTemplate")),
    uiOutput(NS(id, "controlsTemplateOptions")),
    tags$br()
  )
}
getTemplateOptions <- function(templateName,templateSubstitute) {
  # templateName <- "templates/tex/exam-FS.tex"
  # templateName <-"templates/pandoc/pandoc-exam.tex"
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
examsTemplateServer <- function(id, exportFormat) {
  stopifnot(is.reactive(exportFormat))

  moduleServer(id, function(input, output, session) {
    
    reactVals <- reactiveValues(
      selectedTemplate = NULL,
      selectedTemplateOptions = NULL
    )
    
    selectedTemplateFolder <- reactive({
      exportFormat()$argument$template$folder
    })
    selectedTemplateSubstitute <- reactive({
       exportFormat()$argument$template$substitute
    })
    
    templateFile = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = TRUE),fixed = T,value = T))
    
    templateChoices = reactive(grep("",dir(file.path("templates", selectedTemplateFolder()), full.names = FALSE),fixed = T,value = T))
    
    
    output$controlsTemplate <- renderUI({
      if (is.null(exportFormat()$argument$template)) {
       # p("template is NULL.")
        } else {
          if (!exportFormat()$argument$template$userSetable) {
            tags$b("Template already set.")
          } else if ((is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {
            tags$b("No template available.")
      } else {
        selectInput(NS(id, "templateFile"), "Pick a template file", choices = setNames(templateFile(), templateChoices()))}}
    })
    
    observeEvent(exportFormat(), {
      reactVals$selectedTemplate = exportFormat()$argument$template$default
      reactVals$selectedTemplateOptions = exportFormat()$argument$header$default
    })
    
    observeEvent(input$templateFile, {
      reactVals$selectedTemplate = input$templateFile
    })
    
    observe({
      if (is.null(exportFormat()$argument$template)) reactVals$selectedTemplate = NULL
    })
    

    setableTemplateOptions = reactive({
      req(input$templateFile)
      names(getTemplateOptions(reactVals$selectedTemplate,selectedTemplateSubstitute()))
    })


    output$controlsTemplateOptions <- renderUI({
           if (is.null(exportFormat()$argument$header)) {
        #p("template is NULL.")
           } else {
             if (!exportFormat()$argument$header$userSetable) {
               tags$b("Further template options already set") 
               } else if ( (is.null(selectedTemplateFolder())) | (length(templateFile())==0)) {} else {
        if (is.null(setableTemplateOptions())) {
          tags$b("No further template options available")
        } else {
          tagList(
            tags$b("Further template options:"),
            lapply(setableTemplateOptions(), function(var) {
              textInput(NS(id, var), 
                        label=as.character(var), 
                        value = if (var %in% names(exportFormat()$argument$header$default)) exportFormat()$argument$header$default[[var]] else NULL)
            })
          )
        }
             }}
      })

    
    observe({
      if (!is.null(exportFormat()$argument$header)) {
      if ( (!exportFormat()$argument$header$userSetable) | 
           (is.null(exportFormat()$argument$template))) {
        reactVals$selectedTemplateOptions <- exportFormat()$argument$header$default
      } else {
        each_var <- lapply(setableTemplateOptions(), function(var) {
          if (length(grep("^ *Rfun",input[[var]],value = F))==1) {
            if (inherits(try(eval(parse(text=gsub("Rfun ","",input[[var]]))),silent = T),"try-error")) NULL else eval(parse(text=gsub("Rfun ","",input[[var]])))
          } else input[[var]]
        })
        names(each_var) <- setableTemplateOptions()
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
exportFormatApp <- function() {
  ui <- fluidPage(column(4,
                         verbatimTextOutput("showReturnDebug"),
                         fluidPage(exportFormatInput("exportFormat")),
                         examsTemplateUI("examsTemplate"),
                         fluidPage(examsArgumentUI("examsArgument"))),
                  column(4,
                         ),
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
    
    output$showReturnDebug <- renderPrint(print(exportFormat()$command))

    
  }
  shinyApp(ui, server)
}

exportFormatApp()          

