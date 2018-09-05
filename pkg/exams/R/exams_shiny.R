exams_shiny <- function(dir = NULL)
{
  stopifnot(require("shiny"))
  stopifnot(require("shinyAce"))
  stopifnot(require("DT"))
  stopifnot(require("tools"))

  owd <- getwd()
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }
  dir <- path.expand(dir)
  if(!file.exists(file.path(dir, "www")))
    dir.create(file.path(dir, "www"))
  if(!file.exists(file.path(dir, "exercises"))) {
    dir.create(file.path(dir, "exercises"))
  } else {
    ex <- dir(file.path(dir, "exercises"), full.names = TRUE, recursive = TRUE)
    file.remove(ex)
  }
  if(!file.exists(file.path(dir, "tmp"))) {
    dir.create(file.path(dir, "tmp"))
  } else {
    tf <- dir(file.path(dir, "tmp"), full.names = TRUE)
    unlink(tf)
  }
  if(!file.exists(file.path(dir, "exams"))) {
    dir.create(file.path(dir, "exams"))
  } else {
    tf <- dir(file.path(dir, "exams"), full.names = TRUE)
    unlink(tf)
  }
  if(!file.exists(file.path(dir, "extemplates"))) {
    dir.create(file.path(dir, "templates"))
  } else {
    tf <- dir(file.path(dir, "templates"), full.names = TRUE)
    unlink(tf)
  }

  for(j in c("nops", "pandoc", "tex", "xml"))
    file.copy(file.path(find.package("exams"), j), file.path(dir, "templates"), recursive = TRUE)
  if(!file.exists(ut <- file.path(dir, "templates", "user")))
    dir.create(ut)

  dump("exams_shiny_ui", file = file.path(dir, "ui.R"), envir = .GlobalEnv)
  dump("exams_shiny_server", file = file.path(dir, "server.R"), envir = .GlobalEnv)

  runApp(dir)
}


exams_shiny_ui <- function(...) {
  pageWithSidebar(
     ## Application title.
     headerPanel("R exams manager"),
     
     NULL,

     ## Show a plot of the generated distribution.
     mainPanel(
       tags$style(HTML("
         .gray-node {
           color: #E59400;
         }
       ")),
       tabsetPanel(
         tabPanel("Create/Edit Exercises",
           br(),
           fluidRow(
             column(4,
               uiOutput("select_imported_exercise"),
               conditionalPanel('input.selected_exercise != ""', uiOutput("show_selected_exercise"))
             ),
             column(4,
               selectInput("exencoding", label = "Encoding?", choices = c("ASCII", "UTF-8", "Latin-1", "Latin-2", "Latin-3",
                 "Latin-4", "Latin-5", "Latin-6", "Latin-7", "Latin-8", "Latin-9", "Latin-10"),
                 selected = "UTF-8")
             )
           ),
           fluidRow(
             column(9,
               uiOutput("editor", inline = TRUE, container = div),
               uiOutput("player", inline = TRUE, container = div),
               uiOutput("playbutton")
             ),
             column(3,
               selectInput("exmarkup", label = "Load a template. Markup?", choices = c("LaTeX", "Markdown"),
                 selected = "LaTeX"),
               selectInput("extype", label = ("Type?"),
                 choices = c("num", "schoice", "mchoice", "string", "cloze"),
                 selected = "num"),
               actionButton("load_editor_template", label = "Load template"),
               hr(),
               selectInput("exams_exercises", label = "Load exams package exercises.",
                 choices = list.files(file.path(find.package("exams"), "exercises")),
                 selected = "boxplots.Rnw"),
               actionButton("load_editor_exercise", label = "Load exercise")
             )
           ),
           tags$hr(),
           uiOutput("exnameshow"),
           actionButton("save_ex", label = "Save exercise"),
           br(), br()
         ),
         tabPanel("Import/Export Exercises",
           br(),
           p("Import exercises in", strong('.Rnw'), ",", strong(".Rmd"),
            "format, also provided as", strong(".zip"), "or", strong(".tar.gz"), "files!",
            "Import images in", strong(".jpg"), "and", strong("png"), "format!",
            "Import an existing project!"),
           fileInput("ex_upload", NULL, multiple = TRUE,
             accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd", "zip", "tar.gz",
               "jpg", "JPG", "png", "PNG")),
           tags$hr(),
           ## verbatimTextOutput("show_exercises"),
           DT::dataTableOutput("ex_table"),
           uiOutput("deletebutton"),
           uiOutput("ex_table_hr"),
           downloadButton('download_exercises', 'Download as .zip'),
           br()
         ),
         tabPanel("Define Exams",
           fluidRow(
             column(6,
               br(),
               p(tags$b("Select exercises for your exam.")),
               DT::dataTableOutput("ex_table_define"),
               br(),
               uiOutput("selectbutton"),
               br()
             ),
             column(6,
               br(),
               p(tags$b("Set points and exercise number.")),
               DT::dataTableOutput("ex_table_set"),
               br(),
               uiOutput("rmexexambutton"),
               br(),
               textInput("exam_name", "Name of the exam.", "Exam1"),
               uiOutput("saveexambutton"),
               br()
             )
           )
         ),
         tabPanel("Generate Exams",
           br(),
           p("Compile exams, please select input parameters."),
           uiOutput("choose_exam"),
           textInput("name", "Choose a name.", value = "Exam1"),
           selectInput("format", "Format.", c("PDF", "HTML", "QTI12")),
           uiOutput("template"),
           numericInput("n", "Number of copies.", value = 1),
           actionButton("compile", label = "Compile."),
           downloadButton('downloadData', 'Download all files as .zip'),
           br(),
           br(),
           p("Files for download."),
           verbatimTextOutput("exams")
         )
       )
     )
   )
}


exams_shiny_server <- function(input, output, session)
{
  available_exercises <- reactive({
    e1 <- input$save_ex
    e2 <- input$ex_upload
    e3 <- input$delete_exercises
    exfiles <- list.files("exercises", recursive = TRUE)
    if(!is.null(input$selected_exercise)) {
      if(input$selected_exercise != "") {
        if(input$selected_exercise %in% exfiles) {
          i <- which(exfiles == input$selected_exercise)
          exfiles <- c(exfiles[i], exfiles[-i])
        }
      }
    }
    return(exfiles)
  })

  output$select_imported_exercise <- renderUI({
    selectInput('selected_exercise', 'Select exercise to be modified.',
      available_exercises())
  })

  output$show_selected_exercise <- renderUI({
    if(!is.null(input$selected_exercise)) {
      if(input$selected_exercise != "") {
        excode <- readLines(file.path("exercises", input$selected_exercise))
        output$exnameshow <- renderUI({
          textInput("exname", label = "Exercise name.", value = input$selected_exercise)
        })
        output$editor <- renderUI({
          aceEditor("excode", if(input$exmarkup == "LaTeX") "tex" else "markdown",
            value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
        })
      }
      return(NULL)
    } else return(NULL)
  })

  output$editor <- renderUI({
    aceEditor("excode", if(input$exmarkup == "LaTeX") "tex" else "markdown",
      value = "Create/edit exercises here!")
  })

  output$playbutton <- renderUI({
    actionButton("play_exercise", label = "Show preview")
  })

  output$exnameshow <- renderUI({
    textInput("exname", label = "Exercise name.", value = input$exname)
  })

  observeEvent(input$load_editor_template, {
    exname <- paste("template-", input$extype, ".", if(input$exmarkup == "LaTeX") "Rnw" else "Rmd", sep = "")
    excode <- get_template_code(input$extype, input$exmarkup)
    output$exnameshow <- renderUI({
      textInput("exname", label = "Exercise name.", value = exname)
    })
    output$editor <- renderUI({
      aceEditor("excode", mode = if(input$exmarkup == "LaTeX") "tex" else "markdown",
        value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
    })
  })

  observeEvent(input$load_editor_exercise, {
    exname <- input$exams_exercises
    expath <- file.path(find.package("exams"), "exercises", exname)
    excode <- readLines(expath)
    output$exnameshow <- renderUI({
      textInput("exname", label = "Exercise name.", value = exname)
    })
    markup <- tolower(file_ext(exname))
    output$editor <- renderUI({
      aceEditor("excode", mode = if(markup == "rnw") "tex" else "markdown",
        value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
    })
  })

  observeEvent(input$save_ex, {
    if(input$exname != "") {
      writeLines(input$excode, file.path("exercises", input$exname))
    }
    exfiles <- list.files("exercises", recursive = TRUE)
    session$sendCustomMessage(type = 'exHandler', exfiles)
  })

  observeEvent(input$play_exercise, {
    excode <- input$excode
    output$playbutton <- renderUI({
      actionButton("show_editor", label = "Hide preview")
    })
  })

  observeEvent(input$show_editor, {
    output$playbutton <- renderUI({
      actionButton("play_exercise", label = "Show preview")
    })
  })

  exercise_code <- reactive({
    excode <- input$excode
  })

  output$player <- renderUI({
    if(!is.null(input$play_exercise)) {
      if(input$play_exercise > 0) {
        unlink(dir("tmp", full.names = TRUE, recursive = TRUE))
        excode <- exercise_code()
        if(excode[1] != "Create/edit exercises here!") {
          exname <- if(is.null(input$exname)) paste("shinyEx", input$exmarkup, sep = ".") else input$exname
          exname <- gsub("/", "_", exname, fixed = TRUE)
          writeLines(excode, file.path("tmp", exname))
          ex <- try(exams2html(exname, n = 1, name = "preview", dir = "tmp", edir = "tmp",
            base64 = TRUE, encoding = input$exencoding), silent = TRUE)
          if(!inherits(ex, "try-error")) {
            hf <- "preview1.html"	    
            html <- readLines(file.path("tmp", hf))
	    n <- c(which(html == "<body>"), length(html))
	    html <- c(
	      html[1L:n[1L]],                  ## header
	      '<div style="border: 1px solid black;border-radius:5px;padding:8px;">', ## border
	      html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
	      '</div>', '</br>',               ## border
	      html[(n[2L] - 1L):(n[2L])]       ## footer
	    )
            writeLines(html, file.path("tmp", hf))
            return(includeHTML(file.path("tmp", hf)))
          } else {
            return(HTML(paste('<div>', ex, '</div>')))
          }
        } else return(NULL)
      } else return(NULL)
    } else return(NULL)
  })

  observeEvent(input$ex_upload, {
    if(!is.null(input$ex_upload$datapath)) {
      for(i in seq_along(input$ex_upload$name)) {
        fext <- tolower(file_ext(input$ex_upload$name[i]))
        if(fext %in% c("rnw", "rmd")) {
          file.copy(input$ex_upload$datapath[i], file.path("exercises", input$ex_upload$name[i]))
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
          file.copy(cf, file.path(owd, "exercises"), recursive = TRUE)
          setwd(owd)
          unlink(tdir)
        }
      }
      exfiles <- list.files("exercises", recursive = TRUE)
      session$sendCustomMessage(type = 'exHandler', exfiles)
    }
  })

  observeEvent(available_exercises(), {
    ex <- available_exercises()
    if(length(ex)) {
      extab <- data.frame(ex)
      names(extab) <- "Exercises"
      output$ex_table <- DT::renderDataTable({extab}, editable = TRUE)
      output$deletebutton <- renderUI({
        actionButton("delete_exercises", label = "Delete selected exercises")
      })
      output$ex_table_hr <- renderUI({
        tags$hr()
      })
    } else {
      NULL
    }
  })

  observeEvent(input$delete_exercises, {
    id <- input$ex_table_rows_selected
    if(length(id)) {
      ex <- available_exercises()
      rmfile <- ex[id]
      file.remove(file.path("exercises", rmfile))
      extabs <- data.frame("Exercises" = ex[-id])
      output$ex_table_define <- DT::renderDataTable({extabs}, editable = FALSE)
      if(file.exists("exlist.rds")) {
        extab <- readRDS("exlist.rds")
        extab <- extab[extab$Exercises != rmfile, , drop = FALSE]
        if(nrow(extab) < 1)
          extab <- data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)
        else
          saveRDS(extab, file = "exlist.rds")
        output$ex_table_set <- DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
      }
    } else {
      NULL
    }
  })

  output$ex_table_define <- DT::renderDataTable({data.frame("Exercises" = NA)},
    editable = FALSE, rownames = FALSE)
  output$ex_table_set <- DT::renderDataTable({data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)},
    editable = FALSE, rownames = FALSE)

  observeEvent(available_exercises(), {
    ex <- available_exercises()
    if(length(ex)) {
      extab <- data.frame(ex)
      names(extab) <- "Exercises"
      output$ex_table_define <- DT::renderDataTable({extab}, editable = FALSE)
      output$selectbutton <- renderUI({
        actionButton("select_exercises", label = "Select")
      })
    } else {
      NULL
    }
  })

  exam_exercises <- reactive({
    e1 <- input$select_exercises
    id <- input$ex_table_define_rows_selected
    if(length(id) & length(e1)) {
      if(!file.exists("exlist.rds")) {
        ex <- available_exercises()
        extab <- data.frame("Exercises" = ex[id], stringsAsFactors = FALSE)
        extab$Points <- rep(1, nrow(extab))
        extab$Number <- 1:nrow(extab)
      } else {
        extab <- readRDS("exlist.rds")
        ex <- available_exercises()
        ex <- ex[id]
        if(!all(ex %in% extab$Exercises)) {
          extab2 <- data.frame("Exercises" = ex[!(ex %in% extab$Exercises)], stringsAsFactors = FALSE)
          extab2$Points <- rep(1, nrow(extab2))
          extab2$Number <- 1:nrow(extab2) + max(extab$Number)
          extab <- rbind(extab, extab2)
        }
      }
      saveRDS(extab, file = "exlist.rds")
    }
    return(extab)
  })

  observeEvent(input$select_exercises, {
    extab <- exam_exercises()
    output$ex_table_set <- DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    output$rmexexambutton <- renderUI({
      actionButton("rm_ex_exam", label = "Deselect")
    })
    output$saveexambutton <- renderUI({
      actionButton("save_exam", label = "Save exam")
    })
  })

  observeEvent(input$rm_ex_exam, {
    ids <- input$ex_table_set_rows_selected
    extab <- readRDS("exlist.rds")
    extab <- extab[-ids, , drop = FALSE]
    if(nrow(extab) < 1) {
      extab <- data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)
      unlink("exlist.rds")
    } else {
      saveRDS(extab, file = "exlist.rds")
    }
    output$ex_table_set <- DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
  })

  observeEvent(input$ex_table_set_cell_edit, {
    info = input$ex_table_set_cell_edit
    i = info$row
    j = info$col
    v = info$value
    extab <- readRDS("exlist.rds")
    extab[i, j] <- v
    saveRDS(extab, file = "exlist.rds")
    output$ex_table_set <- DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
  })

  output$choose_exam <- renderUI({
    selectInput('selected_exam', 'Select an exam.', "")
  })

  observeEvent(input$save_exam, {
    extab <- readRDS("exlist.rds")
    exname <- paste(input$exam_name, "rds", sep = ".")
    saveRDS(extab, file = file.path("tmp", exname))
    showNotification(paste("Saved", input$exam_name), duration = 1, closeButton = FALSE)
    output$choose_exam <- renderUI({
      exams <- dir("tmp")
      exams <- file_path_sans_ext(exams)
      if(length(exams)) {
        selectInput('selected_exam', 'Select an exam.', exams)
      }
    })
  })

  output$download_exercises <- downloadHandler(
    filename = function() {
      paste("exercises", "zip", sep = ".")
    },
    content = function(file) {
      owd <- getwd()
      dir.create(tdir <- tempfile())
      file.copy(file.path("exercises", list.files("exercises")), tdir, recursive = TRUE)
      setwd(tdir)
      zip(zipfile = paste("exercises", "zip", sep = "."), files = list.files(tdir))
      setwd(owd)
      file.copy(file.path(tdir, paste("exercises", "zip", sep = ".")), file)
      unlink(tdir)
    }
  )

  output$template <- renderUI({
    user <- dir(file.path("templates", "user"))
    if(!length(user))
      user <- NULL
    templates <- switch(input$format,
      "PDF" = grep(".tex", c(dir(file.path("templates", "tex"), full.names = TRUE), user), fixed = TRUE, value = TRUE),
      "HTML" = grep(".html", c(dir(file.path("templates", "xml"), full.names = TRUE), user), fixed = TRUE, value = TRUE),
      "QTI12" = grep(".qti12", c(dir(file.path("templates", "xml"), full.names = TRUE), user), fixed = TRUE, value = TRUE),
      "QTI21" = grep(".qti21", c(dir(file.path("templates", "xml"), full.names = TRUE), user), fixed = TRUE, value = TRUE),
    )
    selectInput('selected_template', 'Select a template.', templates)
  })

  observeEvent(input$compile, {
    exam <- readRDS(file.path("tmp", paste0(input$selected_exam, ".rds")))
    exlist <- split(exam$Exercises, as.factor(exam$Number))
    points <- unlist(sapply(split(exam$Points, as.factor(exam$Number)), function(x) { x[1] }))
    if(input$format == "PDF") {
      ex <- try(exams2pdf(exlist, n = input$n,
        dir = "exams", edir = "exercises", name = input$name, points = points,
        template = input$selected_template), silent = TRUE)
    }
    if(input$format == "HTML") {
      ex <- try(exams2html(exlist, n = input$n,
        dir = "exams", edir = "exercises", name = input$name, points = points,
        template = input$selected_template), silent = TRUE)
    }
    if(input$format == "QTI12") {
      ex <- try(exams2qti12(exlist, n = input$n,
        dir = "exams", edir = "exercises", name = input$name, points = points,
        template = input$selected_template), silent = TRUE)
    }
    if(inherits(ex, "try-error")) {
      showNotification("Error: could not compile exam!", duration = 2, closeButton = FALSE, type = "error")
      ex <- NULL
    }
    if(!is.null(ex))
      save(ex, file = file.path("exams", paste(input$name, "rda", sep = ".")))
  })

  dlinks <- eventReactive(input$compile, {
    dir("exams", full.names = TRUE)
  })
  output$exams <- renderText({
    basename(dlinks())
  })
  output$downloadData <- downloadHandler(
    filename = function() {
      time <- Sys.time()
      time <- gsub(" ", ".", time, fixed = TRUE)
      time <- gsub("-", "_", time, fixed = TRUE)
      time <- gsub(":", "_", time, fixed = TRUE)
      paste0("Exam_", time, ".zip")
    },
    content = function(file) {
      owd <- getwd()
      setwd(file.path(owd, "exams"))
      zip(zipfile = paste(input$name, "zip", sep = "."), files = list.files(file.path(owd, "exams")))
      setwd(owd)
      file.copy(file.path("exams", paste(input$name, "zip", sep = ".")), file)
    }
  )
}


get_template_code <- function(type, markup)
{
  if(markup == "LaTeX") {
    excode <- switch(type,
      "schoice" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'cities <- c("Munich", "Innsbruck", "Zurich", "Amsterdam")',
                'countries <- c("Germany", "Austria", "Switzerland", "Netherlands")',
                'question <- sample(cities, size = 1)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\begin{answerlist}',
                '  \\item Austria',
                '  \\item Germany',
                '  \\item Switzerland',
                '  \\item Netherlands',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\begin{answerlist}',
                '  \\item False.',
                '  \\item True.',
                '  \\item False.',
                '  \\item False.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{schoice}',
                '%% \\exsolution{0100}',
                '%% \\exname{Mean}',
                '%% \\exshuffle{Cities}'),
      "num" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Calculate the mean of the following numbers: \\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'The mean is $0.324$.',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{num}',
                '%% \\exsolution{0.324}',
                '%% \\exname{Mean}',
                '%% \\extol{0.01}'),
      "mchoice" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(33, 3, 33, 333)',
                'y <- c(3, 3, 1/6, 1/33.3)',
                'solutions <- x * y',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{solutions[1]} will return the solution of the first statement.',
                'Which of the following statements is correct?',
                '\\begin{answerlist}',
                '  \\item $33 \\cdot 3 = 109$',
                '  \\item $3 \\cdot 3 = 9$',
                '  \\item $33 / 6 = 5.5$',
                '  \\item $333 / 33.3 = 9$',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\begin{answerlist}',
                '  \\item False. Correct answer is $33 \\cdot 3 = 99$.',
                '  \\item True.',
                '  \\item True.',
                '  \\item False. Correct answer is $333 / 33.3 = 10$.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{mchoice}',
                '%% \\exsolution{0110}',
                '%% \\exname{Simple math}',
                '%% \\exshuffle{TRUE}'),
      "string" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'cities <- c("Munich", "Innsbruck", "Zurich", "Amsterdam")',
                'countries <- c("Germany", "Austria", "Switzerland", "Netherlands")',
                'question <- sample(cities, size = 1)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{string}',
                '%% \\exsolution{Germany}',
                '%% \\exname{Cities 2}'),
      "cloze" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                'Sd <- sd(x)',
                'Var <- var(x)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Given the following numbers: \\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\begin{answerlist}',
                '  \\item What is the mean?',
                '  \\item What is the standard deviation?',
                '  \\item What is the variance?',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\begin{answerlist}',
                '  \\item The mean is $0.324$.',
                '  \\item The standard deviation is $0.767515$.',
                '  \\item The variance is $0.58908$.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{cloze}',
                '%% \\exsolution{0.324|0.767515|0.58908}',
                '%% \\exclozetype{num|num|num}',
                '%% \\exname{Statistics}',
                '%% \\extol{0.01}')
    )
  } else {
    excode <- "Markdown templates not available yet!"
  }
  
  excode
}

