tabpanel.def = fluidPage(theme = "custom.css",
  column(6,
    br(),
    textInput("exam_name", "Name of the exam.", "Exam1"),
    p("Select exercises for your exam."),
    shinyTree("tree", checkbox = TRUE, dragAndDrop = TRUE, search = TRUE),
    br(),
    actionButton("save_exam", label = "Save")
  ),
  column(6,
    verbatimTextOutput("selTxt")
  )
)

