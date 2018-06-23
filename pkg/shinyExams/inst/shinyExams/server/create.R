##### create #####

available_exercises = reactive({
  e1 = input$save_ex
  e2 = input$ex_upload
  exfiles = list.files(directories$exercises)
  if (!is.null(input$selected_exercise)) {
    if (input$selected_exercise != "") {
      if (input$selected_exercise %in% exfiles) {
        i = which(exfiles == input$selected_exercise)
        exfiles = c(exfiles[i], exfiles[-i])
      }
    }
  }
  return(exfiles)
})

# loaded_exercise = reactiveValues(ex = NULL)


# observeEvent(input$load_editor_exercise, {
#   file.copy(file.path(directories$pkg_ex, input$exams_exercises), directories$tmp)
# })

output$select_imported_exercise = renderUI({
  selectInput('selected_exercise', 'Select exercise to be modified.', 
    choices = available_exercises(), selected = exname())
})

exname = reactive(input$exname)

output$show_selected_exercise = renderUI({
  if (!is.null(input$selected_exercise)) {
    if (input$selected_exercise != "") {
      # excode = readLines(file.path("exercises", input$selected_exercise))
      excode = readLines(file.path(directories$pkg_ex, input$selected_exercise))
      output$exnameshow = renderUI({
        textInput("exname", label = "Exercise name.", value = input$selected_exercise)
      })
      output$editor = renderUI({
        aceEditor("excode", if (input$exmarkup == "LaTeX") "tex" else "markdown",
          value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
      })
    }
    return(NULL)
  } else return(NULL)
})

output$editor = renderUI({
  aceEditor("excode", if (input$exmarkup == "LaTeX") "tex" else "markdown",
    value = "Create/edit exercises here!")
})

observeEvent(input$show_preview, {
  excode = input$excode
  shinyjs::hide("show_preview")
  shinyjs::hide("editor")
  shinyjs::show("hide_preview")
  shinyjs::show("player")
})

observeEvent(input$hide_preview, {
  shinyjs::show("show_preview")
  shinyjs::show("editor")
  shinyjs::hide("hide_preview")
  shinyjs::hide("player")
})

output$exnameshow = renderUI({
  textInput("exname", label = "Exercise name.", value = input$exname)
})

observeEvent(input$load_editor_template, {
  exname = paste("template-", input$extype, ".", if (input$exmarkup == "LaTeX") "Rnw" else "Rmd", sep = "")
  excode = get_template_code(input$extype, input$exmarkup)
  writeLines(excode, file.path(directories$tmp, exname))
  output$exnameshow = renderUI({
    textInput("exname", label = "Exercise name.", value = exname)
  })
  output$editor = renderUI({
    aceEditor("excode", mode = if (input$exmarkup == "LaTeX") "tex" else "markdown",
      value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
  })
  updateTabsetPanel(session, "create.tab", selected = "create")
})

# observeEvent(input$load_editor_template, {
#   loaded_exercise$ex = input$exams_exercises
# })

observeEvent(input$load_editor_exercise, {
  exname = input$exams_exercises
  expath = file.path(directories$pkg_ex,  exname)
  excode = readLines(expath)
  file.copy(expath, directories$tmp)
  output$exnameshow = renderUI({
    textInput("exname", label = "Exercise name.", value = exname)
  })
  markup = tolower(file_ext(exname))
  output$editor = renderUI({
    aceEditor("excode", mode = if (markup == "rnw") "tex" else "markdown",
      value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
  })
  updateTabsetPanel(session, "create.tab", selected = "create")
})

observeEvent(input$save_ex, {
  if (input$exname != "") {
    writeLines(input$excode, file.path(directories$exercises, input$exname))
  }
  exfiles = list.files(directories$exercises, recursive = TRUE)
  session$sendCustomMessage(type = 'exHandler', exfiles)
})


exercise_code = reactive({
  excode = input$excode
})

output$player = renderUI({
  if (!is.null(input$show_preview)) {
    if (input$show_preview > 0) {
      unlink(dir(directories$tmp, full.names = TRUE, recursive = TRUE))
      excode = exercise_code()
      if (excode[1] != "Create/edit exercises here!") {
        exname = if (is.null(input$exname)) paste("shinyEx", input$exmarkup, sep = ".") else input$exname
        exname = gsub("/", "_", exname, fixed = TRUE)
        writeLines(excode, file.path(directories$tmp, exname))
        ex = try(exams2html(exname, n = 1, name = "preview", dir = directories$tmp, edir = directories$tmp,
          base64 = TRUE, encoding = input$exencoding), silent = TRUE)
        if (!inherits(ex, "try-error")) {
          hf = "preview1.html"
          html = readLines(file.path(directories$tmp, hf))
          n = c(which(html == "<body>"), length(html))
          html = c(
            html[1L:n[1L]],                  ## header
            '<div style="border: 1px solid black;border-radius:5px;padding:8px;">', ## border
            html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
            '</div>', '</br>',               ## border
            html[(n[2L] - 1L):(n[2L])]       ## footer
          )
          writeLines(html, file.path(directories$tmp, hf))
          return(includeHTML(file.path(directories$tmp, hf)))
        } else {
          return(HTML(paste('<div>', ex, '</div>')))
        }
      } else return(NULL)
    } else return(NULL)
  } else return(NULL)
})