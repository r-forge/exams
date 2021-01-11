library(shiny)
library(exams)
library(jsonlite)

list.files("templates",full.names = T,recursive = T)
## ToDo: 
# - [OK?!?] default values instead of initial values of shiny inputs, but see https://github.com/rstudio/shiny/issues/559; perhaps workaround 0 -> NULL ?!?
# - template-dependent input list: search in template between "\def\@" and "{"


##############

exportFormatInput <- function(id) {
  uiOutput(NS(id, "exportFormatSelection"))
}

exportFormatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    listOfAllExportFormats <- lapply(list.files("./exportConfig/",glob2rx("*.json"),full.names = T), function(x) jsonlite::fromJSON(x))
    names <- sapply(listOfAllExportFormats,function(x) x$name)
    
    reactVals <- reactiveValues(
      selectedCommand = listOfAllExportFormats[[1]]$command,
      selectedArgument = listOfAllExportFormats[[1]]$argument,
      selectedTemplateFolder = listOfAllExportFormats[[1]]$templateFolder
    )
    
    output$exportFormatSelection <- renderUI({
      selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
    })
    
    observeEvent(input$exportFormat,{
      reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
      reactVals$selectedTemplateFolder <- listOfAllExportFormats[[which(names == input$exportFormat)]]$templateFolder
      })
    
    
    
    list(
      selectedCommand = reactive(reactVals$selectedCommand),
      selectedArgument=reactive(reactVals$selectedArgument),
      selectedTemplateFolder=reactive(reactVals$selectedTemplateFolder)
    )
  })
}




examsArgumentUI <- function(id) {
  uiOutput(NS(id, "controls"))
}

make_ui <- function(x, id, var) {
  argumentLabel <- paste0(x$description," (",var,")")
  argumentValue <- x$default
  if (x$type == "integer") {
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



examsTemplateUI <- function(id) {
  uiOutput(NS(id, "controls"))
}

examsTemplateServer <- function(id, selectedTemplateFolder) {
  stopifnot(is.reactive(selectedTemplateFolder))
  
  moduleServer(id, function(input, output, session) {
    
    output$controls <- renderUI({
      templateFile = grep(".tex",dir(file.path("templates", selectedTemplateFolder()), full.names = TRUE),fixed = T,value = T)
      templateChoices = grep(".tex",dir(file.path("templates", selectedTemplateFolder()), full.names = FALSE),fixed = T,value = T)
      selectInput(NS(id, "templateFile"), "Pick a template file", choices = setNames(templateFile, templateChoices))
    })
    
    reactive(input$templateFile)
    #reactive(if (is.null(selectedTemplateFolder())) NULL else input$templateFile)
  })
}


examsTemplateOptionsUI <- function(id) {
  uiOutput(NS(id, "controls"))
}

getTemplateOptions <- function(templateName) {
  #templateName <- "templates/tex/plain.tex"
  
  #TODO: add other template-styles md, ...
  
  # FIXME: use base R only !
  x <- unlist(lapply(readLines(templateName), function(x)qdapRegex::ex_between(x, "\\\\def\\\\@", "{#")))
  x <- if (all(is.na(x))) NA else x[!is.na(x)]
  # TODO: default values or remove NULL values at the end
  if (all(is.na(x))) NULL else setNames(vector("list", length(x)), x)
}

examsTemplateOptionsServer <- function(id, templateName) {
  stopifnot(is.reactive(templateName))
  
  moduleServer(id, function(input, output, session) {
    
    vars <- reactive({
      if (is.null(templateName())) NULL else names(getTemplateOptions(templateName()))
      })
    
      output$controls <- renderUI({
        if (is.null(vars())) {p("No further options available.")} else {
          tagList(
            p("Further options for the template:"),
        lapply(vars(), function(var) {
          textInput(NS(id, var), label=as.character(var), value = NULL)
        }))
        }

    })
      
    reactive({
      each_var <- lapply(vars(), function(var) {
        input[[var]]
      })
      names(each_var) <- vars()
      each_var
    })
  })
}



examsExportApp <- function() {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        exportFormatInput("exportFormat"),
        examsArgumentUI("examsArgument")
      ),
      mainPanel(
        fluidPage(
          column(4,
                 examsTemplateUI("examsTemplate"),
                 examsTemplateOptionsUI("examsTemplateOptions"),
                 p("Template options:"),
                 verbatimTextOutput("templateOptions")
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
    
    # reactVals <- reactiveValues(
    #   mytemplate = "exam.tex"
    # )
    
    exportFormat <- exportFormatServer("exportFormat")
    
    examsArgument <- examsArgumentServer("examsArgument", exportFormat$selectedArgument)
    
    examsTemplate <- examsTemplateServer("examsTemplate", exportFormat$selectedTemplateFolder)
    
    examsTemplateOptions <- examsTemplateOptionsServer("examsTemplateOptions", examsTemplate) #reactive("exam.tex")
    
    # examsTemplate <- reactive(if (is.null(exportFormat$selectedTemplateFolder())) NULL else examsTemplateServer("examsTemplate", exportFormat$selectedTemplateFolder))
    # 
    # examsTemplateOptions <- reactive(if (is.null(examsTemplate())) NULL else examsTemplateOptionsServer("examsTemplateOptions", examsTemplate)) #reactive("exam.tex"))
    
    dir.create(tdir <- tempfile())
    
    mylist <-reactive({
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      ll$template <- examsTemplate()
      ll$header <- examsTemplateOptions()
      ll
    })
    
    output$selectedCommand <- renderPrint(print(exportFormat$selectedCommand()))
    output$compileCommand <- renderPrint(print(mylist()))
    #output$compileCommand <- renderPrint(print(examsArgument()))
    output$tempDirectory <- renderPrint(print(tdir))
    output$templateOptions <- renderPrint(print(examsTemplateOptions()))
    output$mytest <- renderPrint(print(examsTemplate()))
    
    

    
    observeEvent(input$compileExam, {
      #message("running exams2xyz")
      # exams2pdf("dist.Rmd")
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      ll$template <- examsTemplate()
      ll$header <- examsTemplateOptions()
      do.call(exportFormat$selectedCommand(),ll)
      output$generatedExams <- renderPrint(print(list.files(tdir)))
    })
  }
  shinyApp(ui, server)
}

examsExportApp()
