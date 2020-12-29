library(shiny)
library(purrr)
library(exams)

########

# x <- list()
# x$n <- list(argumentDescription = "The number of copies to be compiled from file",range ="integer",default=1L)
# x$nsamp <- list(argumentDescription = "The number(s) of exercise files sampled from each list element of file",range ="integer",default=NULL)
# x$template <- list(argumentDescription = "A specification of a LaTeX template",range =c("exam","solution","plain"),default=NULL)
# x$header <- list(argumentDescription = "A list of further options to be passed to the LaTeX files",range ="list",default="list(Date = Sys.Date())")
# x$name <- list(argumentDescription = "A name prefix for resulting exercises, by default chosen based on template",range ="character",default=NULL)
# x$encoding <- list(argumentDescription = "The default encoding to assume for file",range ="character",default="")
# x
# saveRDS(x,file = "exams2pdf.rds")
# 
# x <- list()
# x$n <- list(argumentDescription = "The number of copies to be compiled from file",range ="integer",default=1L)
# x$nsamp <- list(argumentDescription = "The number(s) of exercise files sampled from each list element of file",range ="integer",default=NULL)
# x$template <- list(argumentDescription = "A specification of a LaTeX template",range =c("plain"),default=NULL)
# x$name <- list(argumentDescription = "A name prefix for resulting exercises, by default chosen based on template",range ="character",default=NULL)
# x$question <- list(argumentDescription = "The header for resulting questions. FALSE removes the header for questions",range ="character",default="<h4>Question</h4>")
# x$solution <- list(argumentDescription = "The header for resulting solutions. FALSE removes the header for solutions",range ="character",default="<h4>Solution</h4>")
# x$mathjax <- list(argumentDescription = "Should the JavaScript from http://www.MathJax.org/ be included for rendering mathematical formulas?",range ="logical",default=NULL)
# x$resolution <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=100)
# x$width <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=4)
# x$height <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=4)
# x$svg <- list(argumentDescription = "Should graphics be rendered in SVG or PNG (default)?",range ="logical",default=FALSE)
# x$encoding <- list(argumentDescription = "The default encoding to assume for file",range ="character",default="")
# x
# saveRDS(x,file = "exams2html.rds")

###########

exportFormatInput <- function(id) {
  exportFormats <- list.files(".",glob2rx("*.rds"))
  names <- tools::file_path_sans_ext(exportFormats)
  selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
}

exportFormatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    list(
      selectedFormat = reactive(input$exportFormat),
      dataList = reactive(readRDS(paste0(input$exportFormat,".rds")))
    )
  })
}




examsArgumentUI <- function(id) {
  uiOutput(NS(id, "controls"))
}

make_ui <- function(x, id, var) {
  argumentLabel <- paste0(x$argumentDescription," (",var,")")
  argumentValue <- x$default
  if (x$range == "integer") {
    sliderInput(id, label = argumentLabel, min = 1, max = 50, value = argumentValue)
  } else if (x$range == "numeric") {
    numericInput(id, label = argumentLabel, min = 1, max = 1000, value = argumentValue)
  } else if (x$range == "logical") {
    checkboxInput(id, label = argumentLabel, value = argumentValue)
  } else if(x$range %in% c("character","list")) {
    textInput(id, label=argumentLabel, value = argumentValue)
  } else {
    selectInput(id, label=argumentLabel,choices = x$range, selected = argumentValue)
    # Not supported
    # NULL
  }
}

getArgumentValues <- function(x, val) {
  if (x$range %in% c("integer","numeric","logical")) {
    val
  } else if (x$range == "character") {
    as.character(val)
  } else if (x$range == "list") {
    eval(parse(text=as.character(val)))
  }else {
    # Not supported
    val
  }
}

examsArgumentServer <- function(id, df) {
  stopifnot(is.reactive(df))
  
  moduleServer(id, function(input, output, session) {
    vars <- reactive(names(df()))
    
    output$controls <- renderUI({
      map(vars(), function(var) make_ui(df()[[var]], NS(id, var), var))
    })
    
    reactive({
      each_var <- map(vars(), function(var) getArgumentValues(df()[[var]], input[[var]]))
      #each_var <- map(vars(), function(var) input[[var]])
      names(each_var) <- vars()
      #print(each_var)
      #paste0(each_var,collapse = ";; ")
      each_var
    })
  })
}

myfun = function(x) paste0("Hallo ",x) 
map


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
        verbatimTextOutput("selectedFormat"),
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
    
    output$selectedFormat <- renderPrint(print(exportFormat$selectedFormat()))
    output$compileCommand <- renderPrint(print(examsArgument()))
    output$tempDirectory <- renderPrint(print(tdir))

    
    observeEvent(input$compileExam, {
      #message("running exams2xyz")
      # exams2pdf("dist.Rmd")
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      do.call(exportFormat$selectedFormat(),ll)
      output$generatedExams <- renderPrint(print(list.files(tdir)))
    })
  }
  shinyApp(ui, server)
}

examsExportApp()
