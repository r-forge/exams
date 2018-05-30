tabpanel.create = fluidPage(theme = "custom.css",
  sidebarLayout(
    sidebarPanel(width = 3,
      selectInput("exmarkup", label = "Load a template. Markup?", choices = c("LaTeX", "Markdown"),
        selected = "LaTeX"),
      selectInput("extype", label = ("Type?"),
        choices = c("num", "schoice", "mchoice", "string", "cloze"),
        selected = "num"),
      actionButton("load_editor_template", label = "Load template"),
      hr(),
      selectInput("exams_exercises", label = "Load exams package exercises.",
        choices = list.files(file.path(find.package("exams"), "exercises")), selected = "boxplots.Rnw"),
      actionButton("load_editor_exercise", label = "Load exercise"),
      hr(),
      conditionalPanel('input.selected_exercise != ""', uiOutput("show_selected_exercise")),
      uiOutput("select_imported_exercise"),
      selectInput("exencoding", label = "Encoding?", choices = c("ASCII", "UTF-8", "Latin-1", "Latin-2", "Latin-3",
        "Latin-4", "Latin-5", "Latin-6", "Latin-7", "Latin-8", "Latin-9", "Latin-10"),
        selected = "UTF-8")
    ),
    mainPanel(width = 9,
      tabBox(id = "create.tab", side = "left", width = 9,
        tabPanel("Create Exercises", value = "create",
          uiOutput("editor", inline = TRUE, container = div),
          uiOutput("playbutton")
        ),
        tabPanel("Preview", value = "preview",
          uiOutput("player", inline = TRUE, container = div),
          # uiOutput("editor", inline = TRUE, container = div),
          uiOutput("exnameshow"),
          actionButton("save_ex", label = "Save exercise")
        )
      )
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
      # )
    )
  )
)

