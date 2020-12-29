library(shiny)
#library(purrr)
library(exams)

########

# x <- list()
# x$n <- list(argumentDescription = "The number of copies to be compiled from file",range ="integer",default=1L)
# x$nsamp <- list(argumentDescription = "The number(s) of exercise files sampled from each list element of file",range ="integer",default=NULL)
# x$template <- list(argumentDescription = "A specification of a LaTeX template",range =c("exam","solution","plain"),default=NULL)
# x$header <- list(argumentDescription = "A list of further options to be passed to the LaTeX files",range ="list",default="list(Date = Sys.Date())")
# x$name <- list(argumentDescription = "A name prefix for resulting exercises, by default chosen based on template",range ="character",default=NULL)
# x$encoding <- list(argumentDescription = "The default encoding to assume for file",range ="character",default="")
# x
# saveRDS(x,file = "exams2pdf.rds")
# 
# x <- list()
# x$n <- list(argumentDescription = "The number of copies to be compiled from file",range ="integer",default=1L)
# x$nsamp <- list(argumentDescription = "The number(s) of exercise files sampled from each list element of file",range ="integer",default=NULL)
# x$template <- list(argumentDescription = "A specification of a LaTeX template",range =c("plain"),default=NULL)
# x$name <- list(argumentDescription = "A name prefix for resulting exercises, by default chosen based on template",range ="character",default=NULL)
# x$question <- list(argumentDescription = "The header for resulting questions. FALSE removes the header for questions",range ="character",default="<h4>Question</h4>")
# x$solution <- list(argumentDescription = "The header for resulting solutions. FALSE removes the header for solutions",range ="character",default="<h4>Solution</h4>")
# x$mathjax <- list(argumentDescription = "Should the JavaScript from http://www.MathJax.org/ be included for rendering mathematical formulas?",range ="logical",default=NULL)
# x$resolution <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=100)
# x$width <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=4)
# x$height <- list(argumentDescription = "Options for rendering PNG (or SVG)",range ="numeric",default=4)
# x$svg <- list(argumentDescription = "Should graphics be rendered in SVG or PNG (default)?",range ="logical",default=FALSE)
# x$encoding <- list(argumentDescription = "The default encoding to assume for file",range ="character",default="")
# x
# saveRDS(x,file = "exams2html.rds")



# x <- readRDS("exams2html.rds")
# x <- cbind(argument = names(x), do.call("rbind", x))
# colnames(x)[2] <- "description"
# write.dcf(x, file = "exams2html.dcf", width = Inf) 
# 
# x <- readRDS("exams2pdf.rds")
# x <- cbind(argument = names(x), do.call("rbind", x))
# colnames(x)[2] <- "description"
# write.dcf(x, file = "exams2pdf.dcf", width = Inf) 
# 
# y <- read.dcf("exams2html.dcf")
# z <- read.dcf("exams2pdf.dcf")




#######################
# .assemble_things_into_a_data_frame <- function(tags, vals, 
#                                                nums) {
#   tf <- factor(tags, levels = unique(tags))
#   cnts <- table(nums, tf)
#   out <- array(NA_character_, dim = dim(cnts), dimnames = list(NULL, 
#                                                                levels(tf)))
#   if (all(cnts <= 1L)) {
#     out[cbind(nums, tf)] <- vals
#     out <- as.data.frame(out, stringsAsFactors = FALSE)
#   }
#   else {
#     levs <- colSums(cnts > 1L) == 0L
#     if (any(levs)) {
#       inds <- tf %in% levels(tf)[levs]
#       out[cbind(nums[inds], tf[inds])] <- vals[inds]
#     }
#     out <- as.data.frame(out, stringsAsFactors = FALSE)
#     for (l in levels(tf)[!levs]) {
#       out[[l]] <- rep.int(list(NA_character_), nrow(cnts))
#       i <- tf == l
#       out[[l]][unique(nums[i])] <- split(vals[i], nums[i])
#     }
#   }
#   out
# }
# 
# 
# file <- "exams2html.dcf"
# 
# lines <- readLines(file, skipNul = TRUE)
# ind <- grep("^[^[:blank:]][^:]*$", lines)
# if (length(ind)) {
#   lines <- strtrim(lines[ind], 0.7 * getOption("width"))
#   stop(gettextf("Invalid DCF format.\nRegular lines must have a tag.\nOffending lines start with:\n%s", 
#                 paste0("  ", lines, collapse = "\n")), domain = NA)
# }
# line_is_not_empty <- !grepl("^[[:space:]]*$", lines)
# nums <- cumsum(diff(c(FALSE, line_is_not_empty) > 0L) > 0L)
# nums <- nums[line_is_not_empty]
# lines <- lines[line_is_not_empty]
# line_is_escaped_blank <- grepl("^[[:space:]]+\\.[[:space:]]*$", 
#                                lines)
# if (any(line_is_escaped_blank)) 
#   lines[line_is_escaped_blank] <- ""
# line_has_tag <- grepl("^[^[:blank:]][^:]*:", lines)
# pos <- which(diff(nums) > 0L) + 1L
# ind <- !line_has_tag[pos]
# if (any(ind)) {
#   lines <- strtrim(lines[pos[ind]], 0.7 * getOption("width"))
#   stop(gettextf("Invalid DCF format.\nContinuation lines must not start a record.\nOffending lines start with:\n%s", 
#                 paste0("  ", lines, collapse = "\n")), domain = NA)
# }
# lengths <- rle(cumsum(line_has_tag))$lengths
# pos <- cumsum(lengths)
# tags <- sub(":.*", "", lines[line_has_tag])
# lines[line_has_tag] <- sub("[^:]*:[[:space:]]*", "", lines[line_has_tag])
# # fold <- is.na(match(tags, keep.white))
# # foldable <- rep.int(fold, lengths)
# # lines[foldable] <- sub("^[[:space:]]*", "", lines[foldable])
# # lines[foldable] <- sub("[[:space:]]*$", "", lines[foldable])
# vals <- mapply(function(from, to) paste(lines[from:to], collapse = "\n"), 
#                c(1L, pos[-length(pos)] + 1L), pos)
# #vals[fold] <- trimws(vals[fold])
# out <- .assemble_things_into_a_data_frame(tags, vals, nums[pos])
# if (!is.null(fields)) 
#   out <- out[fields]
# out





##############

exportFormatInput <- function(id) {
  exportFormats <- list.files(".",glob2rx("*.rds"))
  names <- tools::file_path_sans_ext(exportFormats)
  selectInput(NS(id, "exportFormat"), "Pick an output format", choices = names)
}

exportFormatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    list(
      selectedFormat = reactive(input$exportFormat),
      dataList = reactive(readRDS(paste0(input$exportFormat,".rds")))
    )
  })
}




examsArgumentUI <- function(id) {
  uiOutput(NS(id, "controls"))
}

make_ui <- function(x, id, var) {
  argumentLabel <- paste0(x$argumentDescription," (",var,")")
  argumentValue <- x$default
  if (x$range == "integer") {
    sliderInput(id, label = argumentLabel, min = 1, max = 50, value = argumentValue)
  } else if (x$range == "numeric") {
    numericInput(id, label = argumentLabel, min = 1, max = 1000, value = argumentValue)
  } else if (x$range == "logical") {
    checkboxInput(id, label = argumentLabel, value = argumentValue)
  } else if(x$range %in% c("character","list")) {
    textInput(id, label=argumentLabel, value = argumentValue)
  } else {
    selectInput(id, label=argumentLabel,choices = x$range, selected = argumentValue)
    # Not supported
    # NULL
  }
}

getArgumentValues <- function(x, val) {
  if (x$range %in% c("integer","numeric","logical")) {
    val
  } else if (x$range == "character") {
    as.character(val)
  } else if (x$range == "list") {
    eval(parse(text=as.character(val)))
  }else {
    # Not supported
    val
  }
}

examsArgumentServer <- function(id, df) {
  stopifnot(is.reactive(df))
  
  moduleServer(id, function(input, output, session) {
    vars <- reactive(names(df()))
    
    output$controls <- renderUI({
      lapply(vars(), function(var) make_ui(df()[[var]], NS(id, var), var))
    })
    
    reactive({
      each_var <- lapply(vars(), function(var) getArgumentValues(df()[[var]], input[[var]]))
      #each_var <- map(vars(), function(var) input[[var]])
      names(each_var) <- vars()
      #print(each_var)
      #paste0(each_var,collapse = ";; ")
      each_var
    })
  })
}



examsExportApp <- function() {
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        exportFormatInput("exportFormat"),
        examsArgumentUI("examsArgument"),
      ),
      mainPanel(
        #textOutput("compileCommand")
        p("Selected exams2xyz:"),
        verbatimTextOutput("selectedFormat"),
        p("List of arguments:"),
        verbatimTextOutput("compileCommand"),
        actionButton("compileExam",label = "Compile Exam"),
        p("Temp Dir:"),
        verbatimTextOutput("tempDirectory"),
        p("Generated Exams:"),
        verbatimTextOutput("generatedExams")
      )
    )
  )
  server <- function(input, output, session) {
    exportFormat <- exportFormatServer("exportFormat")
    examsArgument <- examsArgumentServer("examsArgument", exportFormat$dataList)
    
    dir.create(tdir <- tempfile())
    
    output$selectedFormat <- renderPrint(print(exportFormat$selectedFormat()))
    output$compileCommand <- renderPrint(print(examsArgument()))
    output$tempDirectory <- renderPrint(print(tdir))

    
    observeEvent(input$compileExam, {
      #message("running exams2xyz")
      # exams2pdf("dist.Rmd")
      ll <- examsArgument()
      ll$file <- "dist.Rmd"
      ll$dir <- tdir
      do.call(exportFormat$selectedFormat(),ll)
      output$generatedExams <- renderPrint(print(list.files(tdir)))
    })
  }
  shinyApp(ui, server)
}

examsExportApp()
