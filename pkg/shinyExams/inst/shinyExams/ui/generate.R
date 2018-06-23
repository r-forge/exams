tabpanel.generate = fluidPage(theme = "custom.css",
  # sidebarLayout(
  #   sidebarPanel(width = 3,
  #     uiOutput("generate.ui")
  #   ),
  #   mainPanel(width = 9,
  #     htmlOutput("generate.text"),
  #     box(width = 12, DT::dataTableOutput("import.preview")),
  #     uiOutput("tabpanel.browse.openml")
  #   )
  # )
  p("Compile exams, please select input parameters."),
  textInput("name", "Choose an exam name.", value = "Exam1"),
  selectInput("format", "Format.", c("PDF", "HTML", "QTI12")),
  numericInput("n", "Number of copies.", value = 1),
  actionButton("compile", label = "Compile."),
  downloadButton('downloadData', 'Download all files as .zip'),
  br(),
  br(),
  p("Files for download."),
  verbatimTextOutput("exams")
)

