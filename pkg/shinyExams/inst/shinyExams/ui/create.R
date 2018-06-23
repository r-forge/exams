tabpanel.create = fluidPage(theme = "custom.css",
  sidebarLayout(position = "left",
    sidebarPanel(width = 3,
      fileInput("ex_upload", p("Import exercises in", strong('.Rnw'), ",", strong(".Rmd"),
        "format, also provided as", strong(".zip"), "or", strong(".tar.gz"), "files!",
        "Import images in", strong(".jpg"), "and", strong("png"), "format!",
        "Import an existing project!"), multiple = TRUE,
        accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd", "zip", "tar.gz",
          "jpg", "JPG", "png", "PNG")),
      hr(),
      selectInput("exmarkup", label = "Load a template. Markup?", choices = c("LaTeX", "Markdown"),
        selected = "LaTeX"),
      selectInput("extype", label = ("Type?"),
        choices = c("num", "schoice", "mchoice", "string", "cloze"),
        selected = "num"),
      actionButton("load_editor_template", label = "Load template", width = "60%"),
      hr(),
      selectInput("exams_exercises", label = "Load exams package exercises.",
        choices = list.files(file.path(find.package("exams"), "exercises")), selected = "boxplots.Rnw"),
      actionButton("load_editor_exercise", label = "Load exercise", width = "60%"),
      hr(),
      conditionalPanel('input.selected_exercise != ""', uiOutput("show_selected_exercise")),
      uiOutput("select_imported_exercise"),
      selectInput("exencoding", label = "Encoding?", choices = c("ASCII", "UTF-8", "Latin-1", "Latin-2", "Latin-3",
        "Latin-4", "Latin-5", "Latin-6", "Latin-7", "Latin-8", "Latin-9", "Latin-10"),
        selected = "UTF-8")
    ),
    mainPanel(width = 9,
      box(id = "create.box", side = "left", width = 8,
        column(width = 3,
          actionButton("show_preview", label = "Show preview"),
          hidden(actionButton("hide_preview", label = "Hide preview"))
        ),
        column(width = 3,
          actionButton("save_ex", label = "Save exercise")
        ),
        column(width = 6,
          uiOutput("exnameshow")
        ),
        column(12,
        br(),
        uiOutput("editor", inline = TRUE, container = div),
        br(),
        hidden(uiOutput("player", inline = TRUE, container = div))
        )
      ),
      box(width = 4,
        p("List of loaded exercises:"),
        DT::dataTableOutput("show_exercises"),
        br(),
        downloadButton('download_exercises', 'Download as .zip'),
        tags$hr(),
        downloadButton('download_project', 'Download project')
      )
      # )
      # fluidRow(
      #   box(width = 9,
      #     uiOutput("editor", inline = TRUE, container = div),
      #     uiOutput("player", inline = TRUE, container = div),
      #     uiOutput("playbutton"),
      #     tags$hr(),
      #    uiOutput("exnameshow"),
      #     actionButton("save_ex", label = "Save exercise"),
      #     br(), 
      #     br()
      #   )
    )
  )
)

