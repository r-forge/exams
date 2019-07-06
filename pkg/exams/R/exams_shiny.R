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
     headerPanel("R/exams manager"),
     
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
               selectInput("exencoding", label = "Encoding?", choices = c("ascii", "utf8", "latin1", "latin2", "latin3",
                 "latin4", "latin5", "latin6", "latin7", "latin8", "latin9", "latin10"),
                 selected = "utf8")
             )
           ),
           fluidRow(
             column(9,
               uiOutput("editor", inline = TRUE, container = div),
               uiOutput("player", inline = TRUE, container = div),
               fluidRow(
                 column(3, style = "margin-top: 25px;", uiOutput("playbutton")),
                 column(3, style = "margin-top: 0px;",
                   selectInput("exconverter", label = "Converter?",
                     choices = c("ttm", "tth", "pandoc", "tex2image"))),
                 column(3, style = "margin-top: 20px;",
                   checkboxInput("exmathjax", "MathJax?"))
               )
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
           fluidRow(
             column(2, style = "margin-top: 0px;", checkboxInput("dt_sel0", "All")),
             column(2, style = "margin-top: 0px;", checkboxInput("dt_sel0_p", "Page")),
             uiOutput("deletebutton")
           ),
           tags$hr(),
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
               fluidRow(
                 column(2, style = "margin-top: -5px;", checkboxInput("dt_sel", "All")),
                 column(2, style = "margin-top: -5px;", checkboxInput("dt_sel_p", "Page")),
                 column(2, uiOutput("selectbutton")),
                 column(2, uiOutput("blockselectbutton"))
               ),
               br()
             ),
             column(6,
               br(),
               p(tags$b("Set points and exercise number.")),
               DT::dataTableOutput("ex_table_set"),
               br(),
               fluidRow(
                 column(2, style = "margin-top: -5px;", checkboxInput("dt_sel2", "All")),
                 column(2, style = "margin-top: -5px;", checkboxInput("dt_sel2_p", "Page")),
                 column(2, uiOutput("rmexexambutton")),
                 column(2, uiOutput("blockbutton")),
                 column(2, uiOutput("unblockbutton"))
               ),
               fluidRow(
                 column(3, uiOutput("pointsbutton")),
                 column(3, uiOutput("pointsbuttonpoints"))
               ),
               actionButton("set_preview", label = "Preview"),
               tags$hr(),
               textInput("exam_name", "Name of the exam.", "Exam1"),
               uiOutput("saveexambutton"),
               br()
             )
           )
         ),
         tabPanel("Generate Exams",
           br(),
           p("Compile exams, please select input parameters."),
           fluidRow(
             column(6,
               uiOutput("choose_exam"),
               selectInput("format", "Format", c("PDF", "NOPS", "OpenOLAT", "ARSnova", "Moodle", "Blackboard", "Canvas", "QTI12", "QTI21", "TCExam", "DOCX", "HTML")),
               uiOutput("template"),
               numericInput("n", "Number of copies", value = 1)
             ),
             column(6,
               numericInput("maxattempts", "Maximal attempts", value = 1),
               numericInput("duration", "Duration in min.", value = NULL),
               numericInput("seed", "Seed", value = NA)
             )
           ),
           actionButton("compile", label = "Compile"),
           tags$hr(),
           fluidRow(
             column(2, checkboxInput("include_exercises", "Exercises", value = TRUE)),
             column(2, checkboxInput("include_template", "Template", value = TRUE)),
             column(2, checkboxInput("include_Rcode", "R code", value = TRUE))
           ),
           downloadButton('downloadData', 'Download exam as .zip'),
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
    exfiles <- exfiles[tolower(file_ext(exfiles)) %in% c("rnw", "rmd")]
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
          aceEditor("excode", mode = if(input$exmarkup == "LaTeX") "tex" else "markdown",
            value = paste(excode, collapse = '\n'))
        })
      }
      return(NULL)
    } else return(NULL)
  })

  output$editor <- renderUI({
    aceEditor("excode", mode = if(input$exmarkup == "LaTeX") "tex" else "markdown",
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
        value = paste(excode, collapse = '\n'))
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
        value = paste(excode, collapse = '\n'))
    })
  })

  observeEvent(input$save_ex, {
    if(input$exname != "") {
      writeLines(input$excode, file.path("exercises", input$exname))
    }
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
          exname <- basename(exname)
          writeLines(excode, file.path("tmp", exname))
          ex <- try(exams2html(exname, n = 1, name = "preview", dir = "tmp", edir = "tmp",
            base64 = TRUE, encoding = input$exencoding, converter = input$exconverter,
            mathjax = input$exmathjax), silent = TRUE)
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
    }
  })

  output$ex_table <- DT::renderDataTable({data.frame("Exercises" = NA)},
    editable = TRUE, rownames = FALSE)
  ex_table_proxy <- DT::dataTableProxy("ex_table")

  observeEvent(available_exercises(), {
    ex <- available_exercises()
    if(length(ex)) {
      extab <- data.frame(ex)
      names(extab) <- "Exercises"
      output$ex_table <- DT::renderDataTable({extab}, editable = TRUE)
      output$deletebutton <- renderUI({
        actionButton("delete_exercises", label = "Delete selected exercises")
      })
    } else {
      output$ex_table <- DT::renderDataTable({data.frame("Exercises" = NA)}, editable = FALSE, rownames = FALSE)
      output$ex_table_define <- DT::renderDataTable({data.frame("Exercises" = NA)}, editable = FALSE, rownames = FALSE)
      output$ex_table_set <- DT::renderDataTable({data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)}, editable = FALSE, rownames = FALSE)
      unlink("extab.rds")
      unlink(dir("exams", full.names = TRUE))
    }
  })

  observeEvent(input$dt_sel0, {
    if (isTRUE(input$dt_sel0)) {
      DT::selectRows(ex_table_proxy, input$ex_table_rows_all)
    } else {
      DT::selectRows(ex_table_proxy, NULL)
    }
  })
  observeEvent(input$dt_sel0_p, {
    if (isTRUE(input$dt_sel0_p)) {
      DT::selectRows(ex_table_proxy, input$ex_table_rows_current)
    } else {
      DT::selectRows(ex_table_proxy, NULL)
    }
  })

  styleEqual2 <- function(levels, values) {
    n = length(levels)
    if(n != length(values)) 
      stop("length(levels) must be equal to length(values)")
    if(n == 0) 
      return("''")
    levels2 = levels
    if(is.character(levels)) 
      levels2 = gsub("'", "\\'", levels)
    levels2 = sprintf("'%s'", levels2)
    levels2[is.na(levels)] = "null"
    js = ""
    for(i in seq_len(n)) {
      js = paste0(js, sprintf("value == %s ? '%s' : ", levels2[i], values[i]))
    }
    JS(paste0(js, "''"))
  }


  datatable_set <- function(x) {
    if(is.null(x$Number) | nrow(x) < 2) {
      return(DT::renderDataTable({x}, editable = TRUE, rownames = !all(is.na(unlist(x)))))
    } else {
      lN <- unique(x$Number)
      vN <- rep(c("#F9F9F9", "white"), length.out = length(lN))
      return(DT::renderDataTable(formatStyle(datatable(x, editable = TRUE, rownames = TRUE), "Number",
        backgroundColor = styleEqual2(lN, vN), target = "row")))
    }
  }

  observeEvent(input$delete_exercises, {
    id <- input$ex_table_rows_selected
    if(length(id)) {
      ex <- available_exercises()
      rmfile <- ex[id]
      if(all(file.exists(file.path("exercises", rmfile))))
        file.remove(file.path("exercises", rmfile))
      ex <- ex[-id]
      extab <- if(length(ex)) {
        data.frame("Exercises" = ex)
      } else data.frame("Exercises" = NA)
      output$ex_table <- DT::renderDataTable({extab}, editable = TRUE, rownames = length(ex) > 0)
      output$ex_table_define <- DT::renderDataTable({extab}, editable = FALSE, rownames = length(ex) > 0)
      if(file.exists("extab.rds")) {
        extab <- readRDS("extab.rds")
        extab <- extab[!(extab$Exercises %in% rmfile), , drop = FALSE]
        if(nrow(extab) < 1)
          extab <- data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)
        else
          saveRDS(extab, file = "extab.rds")
        output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
      }
    } else {
      NULL
    }
  })

  output$ex_table_define <- DT::renderDataTable({data.frame("Exercises" = NA)},
    editable = FALSE, rownames = FALSE)
  output$ex_table_set <- DT::renderDataTable({data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)},
    editable = FALSE, rownames = FALSE)

  output$selectbutton <- renderUI({
    actionButton("select_exercises", label = "Include")
  })
  output$blockselectbutton <- renderUI({
    actionButton("block_select_exercises", label = "Blockinclude")
  })
  output$rmexexambutton <- renderUI({
    actionButton("rm_ex_exam", label = "Exclude")
  })
  output$blockbutton <- renderUI({
    actionButton("block_exercises", label = "Block")
  })
  output$unblockbutton <- renderUI({
    actionButton("unblock_exercises", label = "Unblock")
  })
  output$pointsbutton <- renderUI({
    actionButton("block_points", label = "Block points")
  })
  output$pointsbuttonpoints <- renderUI({
    numericInput("block_points_p", label = NA, 1)
  })
  output$saveexambutton <- renderUI({
    actionButton("save_exam", label = "Save exam")
  })

  observeEvent(available_exercises(), {
    ex <- available_exercises()
    if(length(ex)) {
      extab <- data.frame(ex)
      names(extab) <- "Exercises"
      output$ex_table_define <- DT::renderDataTable({extab}, editable = FALSE)
    } else {
      NULL
    }
  })

  ex_table_define_proxy <- DT::dataTableProxy("ex_table_define")
  ex_table_set_proxy <- DT::dataTableProxy("ex_table_set")

  observeEvent(input$dt_sel, {
    if (isTRUE(input$dt_sel)) {
      DT::selectRows(ex_table_define_proxy, input$ex_table_define_rows_all)
    } else {
      DT::selectRows(ex_table_define_proxy, NULL)
    }
  })
  observeEvent(input$dt_sel_p, {
    if (isTRUE(input$dt_sel_p)) {
      DT::selectRows(ex_table_define_proxy, input$ex_table_define_rows_current)
    } else {
      DT::selectRows(ex_table_define_proxy, NULL)
    }
  })
  observeEvent(input$dt_sel2, {
    if (isTRUE(input$dt_sel2)) {
      DT::selectRows(ex_table_set_proxy, input$ex_table_set_rows_all)
    } else {
      DT::selectRows(ex_table_set_proxy, NULL)
    }
  })
  observeEvent(input$dt_sel2_p, {
    if (isTRUE(input$dt_sel2_p)) {
      DT::selectRows(ex_table_set_proxy, input$ex_table_set_rows_current)
    } else {
      DT::selectRows(ex_table_set_proxy, NULL)
    }
  })

  exam_exercises <- reactive({
    e1 <- input$select_exercises
    id <- input$ex_table_define_rows_selected
    ex <- available_exercises()
    if(!length(ex))
      return(data.frame("Exercises" = NA, "Points" = NA, "Number" = NA))
    if(length(id)) {
      if(!file.exists("extab.rds")) {
        extab <- data.frame("Exercises" = ex[id], stringsAsFactors = FALSE)
        extab$Points <- rep(1, nrow(extab))
        extab$Number <- 1:nrow(extab)
      } else {
        extab <- readRDS("extab.rds")
        ex <- ex[id]
        if(!all(ex %in% extab$Exercises)) {
          extab2 <- data.frame("Exercises" = ex[!(ex %in% extab$Exercises)], stringsAsFactors = FALSE)
          extab2$Points <- rep(1, nrow(extab2))
          extab2$Number <- 1:nrow(extab2) + max(extab$Number)
          extab <- rbind(extab, extab2)
        }
      }
      saveRDS(extab, file = "extab.rds")
    }
    return(extab)
  })

  exam_exercises_block <- reactive({
    e1 <- input$block_select_exercises
    id <- input$ex_table_define_rows_selected
    ex <- available_exercises()
    if(!length(ex))
      return(data.frame("Exercises" = NA, "Points" = NA, "Number" = NA))
    if(length(id)) {
      if(!file.exists("extab.rds")) {
        extab <- data.frame("Exercises" = ex[id], stringsAsFactors = FALSE)
        extab$Points <- rep(1, nrow(extab))
        extab$Number <- rep(1, nrow(extab))
      } else {
        extab <- readRDS("extab.rds")
        ex <- ex[id]
        if(!all(ex %in% extab$Exercises)) {
          extab2 <- data.frame("Exercises" = ex[!(ex %in% extab$Exercises)], stringsAsFactors = FALSE)
          extab2$Points <- rep(1, nrow(extab2))
          extab2$Number <- rep(1 + max(extab$Number), nrow(extab2))
          extab <- rbind(extab, extab2)
          extab$Number <- as.integer(as.factor(extab$Number))
          extab <- extab[order(extab$Number), , drop = FALSE]
        }
      }
      saveRDS(extab, file = "extab.rds")
    }
    return(extab)
  })

  observeEvent(input$select_exercises, {
    extab <- exam_exercises()
    output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
  })

  observeEvent(input$block_select_exercises, {
    extab <- exam_exercises_block()
    output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
  })

  observeEvent(input$rm_ex_exam, {
    ids <- input$ex_table_set_rows_selected
    if(length(ids) & file.exists("extab.rds")) {
      extab <- readRDS("extab.rds")
      extab <- extab[-ids, , drop = FALSE]
      if(nrow(extab) < 1) {
        extab <- data.frame("Exercises" = NA, "Points" = NA, "Number" = NA)
        unlink("extab.rds")
      } else {
        extab$Number <- as.integer(as.factor(extab$Number))
        extab <- extab[order(extab$Number), , drop = FALSE]
        saveRDS(extab, file = "extab.rds")
      }
      output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    }
  })

  observeEvent(input$ex_table_set_cell_edit, {
    if(file.exists("extab.rds")) {
      info = input$ex_table_set_cell_edit
      i = info$row
      j = info$col
      v = info$value
      extab <- readRDS("extab.rds")
      if(length(ids <- input$ex_table_set_rows_selected))
        i <- ids
      extab[i, j] <- v
      if(names(extab)[j] == "Number") {
        extab$Number <- as.integer(as.factor(extab$Number))
        extab <- extab[order(extab$Number), , drop = FALSE]
      }
      saveRDS(extab, file = "extab.rds")
      output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    }
  })

  observeEvent(input$block_exercises, {
    ids <- input$ex_table_set_rows_selected
    if(length(ids) & file.exists("extab.rds")) {
      extab <- readRDS("extab.rds")
      extab$Number[ids] <- extab$Number[ids][1]
      extab$Number <- as.integer(as.factor(extab$Number))
      extab <- extab[order(extab$Number), , drop = FALSE]
      saveRDS(extab, file = "extab.rds")
      output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    }
  })

  observeEvent(input$unblock_exercises, {
    ids <- input$ex_table_set_rows_selected
    if(length(ids) & file.exists("extab.rds")) {
      extab <- readRDS("extab.rds")
      extab$Number[ids] <- seq(max(extab$Number) + 1, max(extab$Number) + length(ids), by = 1)
      extab$Number <- as.integer(as.factor(extab$Number))
      extab <- extab[order(extab$Number), , drop = FALSE]
      saveRDS(extab, file = "extab.rds")
      output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    }
  })

  observeEvent(input$block_points, {
    ids <- input$ex_table_set_rows_selected
    if(length(ids) & file.exists("extab.rds")) {
      points <- input$block_points_p
      extab <- readRDS("extab.rds")
      extab$Points[ids] <- points
      saveRDS(extab, file = "extab.rds")     
      output$ex_table_set <- datatable_set(extab) ##DT::renderDataTable({extab}, editable = TRUE, rownames = !all(is.na(unlist(extab))))
    }
  })

  output$choose_exam <- renderUI({
    selectInput('selected_exam', 'Select an exam.', "")
  })

  observeEvent(input$save_exam, {
    if(file.exists("extab.rds")) {
      extab <- readRDS("extab.rds")
      exname <- paste0(input$exam_name, "_metainfo.rds")
      saveRDS(extab, file = file.path("exams", exname))
      showNotification(paste("Saved", input$exam_name), duration = 1, closeButton = FALSE)
      output$choose_exam <- renderUI({
        exams <- dir("exams")
        exams <- file_path_sans_ext(exams)
        exams <- gsub("_metainfo", "", exams, fixed = TRUE)
        if(length(exams)) {
          selectInput('selected_exam', 'Select an exam.', exams)
        }
      })
    }
  })

  output$download_exercises <- downloadHandler(
    filename = function() {
      paste("exercises", "zip", sep = ".")
    },
    content = function(file) {
      owd <- getwd()
      dir.create(tdir <- tempfile())
      file.copy(list.files("exercises", recursive = TRUE), tdir, recursive = TRUE)
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
      "QTI21" = grep(".qti21", c(dir(file.path("templates", "xml"), full.names = TRUE), user), fixed = TRUE, value = TRUE)
    )
    selectInput('selected_template', 'Select a template.', templates)
  })

  observeEvent(input$compile, {
    if(file.exists(file.path("exams", paste0(input$selected_exam, "_metainfo.rds")))) {
      if(!file.exists(file.path("exams", "current"))) {
        dir.create(file.path("exams", "current"))
      } else {
        cfiles <- dir(file.path("exams", "current"), full.names = TRUE)
        if(length(cfiles))
          unlink(cfiles)
      }
      cdir <- file.path("exams", "current")
      rds <- file.path("exams", paste0(input$selected_exam, "_metainfo.rds"))
      file.copy(rds, file.path("exams", "current", paste0(input$selected_exam, "_metainfo.rds")))
      rds <- file.path("exams", "current", paste0(input$selected_exam, "_metainfo.rds"))
      exam <- readRDS(rds)
      seed <- input$seed
      if(is.na(seed))
        seed <- as.integer(runif(1, 1, 1e+08))
      maxattempts <- 
      attr(exam, "specs") <- list(
        "name" = input$selected_exam,
        "format" = input$format,
        "template" = input$selected_template,
        "n" = input$n,
        "seed" = seed,
        "maxattempts" = input$maxattempts,
        "duration" = input$duration
      )
      saveRDS(exam, file = rds)
      name <- input$selected_exam
      exlist <- split(basename(exam$Exercises), as.factor(exam$Number))
      points <- unlist(sapply(split(exam$Points, as.factor(exam$Number)), function(x) { x[1] }))
      set.seed(seed)
      has_template <- TRUE
      if(input$format == "ARSnova") {
        ex <- try(exams2arsnova(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name), silent = TRUE)
      }
      if(input$format == "Blackboard") {
        ex <- try(exams2blackboard(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          maxattempts = input$maxattempts), silent = TRUE)
      }
      if(input$format == "HTML") {
        ex <- try(exams2html(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name,
          template = input$selected_template), silent = TRUE)
      }
      if(input$format == "NOPS") {
        ex <- try(exams2nops(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points), silent = TRUE)
      }
      if(input$format == "OpenOLAT") {
        ex <- try(exams2openolat(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          maxattempts = input$maxattempts, duration = input$duration), silent = TRUE)
      }
      if(input$format == "DOCX") {
        ex <- try(exams2pandoc(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points), silent = TRUE)
      }
      if(input$format == "PDF") {
        ex <- try(exams2pdf(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          template = input$selected_template), silent = TRUE)
      }
      if(input$format == "Canvas") {
        ex <- try(exams2canvas(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          maxattempts = input$maxattempts, duration = input$duration), silent = TRUE)
      }
      if(input$format == "QTI12") {
        ex <- try(exams2qti12(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          maxattempts = input$maxattempts, duration = input$duration), silent = TRUE)
      }
      if(input$format == "QTI21") {
        ex <- try(exams2qti12(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points,
          maxattempts = input$maxattempts, duration = input$duration), silent = TRUE)
      }
      if(input$format == "Moodle") {
        ex <- try(exams2moodle(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points), silent = TRUE)
      }
      if(input$format == "TCExam") {
        ex <- try(exams2tcexam(exlist, n = input$n,
          dir = cdir, edir = "exercises", name = name, points = points), silent = TRUE)
      }
      if(inherits(ex, "try-error")) {
        writeLines(ex)
        showNotification("Error: could not compile exam!", duration = 2, closeButton = FALSE, type = "error")
        ex <- NULL
      } else {
        output$exams <- renderText({
          basename(grep(input$selected_exam, dir(cdir, full.names = TRUE), fixed = TRUE, value = TRUE))
        })
        showNotification(paste("Compiled", input$selected_exam, "using", input$format), duration = 1, closeButton = FALSE)
      }
      if(!is.null(ex))
        save(ex, file = file.path(cdir, paste(name, "rda", sep = ".")))
    }
  })
  output$downloadData <- downloadHandler(
    filename = function() {
      time <- Sys.time()
      time <- gsub(" ", ".", time, fixed = TRUE)
      time <- gsub("-", "_", time, fixed = TRUE)
      time <- gsub(":", "_", time, fixed = TRUE)
      paste0(input$selected_exam, "_", time, ".zip")
    },
    content = function(file) {
      dir.create(tdir <- tempfile())
      owd <- getwd()
      exam <- readRDS(file.path("exams", "current", paste0(input$selected_exam, "_metainfo.rds")))
      specs <- attr(exam, "specs")
      if(input$include_exercises) {
        dir.create(file.path(tdir, "exercises"))
        for(j in exam$Exercises) {
          sp <- split_path(j)
          if(length(sp) > 1L) {
            for(i in 1L:(length(sp) - 1L)) {
              if(!file.exists(file.path(tdir, "exercises", sp[1:i]))) {
                dir.create(file.path(tdir, "exercises", sp[1:i]))
              }
            }
          }
        }
        file.copy(file.path(owd, "exercises", exam$Exercises),
          file.path(tdir, "exercises", exam$Exercises))
      }
      if(input$include_template) {
        if(specs$template != "") {
          dir.create(file.path(tdir, "templates"))
          file.copy(specs$template,
            file.path(tdir, "templates", basename(specs$template)))
        }
      }
      if(input$include_Rcode) {
        has_template <- TRUE
        if(specs$format == "ARSnova") {
          Rcall <- "exams2arsnova"
          has_template <- FALSE
        }
        if(specs$format == "Blackboard") {
          Rcall <- "exams2blackboard"
          has_template <- FALSE
        }
        if(specs$format == "HTML") {
          Rcall <- "exams2html"
        }
        if(specs$format == "NOPS") {
          Rcall <- "exams2nops"
          has_template <- FALSE
        }
        if(specs$format == "OpenOLAT") {
          Rcall <- "exams2openolat"
          has_template <- FALSE
        }
        if(specs$format == "Canvas") {
          Rcall <- "exams2canvas"
          has_template <- FALSE
        }
        if(specs$format == "DOCX") {
          Rcall <- "exams2pandoc"
          has_template <- FALSE
        }
        if(specs$format == "PDF") {
          Rcall <- "exams2pdf"
        }
        if(specs$format == "QTI12") {
          Rcall <- "exams2qti12"
          has_template <- FALSE
        }
        if(specs$format == "QTI21") {
          Rcall <- "exams2qti21"
          has_template <- FALSE
        }
        if(specs$format == "Moodle") {
          Rcall <- "exams2moodle"
          has_template <- FALSE
        }
        if(specs$format == "TCExam") {
          Rcall <- "exams2tcexam"
          has_template <- FALSE
        }
        exlist <- split(basename(exam$Exercises), as.factor(exam$Number))
        points <- unlist(sapply(split(exam$Points, as.factor(exam$Number)), function(x) { x[1] }))
        dump("exlist", file.path("tmp", "exlist.R"))
        dump("points", file.path("tmp", "points.R"))
        code <- c('library("exams")', '')
        code <- c(code, readLines(file.path("tmp", "points.R")), '')
        code <- c(code, readLines(file.path("tmp", "exlist.R")), '')
        code <- c(code, paste0('set.seed(', specs$seed, ')'), '',
          paste0(paste0('ex <- ', Rcall, '(exlist, n = ', specs$n, ','),
          paste0('  dir = ".", edir = "exercises", name = "', specs$name, '", points = points'),
          if(specs$format %in% c("Blackboard", "OpenOLAT", "Canvas", "QTI12", "QTI21")) {
            paste0(', maxattempts =', specs$maxattempts)
          } else NULL,
          if(specs$format %in% c("Blackboard", "OpenOLAT", "Canvas", "QTI12", "QTI21")) {
            if(!is.null(specs$duration))
              paste0(', duration =', specs$duration)
          } else NULL,
          if(has_template) {
            paste0(', template = "', file.path("templates", basename(specs$template)), '")')
          } else ')', collapse = '')
        )
        writeLines(code, file.path(tdir, paste0(specs$name, ".R")))
      }
      files <- grep(specs$name, list.files(file.path(owd, "exams", "current")), fixed = TRUE, value = TRUE)
      files <- files[!grepl("_metainfo.rds", files, fixed = TRUE)]
      file.copy(file.path(owd, "exams", "current", files), file.path(tdir, files))
      saveRDS(exam, file = file.path(tdir, paste0(specs$name, "_metainfo.rds")))
      setwd(tdir)
      if(length(files <- dir(include.dirs = TRUE)))
        zip(zipfile = paste(specs$name, "zip", sep = "."), files = files)
      setwd(owd)
      if(length(files))
        file.copy(file.path(tdir, paste(specs$name, "zip", sep = ".")), file)
      unlink(tdir)
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
                '\\\\begin{question}',
                '%% Enter the question here, you can access R variables with \\\\Sexpr{},',
                '%% e.g., \\\\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\\\begin{answerlist}',
                '  \\\\item Austria',
                '  \\\\item Germany',
                '  \\\\item Switzerland',
                '  \\\\item Netherlands',
                '\\\\end{answerlist}',
                '\\\\end{question}',
                '',
                '\\\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\\\begin{answerlist}',
                '  \\\\item False.',
                '  \\\\item True.',
                '  \\\\item False.',
                '  \\\\item False.',
                '\\\\end{answerlist}',
                '\\\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\\\extype{schoice}',
                '%% \\\\exsolution{0100}',
                '%% \\\\exname{Mean}',
                '%% \\\\exshuffle{Cities}'),
      "num" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                '@',
                '',
                '\\\\begin{question}',
                '%% Enter the question here, you can access R variables with \\\\Sexpr{},',
                '%% e.g., \\\\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Calculate the mean of the following numbers: \\\\\\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\\\end{question}',
                '',
                '\\\\begin{solution}',
                '%% Supply a solution here!',
                'The mean is $0.324$.',
                '\\\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\\\extype{num}',
                '%% \\\\exsolution{0.324}',
                '%% \\\\exname{Mean}',
                '%% \\\\extol{0.01}'),
      "mchoice" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(33, 3, 33, 333)',
                'y <- c(3, 3, 1/6, 1/33.3)',
                'solutions <- x * y',
                '@',
                '',
                '\\\\begin{question}',
                '%% Enter the question here, you can access R variables with \\\\Sexpr{},',
                '%% e.g., \\\\Sexpr{solutions[1]} will return the solution of the first statement.',
                'Which of the following statements is correct?',
                '\\\\begin{answerlist}',
                '  \\\\item $33 \\\\cdot 3 = 109$',
                '  \\\\item $3 \\\\cdot 3 = 9$',
                '  \\\\item $33 / 6 = 5.5$',
                '  \\\\item $333 / 33.3 = 9$',
                '\\\\end{answerlist}',
                '\\\\end{question}',
                '',
                '\\\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\\\begin{answerlist}',
                '  \\\\item False. Correct answer is $33 \\\\cdot 3 = 99$.',
                '  \\\\item True.',
                '  \\\\item True.',
                '  \\\\item False. Correct answer is $333 / 33.3 = 10$.',
                '\\\\end{answerlist}',
                '\\\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\\\extype{mchoice}',
                '%% \\\\exsolution{0110}',
                '%% \\\\exname{Simple math}',
                '%% \\\\exshuffle{TRUE}'),
      "string" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'cities <- c("Munich", "Innsbruck", "Zurich", "Amsterdam")',
                'countries <- c("Germany", "Austria", "Switzerland", "Netherlands")',
                'question <- sample(cities, size = 1)',
                '@',
                '',
                '\\\\begin{question}',
                '%% Enter the question here, you can access R variables with \\\\Sexpr{},',
                '%% e.g., \\\\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\\\end{question}',
                '',
                '\\\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\\\extype{string}',
                '%% \\\\exsolution{Germany}',
                '%% \\\\exname{Cities 2}'),
      "cloze" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                'Sd <- sd(x)',
                'Var <- var(x)',
                '@',
                '',
                '\\\\begin{question}',
                '%% Enter the question here, you can access R variables with \\\\Sexpr{},',
                '%% e.g., \\\\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Given the following numbers: \\\\\\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\\\begin{answerlist}',
                '  \\\\item What is the mean?',
                '  \\\\item What is the standard deviation?',
                '  \\\\item What is the variance?',
                '\\\\end{answerlist}',
                '\\\\end{question}',
                '',
                '\\\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\\\begin{answerlist}',
                '  \\\\item The mean is $0.324$.',
                '  \\\\item The standard deviation is $0.767515$.',
                '  \\\\item The variance is $0.58908$.',
                '\\\\end{answerlist}',
                '\\\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\\\extype{cloze}',
                '%% \\\\exsolution{0.324|0.767515|0.58908}',
                '%% \\\\exclozetype{num|num|num}',
                '%% \\\\exname{Statistics}',
                '%% \\\\extol{0.01}')
    )
  } else {
    excode <- "Markdown templates not available yet!"
  }
  
  excode
}


split_path <- function(path, mustWork = FALSE, rev = FALSE) {
  output <- c(strsplit(dirname(normalizePath(path,mustWork = mustWork)), "/|\\\\")[[1]], basename(path))
  ifelse(rev, return(rev(output)), return(output))
}

