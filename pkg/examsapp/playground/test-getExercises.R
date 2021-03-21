library(shiny)
library(tools)


# exfiles <- list.files("testExercises/", recursive = TRUE)
# exfiles
# dirname(exfiles)
# basename(exfiles)
# data.frame("Folder" = dirname(exfiles), "File" = basename(exfiles))

from <- "dir1"
to   <- "dir2"
file.copy(list.files(from, full.names = TRUE), 
          to, 
          recursive = TRUE)

file <- exfiles[1]
dir.exists("versuch/")
dir.create(paste0("versuch/",dirname(file)),recursive = T)

file.copy(paste0("testExercises/",file),tmpDir)


fileCopySubdir <- function(file,dirFrom,dirTo) {
  tmpDir <- paste0(dirTo,"/",dirname(file))
  if (!dir.exists(tmpDir)) dir.create(tmpDir,recursive = T)
  file.copy(paste0(dirFrom,"/",file),tmpDir)
}



exfiles <- list.files("testExercises",full.names = F,recursive = T)

fileCopySubdir(exfiles[1],dirFrom = "testExercises",dirTo = "versuch")

dirname(exfiles[1])

file.copy(exfiles[1],"versuch",recursive = T)

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

mytmp <- makeTmpPath()

getExercises <- function(path){
  exfiles <- list.files(paste0(path,"/","exercises"), recursive = TRUE)
  exfiles <- exfiles[tolower(file_ext(exfiles)) %in% c("rnw", "rmd")]
  return(exfiles)
}



ui<-
  fluidPage(
    fluidRow(
      column(4,
             h2("Reactive Test"),
             textInput("Test_R","Test_R"),
             textInput("Test_R2","Test_R2"),
             textInput("Test_R3","Test_R3"),
             tableOutput("React_Out")
      ),
      column(4,
             h2("Observe Test"),
             textInput("Test","Test"),
             textInput("Test2","Test2"),
             textInput("Test3","Test3"),
             tableOutput("Observe_Out")
      ),
      column(4,
             h2("Observe Event Test"),
             textInput("Test_OE","Test_OE"),
             textInput("Test_OE2","Test_OE2"),
             textInput("Test_OE3","Test_OE3"),
             tableOutput("Observe_Out_E"),
             actionButton("Go","Test")
      )
      
    ),
    fluidRow(
      column(8,
             h4("Note that observe and reactive work very much the same on the surface,
       it is when we get into the server where we see the differences, and how those
       can be exploited for diffrent uses."),
             tableOutput("availableExercises")
      ))
    
  )

server<-function(input,output,session){
  
  reactVals <- reactiveValues(
    pathToTmpFolder = NULL)
  
  observe({reactVals$pathToTmpFolder = makeTmpPath()})
  
  availableExercises <- reactive({
    e1 <- input$Test_R
    exfiles <- getExercises(reactVals$pathToTmpFolder)
    return(exfiles)
  })
  
  output$availableExercises<-renderTable({
    exfiles <- availableExercises()
    data.frame("Folder" = dirname(exfiles), "File" = basename(exfiles))
  })
  
  # Create a reactive Evironment. Note that we can call the varaible outside same place
  # where it was created by calling Reactive_Var(). When the varaible is called by
  # renderTable is when it is evaluated. No real diffrence on the surface, all in the server.
  
  Reactive_Var<-reactive({c(input$Test_R, input$Test_R2, input$Test_R3)})
  
  output$React_Out<-renderTable({
    Reactive_Var()
  })
  
  # Create an observe Evironment. Note that we cannot access the created "df" outside 
  # of the env. A, B,and C will update with any input into any of the three Text Feilds.
  observe({
    A<-input$Test
    B<-input$Test2
    C<-input$Test3
    df<-c(A,B,C)
    output$Observe_Out<-renderTable({df})
  })
  
  #We can change any input as much as we want, but the code wont run until the trigger
  # input$Go is pressed.
  observeEvent(input$Go, {
    A<-input$Test_OE
    B<-input$Test_OE2
    C<-input$Test_OE3
    df<-c(A,B,C)
    output$Observe_Out_E<-renderTable({df})
  })
  
}
shinyApp(ui, server)