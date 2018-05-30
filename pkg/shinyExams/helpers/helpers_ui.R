makeSidebar = function(..., bar.height = 500) {
  args = list(...)
  div(class = "sidebarbox",
    box(width = NULL, height = bar.height, args)
  )
}

makeReportConfigUI = function(title, id, passage = "", ...) {
  more.inps = list(...)
  if (length(more.inps) == 0L)
    more.inps = NULL
  section.title.inp = textInput(paste("sec.title", id, sep = "."),
    label = "Section title", value = title)
  include.inp = checkboxInput(paste("include", id, sep = "."),
    "Add to report", TRUE)
  hidden.inp = checkboxInput(paste("hidden", id, sep = "."),
    "Hide source code", FALSE)
  info.text = textInput(paste("passage", id, sep = "."), "Additional text:",
    value = passage)
  box(title = title, solidHeader = TRUE, width = 12, status = "warning", collapsible = TRUE, collapsed = TRUE,
    section.title.inp,
    include.inp,
    hidden.inp,
    info.text,
    more.inps
  )
}

chooserInput <- function(inputId, leftChoices, rightChoices, size = 5, multiple = FALSE)
{
  leftChoices <- lapply(leftChoices, tags$option)
  rightChoices <- lapply(rightChoices, tags$option)
  questionNr <- lapply(if(length(rightChoices)) 1:length(rightChoices) else rightChoices, tags$li)
  
  if(multiple)
    multiple <- "multiple"
  else
    multiple <- NULL
  
  tagList(
    singleton(tags$head(
      tags$script(src="chooser-binding.js"),
      tags$style(type="text/css",
        HTML(".chooser-container { display: inline-block; }")
      )
    )),
    div(id=inputId, class="chooser",
      div(class="chooser-container chooser-left-container",
        HTML("<b>Available</b><br>"),
        tags$select(class="left", size=size, multiple=multiple, leftChoices)
      ),
      div(class="chooser-container chooser-center-container",
        icon("arrow-circle-o-right", "right-arrow fa-2x"),
        tags$br(),
        icon("arrow-circle-o-left", "left-arrow fa-2x")
      ),
      div(class="chooser-container chooser-right-container",
        HTML("<b>Selected</b><br>"),
        tags$select(class="right", size=size, multiple=multiple, rightChoices)
      ),
      div(class="chooser-container chooser-question-container",
        HTML("<b>Question Nr.</b><br>"),
        tags$ul(class="question", size=size, multiple=multiple, questionNr)
      )
    )
  )
}
