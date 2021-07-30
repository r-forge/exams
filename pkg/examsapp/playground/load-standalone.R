library(shiny)
library(exams)
library(jsonlite)

# function creates temporary folder with subfolders
makeTmpPath <- function(){
  owd <- getwd()
  dir = NULL
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }
  dir <- path.expand(dir)
  #print(dir)
  
  lapply(c("exercises","tmp","exams","templates"),function(x) {
    if(!file.exists(file.path(dir, x))) {
      dir.create(file.path(dir, x))
    } else {
      tf <- dir(file.path(dir, x), full.names = TRUE)
      unlink(tf)
    }
  })
  
  return(file.path(dir))
}


### 


examsLoadApp <- function() {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        p("Hallo!!")
      ),
      mainPanel(
        fluidPage(
          column(4,
                 p("ENDE examsTemplate!!"),
                 fileInput("ex_upload", NULL, multiple = TRUE,
                           accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd", "zip", "tar.gz",
                                      "jpg", "JPG", "png", "PNG"))
                 ),
          column(8,
                 DT::dataTableOutput(ns("outputAddedFiles")),
        p("My Test:")
      )))
    )
  )
  
  server <- function(input, output, session) {
    
    reactVals <- reactiveValues(
      # path to the temporary folder
      pathToTmpFolder = NULL)
    
    observe({
      reactVals$pathToTmpFolder = makeTmpPath()})
    
    # reactVals <- reactiveValues(
    #   mytemplate = "exam.tex"
    # )
    
    ## from exams_shiny.R
    observeEvent(input$ex_upload, {
      if(!is.null(input$ex_upload$datapath)) {
        for(i in seq_along(input$ex_upload$name)) {
          fext <- tolower(file_ext(input$ex_upload$name[i]))
          if(fext %in% c("rnw", "rmd")) {
            file.copy(input$ex_upload$datapath[i], file.path(reactVals$pathToTmpFolder,"exercises", input$ex_upload$name[i]))
          } else {
            tdir <- tempfile()
            dir.create(tdir)
            owd <- getwd()
            setwd(tdir)
            file.copy(input$ex_upload$datapath[i], input$ex_upload$name[i])
            if(fext == "zip") {
              unzip(input$ex_upload$name[i], exdir = ".")
            } else {
              untar(input$ex_upload$name[i], exdir = ".")
            }
            file.remove(input$ex_upload$name[i])
            cf <- dir(tdir)
            file.copy(cf, file.path(reactVals$pathToTmpFolder, "exercises"), recursive = TRUE)
            setwd(owd)
            unlink(tdir)
          }
        }
      }
    })

  }
  shinyApp(ui, server)
}

examsLoadApp()
