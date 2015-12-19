exams_shiny <- function(dir = NULL)
{
  stopifnot(require("shiny"))
  stopifnot(require("shinyAce"))
  stopifnot(require("tools"))

  owd <- getwd()
  if(is.null(dir)) {
    dir.create(dir <- tempfile())
    on.exit(unlink(dir))
  }
  dir <- path.expand(dir)
  if(!file.exists(file.path(dir, "www")))
    dir.create(file.path(dir, "www"))
  if(!file.exists(file.path(dir, "exercises"))) {
    dir.create(file.path(dir, "exercises"))
  } else {
    ex <- dir(file.path(dir, "exercises"), full.names = TRUE)
    file.remove(ex)
  }
  if(!file.exists(file.path(dir, "tmp"))) {
    dir.create(file.path(dir, "tmp"))
  } else {
    tf <- dir(file.path(dir, "tmp"), full.names = TRUE)
    unlink(tf)
  }
  if(!file.exists(file.path(dir, "exams"))) {
    dir.create(file.path(dir, "exams"))
  } else {
    tf <- dir(file.path(dir, "exams"), full.names = TRUE)
    unlink(tf)
  }

  writeLines(chooser.js, file.path(dir, "www", "chooser-binding.js"))
  registerInputHandler("shinyjsexamples.chooser", function(data, ...) {
    if(is.null(data))
      NULL
    else
      list(left=as.character(data$left), right=as.character(data$right))
  }, force = TRUE)

  dump("exams_shiny_ui", file = file.path(dir, "ui.R"), envir = .GlobalEnv)
  dump("exams_shiny_server", file = file.path(dir, "server.R"), envir = .GlobalEnv)

  runApp(dir)
}


exams_shiny_ui <- function(...) {
  pageWithSidebar(
   
     ## Application title.
     headerPanel("R exams manager"),
     
     NULL,

     ## Show a plot of the generated distribution.
     mainPanel(
       tags$head(tags$script(
	 list(
            ## Getting data from server.
	    HTML('Shiny.addCustomMessageHandler("exHandler", function(data) {
              var dest = $("div.chooser-left-container").find("select");
              $.each(data,function(key,val) {
                 var x = val.split("/")
	         x = x[x.length-1]
		 dest.append("<option val=\'"+val+"\'>"+x+"</option>");
              });
            });'))
         )
       ),
       tabsetPanel(
         tabPanel("Create/Edit Exercises",
           br(),
           fileInput("ex_upload", "Load Exercise", multiple = TRUE,
             accept = c("text/Rnw", "text/Rmd", "text/rnw", "text/rmd")),
           fluidRow(
             column(10,
               uiOutput("editor"),
               actionButton("play_exercise", label = "Play")
             ),
             column(2,
               selectInput("exmarkup", label = ("Markup?"), choices = c("LaTeX", "Markdown"),
                 selected = "LaTeX"),
               selectInput("extype", label = ("Type?"),
                 choices = c("num", "schoice", "mchoice", "string", "cloze"),
                 selected = "num"),
               selectInput("exsolution", label = ("Solution?"), choices = c("yes", "no"),
                 selected = "yes"),
               selectInput("exencoding", label = ("Encoding?"), choices = c("UTF-8", "ASCII"),
                 selected = "UTF-8"),
               actionButton("load_editor_template", label = "Load Template")
             )
           ),
           tags$hr(),
           uiOutput("exnameshow"),
           actionButton("save_ex", label = "Save Exercise"),
           tags$hr(),
           uiOutput("saved_exercises"),
           br(), br()
         ),
         tabPanel("Import/Export Exercises"),
         tabPanel("Define Exams",
           fluidRow(
             column(6,
               br(),
               p("Select exercises for your exam."),
               fileInput("file1", "Upload exercises in .Rnw format.", multiple = TRUE),
               p("Alternatively load template exercises."),
               actionButton("templates", label = "Load templates."),
               br(), br(),
               p("Note, the selected exercises will be used to compile exams."),
               chooserInput("mychooser", c(), c(), size = 10, multiple = TRUE)
             ),
             column(6,
               br(),
               uiOutput("preview"),
               conditionalPanel('input.preview2 != ""', uiOutput("html_exercise"))
             )
           )
         ),
         tabPanel("Generate Exams",
           br(),
           p("Compile exams, please select input parameters."),
           textInput("name", "Choose an exam name.", value = "Exam1"),
           selectInput("format", "Format.", c("PDF", "HTML", "QTI12")),
           numericInput("n", "Number of copies.", value = 1),
           actionButton("compile", label = "Compile."),
           downloadButton('downloadData', 'Download all files as .zip.'),
           br(),
           br(),
           p("Files for download."),
           verbatimTextOutput("exams")
         )
       )
     )
   )
}


exams_shiny_server <- function(input, output, session)
{
  observeEvent(input$templates, {
    tex <- dir(file.path(find.package("exams"), "exercises"), full.names = TRUE)
    ex <- dir("exercises")
    file.copy(tex, file.path("exercises", tex <- basename(tex)), overwrite = TRUE)
    tex <- tex[!(tex %in% ex)]
    if(length(tex))
      session$sendCustomMessage(type = 'exHandler', tex)
  })
  observe({
    if(!is.null(input$file1)) {
      ## FIXME: compressed files!
      ex <- dir("exercises")
      file.copy(input$file1$datapath, file.path("exercises",  tex <- input$file1$name), overwrite = TRUE)
      tex <- tex[!(tex %in% ex)]
      if(length(tex))
        session$sendCustomMessage(type = 'exHandler', tex)
    }
    input$file1
  })
  output$selection <- renderPrint({
    input$mychooser
  })
  selected_exercises <- reactive({
    ex <- if(is.null(input$mychooser)) {
      ""
    } else {
      c("", input$mychooser$right)
    }
  })
  output$preview <- renderUI({
    selectInput('preview2', 'Preview exercise.', selected_exercises())
  })
  output$editor <- renderUI({
    aceEditor("excode", mode = "r", value = "Create/edit exercises here!")
  })
  output$exnameshow <- renderUI({
    textInput("exname", label = "Exercise Name", value = input$exname)
  })
  observeEvent(input$load_editor_template, {
    exname <- switch(input$extype,
      "num" = "dist",
      "schoice" = "swisscapital",
      "mchoice" = "switzerland",
      "string" = "function",
      "cloze" = "dist2"
    )
    exname <- paste(exname, if(input$exmarkup == "LaTeX") "Rnw" else "Rmd", sep = ".")
    expath <- file.path(find.package("exams"), "exercises", exname)
    excode <- readLines(expath)
    excode <- gsub('\\', '\\\\', excode, fixed = TRUE)
    output$exnameshow <- renderUI({
      textInput("exname", label = "Exercise name.", value = exname)
    })
    output$editor <- renderUI({
      aceEditor("excode", mode = "r", value = paste(excode, collapse = '\n'))
    })
  })
  observeEvent(input$ex_upload, {
    if(!is.null(input$ex_upload$datapath)) {
      output$exnameshow <- renderUI({
        textInput("exname", label = "Exercise name.", value = input$ex_upload$name)
      })
    } else {
      output$exnameshow <- renderUI({
        textInput("exname", label = "Exercise name.", value = "NA")
      })
    }
    ex <- if(is.null(input$ex_upload$datapath)) {
      "No exercise found!"
    } else {
      readLines(input$ex_upload$datapath)
    }
    ex <- gsub('\\', '\\\\', ex, fixed = TRUE)
    output$editor <- renderUI({
      aceEditor("excode", mode = "r", value = paste(ex, collapse = '\n'))
    })
  })
  observeEvent(input$save_ex, {
    if(input$exname != "") {
      writeLines(input$excode, file.path("exercises", input$exname))
      output$saved_exercises <- renderTable({
        ex <- as.data.frame(matrix(dir("exercises"), ncol = 1))
        colnames(ex) <- "Saved Exercises"
        ex
      })
      session$sendCustomMessage(type = 'exHandler', input$exname)
    }
  })
  output$html_exercise <- renderUI({
    if(length(input$preview2)) {
      if(input$preview2 != "") {
        unlink(dir("tmp", full.names = TRUE))
        ##if(tolower(file_ext(input$preview2)) == "rmd")
        ##  stop("cannot diplay pandoc documents!")
        exams2html(input$preview2, n = 1, dir = "tmp", edir = "exercises",
          base64 = c("bmp", "gif", "jpeg", "jpg", "png", "csv", "raw", "rda", "zip"))
        html <- readLines("tmp/plain1.html")
        html <- gsub('<h2>Exam 1</h2>', '', html, fixed = TRUE)
        writeLines(html, "tmp/plain1.html")
        return(includeHTML("tmp/plain1.html"))
      }
    }
  })
  observeEvent(input$compile, {
    if(length(input$mychooser$right)) {
      unlink(dir("exams", full.names = TRUE))
      ex <- NULL
      if(input$format == "PDF") {
        ex <- exams2pdf(input$mychooser$right, n = input$n,
          dir = "exams", edir = "exercises", name = input$name)
      }
      if(input$format == "HTML") {
        ex <- exams2html(input$mychooser$right, n = input$n,
          dir = "exams", edir = "exercises", name = input$name)
      }
      if(input$format == "QTI12") {
        ex <- exams2qti12(input$mychooser$right, n = input$n,
          dir = "exams", edir = "exercises", name = input$name)
      }
      if(!is.null(ex))
        save(ex, file = file.path("exams", paste(input$name, "rda", sep = ".")))
    } else return(NULL)
  })
  dlinks <- eventReactive(input$compile, {
    dir("exams", full.names = TRUE)
  })
  output$exams <- renderText({
    basename(dlinks())
  })
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$name, "zip", sep = ".")
    },
    content = function(file) {
      owd <- getwd()
      setwd(file.path(owd, "exams"))
      zip(zipfile = paste(input$name, "zip", sep = "."), files = list.files(file.path(owd, "exams")))
      setwd(owd)
      file.copy(file.path("exams", paste(input$name, "zip", sep = ".")), file)
    }
  )
}


chooserInput <- function(inputId, leftChoices, rightChoices, size = 5, multiple = FALSE)
{
  leftChoices <- lapply(leftChoices, tags$option)
  rightChoices <- lapply(rightChoices, tags$option)
  
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
      )
    )
  )
}


chooser.js <- '
(function() {

function updateChooser(chooser) {
    chooser = $(chooser);
    var left = chooser.find("select.left");
    var right = chooser.find("select.right");
    var leftArrow = chooser.find(".left-arrow");
    var rightArrow = chooser.find(".right-arrow");
    
    var canMoveTo = (left.val() || []).length > 0;
    var canMoveFrom = (right.val() || []).length > 0;
    
    leftArrow.toggleClass("muted", !canMoveFrom);
    rightArrow.toggleClass("muted", !canMoveTo);
}

function move(chooser, source, dest) {
    chooser = $(chooser);
    var selected = chooser.find(source).children("option:selected");
    var dest = chooser.find(dest);
    dest.children("option:selected").each(function(i, e) {e.selected = false;});
    dest.append(selected);
    updateChooser(chooser);
    chooser.trigger("change");
}

$(document).on("change", ".chooser select", function() {
    updateChooser($(this).parents(".chooser"));
});

$(document).on("click", ".chooser .right-arrow", function() {
    move($(this).parents(".chooser"), ".left", ".right");
});

$(document).on("click", ".chooser .left-arrow", function() {
    move($(this).parents(".chooser"), ".right", ".left");
});

$(document).on("dblclick", ".chooser select.left", function() {
    move($(this).parents(".chooser"), ".left", ".right");
});

$(document).on("dblclick", ".chooser select.right", function() {
    move($(this).parents(".chooser"), ".right", ".left");
});

var binding = new Shiny.InputBinding();

binding.find = function(scope) {
  return $(scope).find(".chooser");
};

binding.initialize = function(el) {
  updateChooser(el);
};

binding.getValue = function(el) {
  return {
    left: $.makeArray($(el).find("select.left option").map(function(i, e) { return e.value; })),
    right: $.makeArray($(el).find("select.right option").map(function(i, e) { return e.value; }))
  }
};

binding.setValue = function(el, value) {
  // TODO: implement
};

binding.subscribe = function(el, callback) {
  $(el).on("change.chooserBinding", function(e) {
    callback();
  });
};

binding.unsubscribe = function(el) {
  $(el).off(".chooserBinding");
};

binding.getType = function() {
  return "shinyjsexamples.chooser";
};

Shiny.inputBindings.register(binding, "shinyjsexamples.chooser");

})();
'
