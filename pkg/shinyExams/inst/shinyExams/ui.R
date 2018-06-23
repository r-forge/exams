require(shiny)
require(shinyAce)
require(shinyTree)
require(shinyFiles)
require(tools)
require(shinydashboard)
require(shinyjs)
require(shinyBS)
require(DT)
require(exams)
#require(plotly)
# require(shinythemes)

source("./helpers/helpers_ui.R", local = TRUE)$value
source("./helpers/helpers_templates.R", local = TRUE)$value

ui.files = list.files(path = "./ui", pattern = "*.R")
ui.files = paste0("ui/", ui.files)

for (i in seq_along(ui.files)) {
  source(ui.files[i], local = TRUE)
}

shinyUI(
  tagList(
    useShinyjs(),
    # loading.screens,
    div(id = "app-content",
      navbarPage(title = "shinyExams",
        theme = "custom.css", id = "top-nav",
        tabPanel(title = div(class = "navbarlink-container",
          tags$img(height = "17px", alt = "exams Logo",
            src = "logo.svg")
        ), value = "http://www.r-exams.org/"),
        tabPanel("Create/Edit Exercises", tabpanel.create,
          icon = icon("folder-open")),
        # tabPanel("Import/Export Exercises", tabpanel.import, icon = icon("flag")),
        tabPanel("Define Exams", tabpanel.def,
          icon = icon("cog")),
        tabPanel("Generate Exams", tabpanel.generate,
          icon = icon("wrench")),
        tabPanel(title = "hide_me"),
        
        
        footer = tagList(
          includeScript("scripts/top-nav-links.js"),
          includeScript("scripts/app.js"),
          tags$link(rel = "stylesheet", type = "text/css",
            href = "custom.css"),
          tags$link(rel = "stylesheet", type = "text/css",
            href = "https://fonts.googleapis.com/css?family=Roboto"),
          tags$link(rel = "stylesheet", type = "text/css",
            href = "AdminLTE.css"),
          tags$footer(title = "",
            tags$p(id = "copyright",
              tags$img(icon("copyright")),
              2018,
              tags$a(href = "http://www.r-exams.org/",
                target = "_blank", "R-exams.org")
            ),
            tags$p(id = "help_toggler",
              bsButton(inputId = "show_help", label = "show help",
                type = "toggle", icon = icon("question-circle"))
            )
          )
        ),
        windowTitle = "shinyExams",
        selected = "Create/Edit Exercises"
      )
    )
  )
)
