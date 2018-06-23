##### create #####

observeEvent(input$ex_upload, {
  if (!is.null(input$ex_upload$datapath)) {
    for (i in seq_along(input$ex_upload$name)) {
      fext <- tolower(file_ext(input$ex_upload$name[i]))
      if (fext %in% c("rnw", "rmd")) {
        file.copy(input$ex_upload$datapath[i], file.path(directories$exercises, input$ex_upload$name[i]))
      } else {
        tdir <- tempfile()
        dir.create(tdir)
        # owd <- getwd()
        setwd(tdir)
        file.copy(input$ex_upload$datapath[i], input$ex_upload$name[i])
        if (fext == "zip") {
          unzip(input$ex_upload$name[i], exdir = owd)
        } else {
          untar(input$ex_upload$name[i], exdir = owd)
        }
        file.remove(input$ex_upload$name[i])
        cf <- dir(tdir)
        file.copy(cf, file.path(direcotires$exercises), recursive = TRUE)
        setwd(owd)
        unlink(tdir)
      }
    }
    exfiles <- list.files("exercises", recursive = TRUE)
    session$sendCustomMessage(type = 'exHandler', exfiles)
  }
})

foo <- function(x) {
  for (i in seq_along(x))
    cat(x[i], "\n")
  invisible(NULL)
}

output$show_exercises <- DT::renderDataTable({
  data.frame("Exercises" = available_exercises())
}, selection = "single", escape = FALSE, options = list(dom = 't', paging = FALSE, ordering = FALSE))

output$download_exercises <- downloadHandler(
  filename = function() {
    paste("exercises", "zip", sep = ".")
  },
  content = function(file) {
    # owd <- getwd()
    dir.create(tdir <- tempfile())
    file.copy(directories$exercises, tdir, recursive = TRUE)
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
    # owd <- getwd()
    dir.create(tdir <- tempfile())
    file.copy(file.path(owd, list.files(".")), tdir, recursive = TRUE)
    setwd(tdir)
    zip(zipfile = paste("exams_project", "zip", sep = "."), files = c("exercises", "exams"))
    setwd(owd)
    file.copy(file.path(tdir, paste("exams_project", "zip", sep = ".")), file)
    unlink(tdir)
  }
)