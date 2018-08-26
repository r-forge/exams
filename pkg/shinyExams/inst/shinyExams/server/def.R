##### create #####

examStructure = reactive({
  exfiles = available_exercises()
  names = character(0L)
  for (i in 1:length(exfiles)) {
    names = c(names, (paste("Exercise", i, sep = " ")))
  }
  exam = namedList(names)

  for (i in 1:length(exfiles)) {
    exam[[i]] = namedList(exfiles[[i]])
  }
  return(exam)
})



output$tree <- renderTree({
  list(
    Exam = examStructure()
  )
})

output$selTxt <- renderPrint({
  tree <- input$tree
  if (is.null(tree)) {
    "None"
  } else {
    get_selected(tree)
  }
})

dir.create(recursive = TRUE)
