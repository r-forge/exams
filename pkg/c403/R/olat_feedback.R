
#' Generate OLAT test feedback files (answer/solution)
#'
#' Similar to what \code{\link[c403]{olat_eval}} with the additional
#' flag \code{export = TRUE} does but in a different way. Shows ansers
#' and solutions. Creates a temporary html file.
#'
#' @param res data.frame, result from olat_eval
#' @param xexam list as returned from reading the rds file
#' @param i integer, row index (which row in 'x' to render)
#' @param show logical, if set to \code{TRUE} the html file will
#'        be opened in a browser
#' @param name character, name of the test, will be used to name
#'        the zip archive file and the html files
#' @param htmlfile character, name of the output file
#'
#' @return Returns the name of the zip file created.
#'
#' @author Reto Stauffer
#' @export
olat_feedback <- function(res, xexam, name = "olat_feedback") {

    stopifnot(is.character(name) || !length(name) == 1L)
    name <- gsub(" ", "_", name)

    # Render all html files
    fn <- function(i, name) {
        htmlfile <- sprintf("%s.html", name)
        return(olat_feedback_render_one(res, xexam, i, htmlfile, show = FALSE))
    }
    html <- sapply(1:nrow(res), fn, name = name)

    # Change working directory
    holdwd <- getwd(); on.exit(setwd(holdwd)); setwd(tempdir())

    # Pack (zip) and return name of the zip file
    zipfile <- file.path(holdwd, sprintf("%s.zip", name))
    zip(zipfile, res$username)
    invisible(basename(zipfile))

}

#' @import xml2
#' @export
#' @rdname olat_feedback
olat_feedback_render_one <- function(res, xexam, i, htmlfile = "Result.html", show = FALSE) {

    # Sanity checks
    stopifnot(inherits(res, "data.frame"))
    stopifnot(is.numeric(i) | !length(i) == 1L)
    stopifnot(is.logical(show) & length(show) == 1L)

    test.id <- 1L + (res$id.1[i] - 1L) %% length(xexam)
    
    # Take test for this participant
    stopifnot(test.id > 0L & test.id <= length(xexam))
    test <- xexam[[test.id]]

    # Doc template: TODO: should be a file in the package
    template <- file.path(system.file(package = "c403"),
                          "olat_feedback_template.html")
    stopifnot(file.exists(template))
    doc <- read_html(template)


    
    # Append a summary div (will be filled later on)
    xml_add_child(xml_find_first(doc, "//html/body"), "div", id = "meta")
    xml_add_child(xml_find_first(doc, "//html/body"), "div", id = "summary")
    
    # Converts binary string (e.g., "0100") into
    # a logical vector (c(FALSE, TRUE, FALSE, FALSE)).
    #
    # @param x character something like 00100 or 100 or so.
    #
    # @returns Returns a logical vector.
    binary_to_logical <- function(x) as.logical(as.integer(strsplit(x, "")[[1]]))
    
    # Helper function
    #
    # @param ans logical whether or not the participant selected this this answer
    # @param sol logical whether or not this solution is correct
    #
    # @return Returns FALSE if the answer given by the participant was not
    # correct, TRUE if it was correct, and NA else.
    check_answer_solution <- function(ans, sol) {
        if (ans & sol) {
            res <- TRUE
        } else if (!sol & ans) {
            res <- FALSE
        } else {
            res <- NA
        }
        return(res)
    }
    
    # ------------------------------------------
    # Looping over the individual questions in the test
    # to generate the html output.
    # ------------------------------------------
    # qnr: question number (loop index)
    for (qnr in seq_along(test)) { 
        # Add new <div class="question" /> element
        tmp <- xml_add_child(xml_find_first(doc, "//html/body"),
                             "div", id = test[[qnr]]$metainfo$id, class = "question")
        # ADding title and question (text)
        xml_set_text(xml_add_child(tmp, "h1", id = sprintf("question-%d", qnr)),
                     sprintf("Question %d", qnr))
        xml_add_child(tmp, xml_cdata(paste(test[[qnr]]$question, collapse = "\n")))
    
        # Answer given by the participant
        answer   <- binary_to_logical(res[i, paste("answer", qnr, sep = ".")])
        solution <- test[[qnr]]$metainfo$solution
    
        # Just check if the test solution fits the one stored in the data.frame x.
        # Not required, but would prevent errors matching wrong results and
        # questions to some extent.
        stopifnot(identical(solution, binary_to_logical(res[i, paste("solution", qnr, sep = ".")])))
    
        # Append an <ul> element to add the possible answers
        ul <- xml_add_child(tmp, "ul", class = "answerlist")
        for (j in seq_along(test[[qnr]]$questionlist)) {
            # Correct or not?
            check <- check_answer_solution(answer[j], solution[j])
            
            li <- xml_add_child(ul, "li", class = paste("check", as.character(check), sep = "-"))
            xml_add_child(li, "span", class = paste("solution", ifelse(solution[j], "correct", "incorrect")))
            xml_add_child(li, "span", class = paste("answer",
                                                    ifelse(answer[j],   "selected", "notselected"),
                                                    ifelse(solution[j], "correct", "incorrect")))
            xml_add_child(li, xml_cdata(test[[qnr]]$questionlist[j]))
        }
        
        # Append a second ul with the answers
        xml_set_text(xml_add_child(tmp, "h3"), "Solution")
        ul <- xml_add_child(tmp, "ul", class = "solutionlist")
        for (j in seq_along(test[[qnr]]$solutionlist)) {
            # Append solution
            li <- xml_add_child(ul, "li", class = paste("solution", ifelse(solution[j], "correct", "incorrect")))
            xml_add_child(li, xml_cdata(test[[qnr]]$solutionlist[j]))
        }
    }

    
    # ------------------------------------------
    # Adding meta information
    # ------------------------------------------
    div <- xml_find_first(doc, "//*/div[@id='meta']")
    xml_set_text(xml_add_child(div, "h1"), "Meta")
    ul <- xml_add_child(div, "ul", class = "meta")
    xml_set_text(xml_add_child(ul, "li"), sprintf("Name: %s %s", res$firstname[i], res$lastname[i])) 
    xml_set_text(xml_add_child(ul, "li"), sprintf("User: %s", res$username[i]))
    xml_set_text(xml_add_child(ul, "li", id = "meta-score"), "Points:  ")
    
    li <- xml_find_first(doc, "//*/li[@id='meta-score']")
    xml_set_text(xml_add_child(li, "b"), sprintf("%d / %d", res$score[i], length(test)))
    xml_set_text(xml_add_child(li, "span"), sprintf("  (%.0f percent)", 100 * res$score[i] / length(test)))


    # ------------------------------------------
    # The summary table
    # ------------------------------------------
    div <- xml_find_first(doc, "//*/div[@id='summary']")
    xml_set_text(xml_add_child(div, "h2"), "Summary Table")
    table <- xml_add_child(div, "table", class = "summary-table")
    tr <- xml_add_child(xml_add_child(table, "thead"), "tr")
    for (col in c("Nr.", "Type", "Points", "Duration", "Name"))
        xml_set_text(xml_add_child(tr, "th"), col)

    tbody <- xml_add_child(table, "tbody")
    for (qnr in seq_along(test)) {
        # Get answer/solution logical vectors once more
        answer   <- binary_to_logical(res[i, paste("answer", qnr, sep = ".")])
        solution <- test[[qnr]]$metainfo$solution
        # Add row
        tr <- xml_add_child(tbody, "tr",
                            class = if (identical(answer, solution)) "correct" else "incorrect")
        values <- list(qnr,
                       test[[qnr]]$metainfo$type,
                       res[i, paste("points", qnr, sep = ".")], 
                       paste(res[i, paste("duration", qnr, sep = ".")], " sec"), 
                       xml_cdata(sprintf("<a href=\"#question-%d\">%s</a>", qnr,
                                         test[[qnr]]$metainfo$file)))
        # Loop over values, add data
        for (val in values) {
            if (class(val) == "xml_cdata") {
                xml_add_child(xml_add_child(tr, "td"), val)
            } else {
                xml_set_text(xml_add_child(tr, "td"), as.character(val))
            }
        }
    }


    # ------------------------------------------
    # Write output into temporary folder
    # ------------------------------------------
    dir.create(file.path(tempdir(), res$username[i]), showWarnings = FALSE)
    file <- file.path(tempdir(), res$username[i], htmlfile)
    write_html(doc, file = file)
    if (show) browseURL(file)

    # Return file name
    invisible(file)
}

