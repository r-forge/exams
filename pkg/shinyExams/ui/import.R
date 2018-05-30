tabpanel.import = fluidPage(theme = "custom.css",
  # sidebarLayout(
  #   sidebarPanel(width = 3,
  #     uiOutput("import.ui")
  #   ),
  #   mainPanel(width = 9,
  #     br(),
  p("Import exercises in", strong('.Rnw'), ",", strong(".Rmd"),
    "format, also provided as", strong(".zip"), "or", strong(".tar.gz"), "files!",
    "Import images in", strong(".jpg"), "and", strong("png"), "format!",
    "Import an existing project!"),
  fileInput("ex_upload", NULL, multiple = TRUE,
    accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd", "zip", "tar.gz",
      "jpg", "JPG", "png", "PNG")),
  tags$hr(),
  p("List of loaded exercises:"),
  verbatimTextOutput("show_exercises"),
  br(),
  downloadButton('download_exercises', 'Download as .zip'),
  tags$hr(),
  downloadButton('download_project', 'Download project')
  #   )
  # )
)

