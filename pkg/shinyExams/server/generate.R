##### create #####

final_exam <- reactive({
  input$save_exam
  if (length(list.files(directories$exams))) {
    exname <- paste(input$exam_name, "rda", sep = ".")
    load(exname)
    return(eval(parse(text = exname)))
  } else return(NULL)
})

output$exercises4exam <- renderUI({
  if (!is.null(ex <- final_exam())) {
    ex
  } else {
    input$exam_name
  }
})

observeEvent(input$save_exam, {
  
})

observeEvent(input$compile, {
  if(length(input$mychooser$right)) {
    unlink(dir("exams", full.names = TRUE))
    ex <- NULL
    if(input$format == "PDF") {
      ex <- exams2pdf(input$mychooser$right, n = input$n,
        dir = "exams", edir = "exercises", name = input$name)
    }
    if(input$format == "HTML") {
      ex <- exams2html(input$mychooser$right, n = input$n,
        dir = "exams", edir = "exercises", name = input$name)
    }
    if(input$format == "QTI12") {
      ex <- exams2qti12(input$mychooser$right, n = input$n,
        dir = "exams", edir = "exercises", name = input$name)
    }
    if(!is.null(ex))
      save(ex, file = file.path("exams", paste(input$name, "rda", sep = ".")))
  } else return(NULL)
})

dlinks <- eventReactive(input$compile, {
  dir("exams", full.names = TRUE)
})

output$exams <- renderText({
  basename(dlinks())
})

output$downloadData <- downloadHandler(
  filename = function() {
    paste(input$name, "zip", sep = ".")
  },
  content = function(file) {
    owd <- getwd()
    setwd(file.path(owd, "exams"))
    zip(zipfile = paste(input$name, "zip", sep = "."), files = list.files(file.path(owd, "exams")))
    setwd(owd)
    file.copy(file.path("exams", paste(input$name, "zip", sep = ".")), file)
  }
)
