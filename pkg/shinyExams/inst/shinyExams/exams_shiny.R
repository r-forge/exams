exams_shiny <- function(dir = NULL)
{
  stopifnot(require("shiny"))
  stopifnot(require("shinyAce"))
  stopifnot(require("shinyTree"))
  stopifnot(require("shinyFiles"))
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
    ex <- dir(file.path(dir, "exercises"), full.names = TRUE, recursive = TRUE)
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
      list(questions=as.character(data$questions), left=as.character(data$left), right=as.character(data$right))
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
       tags$style(HTML("
         .gray-node {
           color: #E59400;
         }
       ")),
       tags$head(tags$script(
	 list(
            ## Getting data from server.
	    HTML('Shiny.addCustomMessageHandler("exHandler", function(data) {
               var dest = $("div.chooser-left-container").find("select.left");
               dest.empty();
	       if ( typeof(data) == "string" ) {
		  dest.append("<option>"+data+"</option>");
               } else {
                  $.each(data, function(key, val) {
		     dest.append("<option>"+val+"</option>");
                  });
               }
            });'))
         )
       ),
       tabsetPanel(
         tabPanel("Create/Edit Exercises",
           br(),
           fluidRow(
             column(4,
               uiOutput("select_imported_exercise"),
               conditionalPanel('input.selected_exercise != ""', uiOutput("show_selected_exercise"))
             ),
             column(4,
               selectInput("exencoding", label = "Encoding?", choices = c("ASCII", "UTF-8", "Latin-1", "Latin-2", "Latin-3",
                 "Latin-4", "Latin-5", "Latin-6", "Latin-7", "Latin-8", "Latin-9", "Latin-10"),
                 selected = "UTF-8")
             )
           ),
           fluidRow(
             column(9,
               uiOutput("editor", inline = TRUE, container = div),
               uiOutput("player", inline = TRUE, container = div),
               uiOutput("playbutton")
             ),
             column(3,
               selectInput("exmarkup", label = "Load a template. Markup?", choices = c("LaTeX", "Markdown"),
                 selected = "LaTeX"),
               selectInput("extype", label = ("Type?"),
                 choices = c("num", "schoice", "mchoice", "string", "cloze"),
                 selected = "num"),
               actionButton("load_editor_template", label = "Load template"),
               hr(),
               selectInput("exams_exercises", label = "Load exams package exercises.",
                 choices = list.files(file.path(find.package("exams"), "exercises")),
                 selected = "boxplots.Rnw"),
               actionButton("load_editor_exercise", label = "Load exercise")
             )
           ),
           tags$hr(),
           uiOutput("exnameshow"),
           actionButton("save_ex", label = "Save exercise"),
           br(), br()
         ),
         tabPanel("Import/Export Exercises",
           br(),
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
           downloadButton('download_project', 'Download project'),
           br(), br()
         ),
         tabPanel("Define Exams",
           fluidRow(
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
         ),
         tabPanel("Generate Exams",
           br(),
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
       )
     )
   )
}


exams_shiny_server <- function(input, output, session)
{
  available_exercises <- reactive({
    e1 <- input$save_ex
    e2 <- input$ex_upload
    exfiles <- list.files("exercises", recursive = TRUE)
    if(!is.null(input$selected_exercise)) {
      if(input$selected_exercise != "") {
        if(input$selected_exercise %in% exfiles) {
          i <- which(exfiles == input$selected_exercise)
          exfiles <- c(exfiles[i], exfiles[-i])
        }
      }
    }
    return(exfiles)
  })

  output$select_imported_exercise <- renderUI({
    selectInput('selected_exercise', 'Select exercise to be modified.',
      available_exercises())
  })

  output$show_selected_exercise <- renderUI({
    if(!is.null(input$selected_exercise)) {
      if(input$selected_exercise != "") {
        excode <- readLines(file.path("exercises", input$selected_exercise))
        output$exnameshow <- renderUI({
          textInput("exname", label = "Exercise name.", value = input$selected_exercise)
        })
        output$editor <- renderUI({
          aceEditor("excode", if(input$exmarkup == "LaTeX") "tex" else "markdown",
            value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
        })
      }
      return(NULL)
    } else return(NULL)
  })

  output$editor <- renderUI({
    aceEditor("excode", if(input$exmarkup == "LaTeX") "tex" else "markdown",
      value = "Create/edit exercises here!")
  })

  output$playbutton <- renderUI({
    actionButton("play_exercise", label = "Show preview")
  })

  output$exnameshow <- renderUI({
    textInput("exname", label = "Exercise name.", value = input$exname)
  })

  observeEvent(input$load_editor_template, {
    exname <- paste("template-", input$extype, ".", if(input$exmarkup == "LaTeX") "Rnw" else "Rmd", sep = "")
    excode <- get_template_code(input$extype, input$exmarkup)
    output$exnameshow <- renderUI({
      textInput("exname", label = "Exercise name.", value = exname)
    })
    output$editor <- renderUI({
      aceEditor("excode", mode = if(input$exmarkup == "LaTeX") "tex" else "markdown",
        value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
    })
  })

  observeEvent(input$load_editor_exercise, {
    exname <- input$exams_exercises
    expath <- file.path(find.package("exams"), "exercises", exname)
    excode <- readLines(expath)
    output$exnameshow <- renderUI({
      textInput("exname", label = "Exercise name.", value = exname)
    })
    markup <- tolower(file_ext(exname))
    output$editor <- renderUI({
      aceEditor("excode", mode = if(markup == "rnw") "tex" else "markdown",
        value = paste(gsub('\\', '\\\\', excode, fixed = TRUE), collapse = '\n'))
    })
  })

  observeEvent(input$save_ex, {
    if(input$exname != "") {
      writeLines(input$excode, file.path("exercises", input$exname))
    }
    exfiles <- list.files("exercises", recursive = TRUE)
    session$sendCustomMessage(type = 'exHandler', exfiles)
  })

  observeEvent(input$play_exercise, {
    excode <- input$excode
    output$playbutton <- renderUI({
      actionButton("show_editor", label = "Hide preview")
    })
  })

  observeEvent(input$show_editor, {
    output$playbutton <- renderUI({
      actionButton("play_exercise", label = "Show preview")
    })
  })

  exercise_code <- reactive({
    excode <- input$excode
  })

  output$player <- renderUI({
    if(!is.null(input$play_exercise)) {
      if(input$play_exercise > 0) {
        unlink(dir("tmp", full.names = TRUE, recursive = TRUE))
        excode <- exercise_code()
        if(excode[1] != "Create/edit exercises here!") {
          exname <- if(is.null(input$exname)) paste("shinyEx", input$exmarkup, sep = ".") else input$exname
          exname <- gsub("/", "_", exname, fixed = TRUE)
          writeLines(excode, file.path("tmp", exname))
          ex <- try(exams2html(exname, n = 1, name = "preview", dir = "tmp", edir = "tmp",
            base64 = TRUE, encoding = input$exencoding), silent = TRUE)
          if(!inherits(ex, "try-error")) {
            hf <- "preview1.html"	    
            html <- readLines(file.path("tmp", hf))
	    n <- c(which(html == "<body>"), length(html))
	    html <- c(
	      html[1L:n[1L]],                  ## header
	      '<div style="border: 1px solid black;border-radius:5px;padding:8px;">', ## border
	      html[(n[1L] + 5L):(n[2L] - 6L)], ## exercise body (omitting <h2> and <ol>)
	      '</div>', '</br>',               ## border
	      html[(n[2L] - 1L):(n[2L])]       ## footer
	    )
            writeLines(html, file.path("tmp", hf))
            return(includeHTML(file.path("tmp", hf)))
          } else {
            return(HTML(paste('<div>', ex, '</div>')))
          }
        } else return(NULL)
      } else return(NULL)
    } else return(NULL)
  })

  observeEvent(input$ex_upload, {
    if(!is.null(input$ex_upload$datapath)) {
      for(i in seq_along(input$ex_upload$name)) {
        fext <- tolower(file_ext(input$ex_upload$name[i]))
        if(fext %in% c("rnw", "rmd")) {
          file.copy(input$ex_upload$datapath[i], file.path("exercises", input$ex_upload$name[i]))
        } else {
          tdir <- tempfile()
          dir.create(tdir)
          owd <- getwd()
          setwd(tdir)
          file.copy(input$ex_upload$datapath[i], input$ex_upload$name[i])
          if(fext == "zip") {
            unzip(input$ex_upload$name[i], exdir = ".")
          } else {
            untar(input$ex_upload$name[i], exdir = ".")
          }
          file.remove(input$ex_upload$name[i])
          cf <- dir(tdir)
          file.copy(cf, file.path(owd, "exercises"), recursive = TRUE)
          setwd(owd)
          unlink(tdir)
        }
      }
      exfiles <- list.files("exercises", recursive = TRUE)
      session$sendCustomMessage(type = 'exHandler', exfiles)
    }
  })

  foo <- function(x) {
    for(i in seq_along(x))
      cat(x[i], "\n")
    invisible(NULL)
  }

  output$show_exercises <- renderPrint({
    foo(available_exercises())
  })

  output$download_exercises <- downloadHandler(
    filename = function() {
      paste("exercises", "zip", sep = ".")
    },
    content = function(file) {
      owd <- getwd()
      dir.create(tdir <- tempfile())
      file.copy(file.path("exercises", list.files("exercises")), tdir, recursive = TRUE)
      setwd(tdir)
      zip(zipfile = paste("exercises", "zip", sep = "."), files = list.files(tdir))
      setwd(owd)
      file.copy(file.path(tdir, paste("exercises", "zip", sep = ".")), file)
      unlink(tdir)
    }
  )

  output$download_project <- downloadHandler(
    filename = function() {
      paste("exams_project", "zip", sep = ".")
    },
    content = function(file) {
      owd <- getwd()
      dir.create(tdir <- tempfile())
      file.copy(file.path(".", list.files(".")), tdir, recursive = TRUE)
      setwd(tdir)
      zip(zipfile = paste("exams_project", "zip", sep = "."), files = c("exercises", "exams"))
      setwd(owd)
      file.copy(file.path(tdir, paste("exams_project", "zip", sep = ".")), file)
      unlink(tdir)
    }
  )

  final_exam <- reactive({
    input$save_exam
    if(length(list.files("exam"))) {
      exname <- paste(input$exam_name, "rda", sep = ".")
      load(exname)
      return(eval(parse(text = exname)))
    } else return(NULL)
  })
  output$exercises4exam <- renderUI({
    if(!is.null(ex <- final_exam())) {
      ex
    } else {
      input$exam_name
    }
  })
  observeEvent(input$save_exam, {
    
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


get_template_code <- function(type, markup)
{
  if(markup == "LaTeX") {
    excode <- switch(type,
      "schoice" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'cities <- c("Munich", "Innsbruck", "Zurich", "Amsterdam")',
                'countries <- c("Germany", "Austria", "Switzerland", "Netherlands")',
                'question <- sample(cities, size = 1)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\begin{answerlist}',
                '  \\item Austria',
                '  \\item Germany',
                '  \\item Switzerland',
                '  \\item Netherlands',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\begin{answerlist}',
                '  \\item False.',
                '  \\item True.',
                '  \\item False.',
                '  \\item False.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{schoice}',
                '%% \\exsolution{0100}',
                '%% \\exname{Mean}',
                '%% \\exshuffle{Cities}'),
      "num" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Calculate the mean of the following numbers: \\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'The mean is $0.324$.',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{num}',
                '%% \\exsolution{0.324}',
                '%% \\exname{Mean}',
                '%% \\extol{0.01}'),
      "mchoice" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(33, 3, 33, 333)',
                'y <- c(3, 3, 1/6, 1/33.3)',
                'solutions <- x * y',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{solutions[1]} will return the solution of the first statement.',
                'Which of the following statements is correct?',
                '\\begin{answerlist}',
                '  \\item $33 \\cdot 3 = 109$',
                '  \\item $3 \\cdot 3 = 9$',
                '  \\item $33 / 6 = 5.5$',
                '  \\item $333 / 33.3 = 9$',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\begin{answerlist}',
                '  \\item False. Correct answer is $33 \\cdot 3 = 99$.',
                '  \\item True.',
                '  \\item True.',
                '  \\item False. Correct answer is $333 / 33.3 = 10$.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{mchoice}',
                '%% \\exsolution{0110}',
                '%% \\exname{Simple math}',
                '%% \\exshuffle{TRUE}'),
      "string" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'cities <- c("Munich", "Innsbruck", "Zurich", "Amsterdam")',
                'countries <- c("Germany", "Austria", "Switzerland", "Netherlands")',
                'question <- sample(cities, size = 1)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{question} will return the name of the sampled city in the code above.',
                'In which country is Munich?',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!',
                'Munich is in Germany.',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{string}',
                '%% \\exsolution{Germany}',
                '%% \\exname{Cities 2}'),
      "cloze" = c('<<echo=FALSE, results=hide>>=',
                '## DATA GENERATION EXAMPLE',
                'x <- c(-0.17, 0.63, 0.96, 0.97, -0.77)',
                'Mean <- mean(x)',
                'Sd <- sd(x)',
                'Var <- var(x)',
                '@',
                '',
                '\\begin{question}',
                '%% Enter the question here, you can access R variables with \\Sexpr{},',
                '%% e.g., \\Sexpr{Mean} will return the mean of variable x in the R code above.',
                'Given the following numbers: \\\\',
                '$',
                '-0.17, 0.63, 0.96, 0.97, -0.77.',
                '$',
                '\\begin{answerlist}',
                '  \\item What is the mean?',
                '  \\item What is the standard deviation?',
                '  \\item What is the variance?',
                '\\end{answerlist}',
                '\\end{question}',
                '',
                '\\begin{solution}',
                '%% Supply a solution here!', '',
                '\\begin{answerlist}',
                '  \\item The mean is $0.324$.',
                '  \\item The standard deviation is $0.767515$.',
                '  \\item The variance is $0.58908$.',
                '\\end{answerlist}',
                '\\end{solution}',
                '',
                '%% META-INFORMATION',
                '%% \\extype{cloze}',
                '%% \\exsolution{0.324|0.767515|0.58908}',
                '%% \\exclozetype{num|num|num}',
                '%% \\exname{Statistics}',
                '%% \\extol{0.01}')
    )
  } else {
    excode <- "Markdown templates not available yet!"
  }
  
  excode
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


chooser.js <- '
(function() {

function updateChooser(chooser) {
    chooser = $(chooser);
    var left = chooser.find("select.left");
    var right = chooser.find("select.right");
    var leftArrow = chooser.find(".left-arrow");
    var rightArrow = chooser.find(".right-arrow");

    var qnr = chooser.find("ul.question");
    qnr.empty();
    $.each( $("select.right").find("option"), function(key, val) {
        qnr.append("<li><id>"+(key+1)+"</id>"
                  +"<minus>-</minus>"
                  +"<plus>+</plus>"
                  +"</li>");
    })

    $("li.question").on("click","plus",function() {
	alert("plus clicked")
    });
    
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

$(document).on("click", ".chooser select.question", function() {
  alert("clicked!");
});

var binding = new Shiny.InputBinding();

binding.find = function(scope) {
  return $(scope).find(".chooser");
};

binding.initialize = function(el) {
  updateChooser(el);
};

binding.getValue = function(el) {
  console.log("binding.getValue triggered")
  console.log($.makeArray($(el).find("select.questions option").map(function(i, e) { return e.value; })))
  return {
    left: $.makeArray($(el).find("select.left option").map(function(i, e) { return e.value; })),
    right: $.makeArray($(el).find("select.right option").map(function(i, e) { return e.value; })),
    question: $.makeArray($(el).find("select.question option").map(function(i, e) { return e.value; }))
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
