tabpanel.def = fluidPage(theme = "custom.css",
  column(6,
    br(),
    textInput("exam_name", "Name of the exam.", "Exam1"),
    p("Select exercises for your exam."),
    chooserInput("mychooser", c(), c(), size = 10, multiple = TRUE),
    br(),
    actionButton("save_exam", label = "Save")
  ),
  column(6,
    br(),
    p("Exam structure."),
    uiOutput("exercises4exam")
  )
)

