library(shiny)
library(exams)
library(jsonlite)

## ToDo: defalut values instead of initial values of shiny inputs, but see https://github.com/rstudio/shiny/issues/559; perhaps workaround 0 -> NULL ?!?


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
      selectedArgument = listOfAllExportFormats[[1]]$argument
    )
    
    output$exportFormatSelection <- renderUI({
      selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
    })
    
    observeEvent(input$exportFormat,{
      reactVals$selectedCommand <- listOfAllExportFormats[[which(names == input$exportFormat)]]$command
      reactVals$selectedArgument <- listOfAllExportFormats[[which(names == input$exportFormat)]]$argument
      })
    
    
    
    list(
      selectedCommand = reactive(reactVals$selectedCommand),
      #which(names == input$exportFormat)
      ## FIXME: Error in [[: attempt to select less than one element in get1index 
      #dataList=reactive(listOfAllExportFormats[[which(names == input$exportFormat)]]$argument)
      dataList=reactive(reactVals$selectedArgument)
      #dataList = reactive(readRDS(paste0(input$exportFormat,".rds")))
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
      purrr::map(vars(), function(var) make_ui(df()[[var]], NS(id, var), var))
    })
    
    reactive({
      each_var <- purrr::map(vars(), function(var) getArgumentValues(df()[[var]], input[[var]]))
      #each_var <- map(vars(), function(var) input[[var]])
      names(each_var) <- vars()
      #print(each_var)
      #paste0(each_var,collapse = ";; ")
      each_var
    })
  })
}



examsExportApp <- function() {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        exportFormatInput("exportFormat"),
        examsArgumentUI("examsArgument"),
      ),
      mainPanel(
        #textOutput("compileCommand")
        p("Selected exams2xyz:"),
        verbatimTextOutput("selectedCommand"),
        p("List of arguments:"),
        verbatimTextOutput("compileCommand"),
        actionButton("compileExam",label = "Compile Exam"),
        p("Temp Dir:"),
        verbatimTextOutput("tempDirectory"),
        p("Generated Exams:"),
        verbatimTextOutput("generatedExams")
      )
    )
  )
  server <- function(input, output, session) {
    
    
    exportFormat <- exportFormatServer("exportFormat")
    
    examsArgument <- examsArgumentServer("examsArgument", exportFormat$dataList)
    
    dir.create(tdir <- tempfile())
    
    output$selectedCommand <- renderPrint(print(exportFormat$selectedCommand()))
    output$compileCommand <- renderPrint(print(examsArgument()))
    output$tempDirectory <- renderPrint(print(tdir))

    
    observeEvent(input$compileExam, {
      #message("running exams2xyz")
      # exams2pdf("dist.Rmd")
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      do.call(exportFormat$selectedCommand(),ll)
      output$generatedExams <- renderPrint(print(list.files(tdir)))
    })
  }
  shinyApp(ui, server)
}

examsExportApp()
