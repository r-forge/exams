library(shiny)
library(shinyAce)
library(DT)
library(exams)
library(tth)

editTabUI <- function(id){
  
  ns = NS(id)
  tabPanel("Create/Edit Exercises",
           br(),
           fluidRow(
             column(4,
                    uiOutput(ns("select_imported_exercise")),
                    conditionalPanel('input.selected_exercise != ""', uiOutput(ns("show_selected_exercise")))
             ),
             column(4,
                    selectInput(ns("exencoding"), label = "Encoding?", choices = c("ascii", "utf8", "latin1", "latin2", "latin3",
                                                                               "latin4", "latin5", "latin6", "latin7", "latin8", "latin9", "latin10"),
                                selected = "utf8")
             )
           ),
           fluidRow(
             column(9,
                    uiOutput(ns("editor"), inline = TRUE, container = div),
                    uiOutput(ns("player"), inline = TRUE, container = div),
                    fluidRow(
                      column(3, style = "margin-top: 25px;", uiOutput(ns("playbutton"))),
                      column(3, style = "margin-top: 0px;",
                             selectInput(ns("exconverter"), label = "Converter?",
                                         choices = c("ttm", "tth", "pandoc", "tex2image"))),
                      column(3, style = "margin-top: 20px;",
                             checkboxInput(ns("exmathjax"), "MathJax?"))
                    )
             ),
             column(3,
                    selectInput(ns("exmarkup"), label = "Load a template. Markup?", choices = c("LaTeX", "Markdown"),
                                selected = "LaTeX"),
                    selectInput(ns("extype"), label = ("Type?"),
                                choices = c("num", "schoice", "mchoice", "string", "cloze"),
                                selected = "num"),
                    actionButton(ns("load_editor_template"), label = "Load template"),
                    hr(),
                    selectInput(ns("exams_exercises"), label = "Load exams package exercises.",
                                choices = list.files(file.path(find.package("exams"), "exercises")),
                                selected = "boxplots.Rnw"),
                    actionButton(ns("load_editor_exercise"), label = "Load exercise")
             )
          ),
          tags$hr(),
           uiOutput(ns("exnameshow")),
           actionButton(ns("save_ex"), label = "Save exercise"),
           br(), br()
           
           
  )
}

editTabServer <- function(id, pathToFolder, tabChanged) {
  stopifnot(is.reactive(pathToFolder))
  stopifnot(is.reactive(tabChanged))

  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
  reactVals <- reactiveValues(
    # path to the temporary folder, on which the user has access
    pathToFolderLocal = NULL,
    # all available exercises, i.e. all files in or added to tmp/exercises
    availableExercises = NULL
    )
  
  observe({
    reactVals$pathToFolderLocal = pathToFolder()
  })   
  
  observe({
    e1 <- tabChanged()
    reactVals$availableExercises  <- getExercises(reactVals$pathToFolderLocal)
  })

  
  ##################
  
  output$select_imported_exercise <- renderUI({
    selectInput(ns('selected_exercise'), 'Select exercise to be modified.',
                reactVals$availableExercises)
  })
  
  output$show_selected_exercise <- renderUI({
    if(!is.null(input$selected_exercise)) {
      if(input$selected_exercise != "") {
        excode <- readLines(file.path(reactVals$pathToFolderLocal,"exercises", input$selected_exercise))
        output$exnameshow <- renderUI({
          textInput(ns("exname"), label = "Exercise name.", value = input$selected_exercise)
        })
        output$editor <- renderUI({
          aceEditor(ns("excode"), mode = if(input$exmarkup == "LaTeX") "latex" else "markdown",
                    value = paste(excode, collapse = '\n'), autoComplete = "live", theme = "dreamweaver")
        })
      }
      return(NULL)
    } else return(NULL)
  })
  
  output$editor <- renderUI({
    aceEditor(ns("excode"), mode = if(input$exmarkup == "LaTeX") "latex" else "markdown",
              value = "Create/edit exercises here!", autoComplete = "live", theme = "dreamweaver")
  })
  
  output$playbutton <- renderUI({
    actionButton(ns("play_exercise"), label = "Show preview")
  })
  
  output$exnameshow <- renderUI({
    textInput(ns("exname"), label = "Exercise name.", value = input$exname)
  })
  
  observeEvent(input$load_editor_template, {
    exname <- paste("template-", input$extype, ".", if(input$exmarkup == "LaTeX") "Rnw" else "Rmd", sep = "")
    excode <- get_template_code(input$extype, input$exmarkup)
    output$exnameshow <- renderUI({
      textInput(ns("exname"), label = "Exercise name.", value = exname)
    })
    output$editor <- renderUI({
      aceEditor(ns("excode"), mode = if(input$exmarkup == "LaTeX") "latex" else "markdown",
                value = paste(excode, collapse = '\n'), autoComplete = "live", theme = "dreamweaver")
    })
  })
  
  observeEvent(input$load_editor_exercise, {
    exname <- input$exams_exercises
    expath <- file.path(find.package("exams"), "exercises", exname)
    excode <- readLines(expath)
    output$exnameshow <- renderUI({
      textInput(ns("exname"), label = "Exercise name.", value = exname)
    })
    markup <- tolower(file_ext(exname))
    output$editor <- renderUI({
      aceEditor(ns("excode"), mode = if(markup == "rnw") "latex" else "markdown",
                value = paste(excode, collapse = '\n'),  autoComplete = "live", theme = "dreamweaver")
    })
  })
  
  observeEvent(input$save_ex, {
    if(input$exname != "") {
      writeLines(input$excode, file.path(reactVals$pathToFolderLocal,"exercises", input$exname))
    }
  })
  
  observeEvent(input$play_exercise, {
    excode <- input$excode
    output$playbutton <- renderUI({
      actionButton(ns("show_editor"), label = "Hide preview")
    })
  })
  
  observeEvent(input$show_editor, {
    output$playbutton <- renderUI({
      actionButton(ns("play_exercise"), label = "Show preview")
    })
  })
  
  exercise_code <- reactive({
    excode <- input$excode
  })
  
  output$player <- renderUI({
    if(!is.null(input$play_exercise)) {
      if(input$play_exercise > 0) {
        unlink(dir(reactVals$pathToFolderLocal,"tmp", full.names = TRUE, recursive = TRUE))
        excode <- exercise_code()
        if(excode[1] != "Create/edit exercises here!") {
          exname <- if(is.null(input$exname)) paste("shinyEx", input$exmarkup, sep = ".") else input$exname
          exname <- basename(exname)
          writeLines(excode, file.path(reactVals$pathToFolderLocal,"tmp", exname))
          ex <- try(exams2html(exname, n = 1, name = "preview", dir = file.path(reactVals$pathToFolderLocal,"tmp"), edir = file.path(reactVals$pathToFolderLocal,"tmp"),
                               base64 = TRUE, encoding = input$exencoding, converter = input$exconverter,
                               mathjax = input$exmathjax), silent = TRUE)
          if(!inherits(ex, "try-error")) {
            hf <- "preview1.html"	    
            html <- readLines(file.path(reactVals$pathToFolderLocal,"tmp", hf))
            n <- c(which(html == "<body>"), length(html))
            html <- c(
              html[1L:n[1L]],                  ## header
              '<div style="border: 1px solid black;border-radius:5px;padding:8px;">', ## border
              html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
              '</div>', '</br>',               ## border
              html[(n[2L] - 1L):(n[2L])]       ## footer
            )
            writeLines(html, file.path(reactVals$pathToFolderLocal,"tmp", hf))
            return(includeHTML(file.path(reactVals$pathToFolderLocal,"tmp", hf)))
          } else {
            return(HTML(paste('<div>', ex, '</div>')))
          }
        } else return(NULL)
      } else return(NULL)
    } else return(NULL)
  })
  
  
  ##################
  
  
 
})
}
