


#' Extracting OpenOLAT Results from HTML Results Files
#'
#' Warning: This function has been written in December 2024 for a specific
#' analysis and is not yet feature complete and tested properly. Use at your own risk!
#'
#' To get detailed information from the individual questions of a test, this function
#' processes the HTML results files (test summaries) created by OpenOLAT, and combines
#' this the data with the information provided by [exams2openolat] to create the link to the
#' question source files (i.e., R/exams Rmd/Rnw questions).
#'
#' @param rds character, name of the RDS file procuded by [exams2openolat] when the
#'        test was generated.
#' @param zipfile character, name/path to the ZIP file (exported via OpenOlat)
#'        oontaining the HTML results files (amongst other files needed).
#' @param verbose logical, if `TRUE` some information is written to stdout.
#'
#' @return Returns a `data.frame` of dimension `N x 13` where `N` corresponds to the total
#' number of questions. If 100 participants have taken a test with 20 questions each,
#' this would result in `N = 2000`. The columns contain:
#'
#' - `ID`: OpenOLAT question identifier.
#' - `Name`/`User`: Participant name and username extracted from the path to the HTML file.
#' - `html_Name`/`html_Email`: Participant name and email as shown in the HTML file.
#' - `Status`: Status provided by OpenOLAT.
#' - `Score`: The participant's score for this question ("My Score" in the HTML file).
#' - `Answer`: The participant's answer, can be `NA` if empty.
#' - `Solution`: The correct solution.
#' - `filename`: Source file name (modified), path/name of the original R/exams file (Rmd/Rnw).
#' - `exname`: Name of the question (the exname meta-information from the R/exams question).
#' - `Section`/`Item`: The original section/item provided by the `rds` file.
#'
#' Besides `Score` (numeric), `Section`/`Item` (int) everything is of class character.
#'
#' @section Disclaimer and missing features:
#'
#' TODO: This is a first implementation of this feature and there is a series of
#' todo's and missing features. Incomplete list of known missing features:
#'
#' - Depending on the (user specific) OpenOLAT language setting, the exported ZIP file
#'   comes in different languages. We 'auto guess' the language based on the content of
#'   the ZIP archive.
#' - Originally implemented for string, num, and schoice questions.
#'   Not sure if it works for mchoice, definitively no support for cloze questions at the moment.
#' - Handling of multiple attempts (evaluate first, second, last attempt?).
#' - Support for multiple tests (if the "Results" folder contains multiple "test*" directories).
#' - Variations of questions (limited support; import works but post-processing might get
#'   difficult/impossible).
#'
#' @section Adding functionality:
#'
#' TODO: The plan is to add additional functionality to produce output similar to what has been
#' implemented already for the "nops workflow", to allow performing the same checks/analysis
#' no matter where the results come from. See:
#'
#' * <https://git.uibk.ac.at/econstat/exams/demo/-/tree/main/gp-2024-02>
#'
#' @details
#' A brief summary of the individual steps:
#'
#' 1. Reading and flattening the `rds` file (source file name, and question name (`exname`)).
#' 2. Unzips the `zipfile`, tries to guess the language of the content in the ZIP file,
#'    and checks if the content looks as expected.
#' 3. Searching for the manifest (`imsmanifest.xml`) containing the OpenOLAT IDs;
#'    combine with the information from step (1) to create the link between source files
#'    and OpenOLAT IDs.
#' 4. Identifying all HTML results files (HTML test summary) containing the required
#'    detailed information.
#' 5. Parsing all HTML files, extracting user information and details about each
#'    individual question (OpenOLAT ID, Score, user Answer, correct Solution).
#'    This is combined with the information from step (2).
#'
#' After that a few small modifications are made on the resulting `data.frame`
#' before it is returned.
#'
#' @examples
#' \dontrun{
#'
#' # 'Minimal' of the analysis performed in December 2024 (for which this
#' # function was originally written); few ggplot2 plots plus code to prepare
#' # the data matrix for estimating a Rasch model. Can't be run by end-users as
#' # we can't provide the data needed to run the example, this serves as a
#' # template for future developments/ideas.
#' library("c403")
#'
#' # Extracting all the required information
#' rds <- "GP_December2024.rds"
#' zipfile <- "results_GP_December2024.zip"
#' results <- olat_extract_html_results(rds = rds, zipfile = zipfile)
#'
#'
#' # ------------------------------------------------------------------
#' # Plotting
#' # ------------------------------------------------------------------
#'
#' library("ggplot2")
#' library("patchwork")
#'
#' # Some demo plots; assumes that the students could only
#' # gain 0 points (incorrect) or 2 points (correct)
#' results$label <- with(results, paste(file, exname, sep = "\n"))
#'
#' add_score_label <- function(x) {
#'     res <- rep(NA_character_, nrow(x))
#'     res[x$Score == 2] <- "Correct"
#'     res[x$Score == 0 & grepl("Answered", x$Status)] <- "Answered, incorrect"
#'     res[x$Score == 0 & !grepl("Answered", x$Status)] <- "Not answered"
#'     #x$labelScore <- factor(res, c("Answered, incorrect", "Not answered", "Correct"))
#'     x$labelScore <- factor(res, c("Answered, incorrect", "Correct", "Not answered"))
#'     return(x)
#' }
#' results <- add_score_label(results)
#' 
#' g1 <- ggplot(results) + geom_bar(aes(y = label, fill = Status), stat = "count") +
#'           scale_fill_manual(values = c("Answered" = "limegreen",
#'                                        "Answered but Empty" = "steelblue",
#'                                        "Seen but not answered" = "gray")) +
#'           labs(title = "Stacked barplot of answered/unanswerd questions") + theme_minimal()
#' g2 <- ggplot(results) + geom_bar(aes(y = label, fill = labelScore), stat = "count") +
#'           scale_fill_manual(values = c("Answered, incorrect" = "tomato",
#'                                        "Correct" = "limegreen", "Not answered" = "gray")) +
#'           labs(title = "Correct/incorrect given question | Status") + theme_minimal()
#' 
#' g1 + g2 # Patchwork plot
#'
#'
#' # Histogram of Score distribution; here assuming the threshold was 22 points
#' library("dplyr")
#' results %>% group_by(Name) %>% summarize(Score = sum(Score)) %>%
#'     ggplot() + geom_histogram(aes(x = Score), binwidth = 1) +
#'         geom_vline(xintercept = 22, col = "tomato", lwd = 2) + 
#'         labs(title = "Histogram of total Score") + theme_minimal()
#'
#' # ------------------------------------------------------------------
#' # Estimating Rasch model
#' # ------------------------------------------------------------------
#'
#' library("tidyr")
#' library("psychotools")
#'
#' # Prepare result to binary matrix for Rasch model
#' tmp <- transform(subset(results, select = c(Name, file, Score)), Score = as.integer(Score > 0)) |>
#'         pivot_wider(names_from = file, values_from = Score) |>
#'         as.data.frame()
#' tmp <- as.matrix(tmp[, grepl("^0Final", names(tmp))])
#'
#' # Estimate Rasch model
#' mr <- raschmodel(tmp)
#'
#' # Default plots
#' hold <- par(no.readonly = FALSE)
#' par(mar = c(20, 12, 2.5, 1))
#' plot(mr, type = "profile")
#' par(hold)
#' plot(mr, type = "piplot")
#'
#' }
#'
#' @importFrom stats setNames
#' @importFrom xml2 read_xml read_html xml_find_all xml_find_first xml_text xml_attr
#' @importFrom utils unzip
#' @export
#' @author Reto
olat_extract_html_results <- function(rds, zipfile = NULL, verbose = TRUE) {
    stopifnot(
        "`rds` input incorrect or file not found" = isTRUE(file.exists(rds)),
        "`zipfile` incorrect or file not found" = isTRUE(file.exists(zipfile))
    )


    # ---------------------------------------------------------------
    # (1) Reading content of the RDS file. Reduce the list by
    #     one level (remove the 'section' segmentation) and coerce
    #     to data.frame, storing question name (exname) and source file name.
    # ---------------------------------------------------------------
    rds <- readRDS(rds)
    # Alternatively use dplyr::bind_rows
    rds_to_df <- function(x) {
        fn <- function(r) { 
            r <- lapply(r, function(k) as.data.frame(k$metainfo[c("file", "name")]))
            return(do.call(rbind, r))
        }
        do.call(rbind, lapply(rds, fn))
    }
    rds <- rds_to_df(rds)
    names(rds) <- c("file", "exname")
    if (verbose) {
        message("- Found ", nrow(rds), " questions based on ",
                length(unique(rds$file)), " different R/exams questions (source files).")
    }


    # ---------------------------------------------------------------
    # (2) Unzipping the `zipfile` archive (requires unzip) and
    #     quickly checks if the content is as expected, i.e., if the
    #     content looks like an export from OpenOLAT containing the
    #     results from an test.
    # ---------------------------------------------------------------
    # Creating new temporary folder (using temporary file name as folder name)
    dir.create(tmpdir <- tempfile("olat_results_"))
    on.exit(unlink(tmpdir, recursive = TRUE))
    if (verbose) message("- Extracting ZIP archive \"", zipfile, "\".")
    tryCatch(unzip(zipfile, exdir = tmpdir),
             error = function(e) stop("Problems unzipping the ZIP file: ", e))

    check_tmpdir_content_and_guess_language <- function(d) {
        lang <- list()
        if (verbose) message("- Checking extracted files/folders ...")
        tmp <- list.dirs(d, recursive = FALSE, full.names = FALSE)
        stopifnot("issues guessing language (checking root folder of ZIP file content)" =
                  is.character(tmp) && length(tmp) == 1)
        # Else we know the (polylingual) name of the main folder
        lang$resultsdir <- tmp
        tmp <- list.dirs(file.path(d, lang$resultsdir), recursive = FALSE, full.names = FALSE)
        stopifnot(
            "can't find folder \"userdata\". ZIP content not as expected" = "userdata" %in% tmp,
            "can't find any \"^test[0-9]+$\" folder. ZIP content not as expected" = any(grepl("^test[0-9]+$", tmp))
        )
        # Next we need to auto-guess the language of the folders containing
        # the attempts. In EN it is "Attempt_X", in German "Versuch_*", we try to guess it here.
        dirs <- list.dirs(file.path(d, lang$resultsdir, "userdata"), recursive = FALSE)
        dirs <- unlist(lapply(dirs, function(x) list.dirs(x, recursive = FALSE, full.names = FALSE)))
        # Extracting language dependent name
        att  <- unique(regmatches(dirs, regexpr("^.*?(?=(_))", dirs, perl = TRUE)))
        if (!is.character(att) & length(att) == 1)
            stop("issues guessing language of folder name for 'attempts', got ", paste(att, collapse = ", "))
        lang$attempt <- att

        if (verbose) {
            message("- Quick check: Structure of the ZIP content looks fine")
            message("- Automatic language check:")
            message("       Name of results directory:     ", lang$resultsdir)
            message("       Name of 'attempt' directories: ", lang$attempt)
        }
        invisible(lang)
    }
    lang <- check_tmpdir_content_and_guess_language(tmpdir)


    # ---------------------------------------------------------------
    # (3) Next we need to read the imsmanifest.xml file which is the
    #     link between the randomizations (in `rds`) and the IDs used
    #     by Open OLAT. For that, we need to find the "<lang$resultsdir>/test*"
    #     directory which contains the manifest.
    #     TODO: Currently expects that there is only one, the logic
    #     of having multiple tests is not covered.
    # ---------------------------------------------------------------
    testdir <- list.dirs(file.path(tmpdir, lang$resultsdir), recursive = FALSE, full.names = FALSE)
    testdir <- testdir[grepl("^test[0-9]+$", testdir)]
    if (length(testdir) != 1)
        stop("Issues identifying the \"", lang$resultsdir, "/test*\" dir correctly.")

    # Find manifests file
    manifest <- file.path(tmpdir, lang$resultsdir, testdir, "imsmanifest.xml")
    stopifnot("issues finding \"imsmanifest.xml\"" = isTRUE(file.exists(manifest)))

    # Parsing the manifest. It is an XML file, but a broken XML, thus the tricks
    # of removing line one and parsing it as HTML rather than XML.
    # Returns a data.frame with the ID Open OLAT uses, the Section number as
    # well as the Item number, sorted by (Item, Section) ascending.
    read_manifest <- function(manifest) {
        man <- read_html(paste(readLines(manifest)[-1], collapse = "\n")) 
        ids <- gsub("_id$", "", xml_attr(xml_find_all(man, ".//dependency"), "identifierref"))
        # Need to extract section and itemnum to sort correctly
        ids <- data.frame(ID = ids,
                          Section = as.integer(regmatches(ids, regexpr("(?<=(section_))[0-9]+", ids, perl = TRUE))),
                          Item    = as.integer(regmatches(ids, regexpr("(?<=(item_))[0-9]+", ids, perl = TRUE))))
        # Sort by (i) Item, (ii) Section
        ids <- ids[order(ids$Item, ids$Section), ]
        return(ids)
    }
    olat_ids <- read_manifest(manifest)
    if (verbose) message("- Imported ", nrow(olat_ids), " IDs from the manifest file.")
    stopifnot("number of elements read from manifest does not match number of questions read from the rds" =
              nrow(olat_ids) == nrow(rds))

    # Column-bind `rds` and `olat_ids` to create the link from R/exams to the
    # Open OLAT results files (HTML files) read next.
    rds <- cbind(rds, olat_ids)
    rm(olat_ids)


    # ---------------------------------------------------------------
    # (4) Find user results; we are looking for the HTML file
    #     crated by Open OLAT (exported via the ZIP file) located
    #     in "<tmpdir>/<lang$resultsdir>/userdata/.../<lang$attempt>_[0-9]+/"
    #
    # Note that the function will extract the 'Attempt number'
    # and (currently) will fail if they are not all only attempt 1!
    # TODO: Extend support for multi-attempt results; ensure to
    # evaluate the correct result (first/all/last attempt?).
    # ---------------------------------------------------------------
    get_result_html_files <- function(dir, lang) {
        stopifnot(isTRUE(dir.exists(dir)))
        files <- file.path(dir, list.files(dir, recursive = TRUE))
        pattern <- paste0(".*\\/", lang$attempt, "_[0-9]+\\/.*\\.html$")
        files <- files[grepl(pattern, files)]

        # Checking attempt (there should only be 1s)
        pattern <- paste0("(?<=(", lang$attempt, "_))[0-9]")
        attempt <- as.integer(regmatches(files, regexpr(pattern, files, perl = TRUE)))
        stopifnot("not all attempts are 1th attempts!" = all(attempt == 1)) # TODO: Custom check

        # Return vector with full names of the HTML results files
        return(files)
    }
    htmlfiles <- get_result_html_files(file.path(tmpdir, lang$resultsdir), lang)
    if (verbose) message("- Found ", length(htmlfiles), " HTML files with user test results.")


    # ---------------------------------------------------------------
    # (5) Main step: Parsing user information, type (ID) of question,
    #     Score, and user Answer/correct Solution from the HTML file.
    #     This is done by `get_exam_results()` using some magic
    #     regex and XPath expressions.
    #
    # TODO: Note that this was only tested for string, num, schoice for now;
    # extend support in the future.
    # ---------------------------------------------------------------
    get_exam_results <- function(htmlfile, long = FALSE) {
        if (!isTRUE(file.exists(htmlfile))) stop("cannot find file \"", htmlfile, "\".")
        stopifnot(isTRUE(long) || isFALSE(long))

        # Parsing HTML file and find all 'items' sections
        doc   <- read_html(htmlfile)
        items <- xml_find_all(doc, ".//div[contains(@class, 'o_qti_items')]/div[contains(@class, 'o_qti_item')]")

        # Used as return list
        result <- list()

        # Getting user information
        get_userinfo <- function(x, htmlfile) {
            # Extracting Name and Username from the html file name
            pattern <- paste0("(?<=(\\/))\\w+(?=(\\/", lang$attempt, "))")
            tmp <- regmatches(htmlfile, regexpr(pattern, htmlfile, perl = TRUE))
            Name <- regmatches(tmp, regexpr(".*(?=(_))", tmp, perl = TRUE))
            User <- regmatches(tmp, regexpr("(?<=(_))[A-Za-z0-9]+$", tmp, perl = TRUE))

            # Extracting name and email as shown in the HTML file
            html_Name  <- xml_find_all(x, ".//div[contains(@class, 'o_userShortDescription')]//tr[contains(@class, 'o_user')]/td")
            html_Email <- xml_find_all(x, ".//div[contains(@class, 'o_userShortDescription')]//tr[contains(@class, 'o_email')]/td")

            return(list(Name = Name, User = User,
                        html_Name = trimws(xml_text(html_Name)), html_Email = trimws(xml_text(html_Email))))
        }
        result$User <- get_userinfo(doc, htmlfile)

        # Helper function to extract item header
        get_header <- function(x) {
            fn <- function(x) trimws(gsub("(\\t|\\n)", "", xml_text(x)))
            # OpenOLAT ID
            id     <- fn(xml_find_all(x, "table/tbody/tr[contains(@class, 'o_qti_item_id')]/td"))
            # Logged Status Message
            status <- fn(xml_find_all(x, "table/tbody/tr[contains(@class, 'o_sel_assessmentitem_status')]/td"))
            # Extracting score (numeric)
            score  <- fn(xml_find_all(x, "table/tbody/tr[contains(@class, 'o_sel_assessmentitem_score')]/td"))
            score  <- as.numeric(regmatches(score, regexpr("^.*?(?=(\\/))", score, perl = TRUE)))

            return(list(ID = id, Status = status, Score = score))
        }

        # Helper function to extract user Answer and correct Solution
        # - string/num: Content of the <input> field
        # - schoice: a string of the form "0|1|0|0|0" where '1' is enabled, '0' disabled
        get_ans_and_sol <- function(x) {
            # Helper function which returns either the content of an input field
            # (char) (can be NA if not answered by the user) or or answers of
            # (single) choice question codes as char "0|0|1|0".
            extract <- function(x) {
                tmp <- xml_find_first(x, ".//div[contains(@class, 'choiceInteraction')]")
                # Input field (text) interaction
                if (length(tmp) == 0) {
                    x   <- xml_find_first(x, ".//span[contains(@class, 'textEntryInteraction')]/input")
                    res <- xml_attr(x, "value")
                    if (nchar(res) == 0) res <- NA_character_
                # Choice interaction
                } else {
                    tmp <- xml_find_all(tmp, ".//table/tr[contains(@class, 'choiceinteraction')]/td[contains(@class, 'control')]/input")
                    tmp <- ifelse(xml_attr(tmp, "checked") == "checked", 1, 0)
                    res <- paste(ifelse(is.na(tmp), 0, 1), collapse = "|")
                }
                return(res)
            }

            # Using header as starting point for solution
            ans <- xml_find_first(x, ".//div[contains(@class, 'panel-body')]/div[not(contains(@class, 'o_qti21_solution'))]")
            sol <- xml_find_first(x, ".//div[contains(@class, 'panel-body')]/div[contains(@class, 'o_qti21_solution')]")

            # Extract solution and answer, return
            result <- list(Answer = extract(ans), Solution = extract(sol))
            return(result)
        }

        # Helper function to loop over all items
        fn <- function(item) {
            # Header: Contains exams/OLAT ID, score, and a status
            header <- get_header(item)
            # Answer and solution
            anssol <- get_ans_and_sol(item)
            return(c(header, anssol))
        }
        result$questionlist <- lapply(items, fn)

        # Long format requested? Using `dplyr::bind_rows` to convert the
        # questionlist (list of lists) into a data.frame and combine it
        # with the user information.
        if (long) {
            # Alternatively use dplyr::bind_rows
            tmp <- do.call(rbind, lapply(result$questionlist, as.data.frame))
            result <- cbind(as.data.frame(result$User), tmp)
        }

        # Returning named list (if `long = FALSE`) or data.frame (`long = TRUE`).
        return(result)
    }

    # Looping over all HTML files, extract the user information/user results,
    # and combine it with the information from the `rds` object (information from
    # the RDS file as well as the manifest) to finish linking R/exams and Open OLAT
    # results together.
    # Process all
    worker <- function(html, rds) {
        user_results <- get_exam_results(html, long = TRUE)
        return(merge(user_results, rds, by = "ID", all.x = TRUE, all.y = FALSE))
    }
    results_list <- lapply(htmlfiles, worker, rds = rds)
    results      <- do.call(rbind, results_list)
    if (verbose) {
        message("- Got ", nrow(results), " individual questions/answers from ", length(htmlfiles), 
                " HTML results files,\n  in other words ", nrow(results) / length(htmlfiles),
                " questions/results from ", length(htmlfiles), " users/participants.")
    }

    # `results$Status` contains a status provided by Open OLAT
    # - Answered: Participant answered the question (used 'save answer'). It is, however,
    #   possible that they saved an "empty field". Thus, we replace "Answered" with
    #   "Answered but empty" if the user's Answer is NA.
    idx <- results$Status == "Answered" & is.na(results$Answer)
    if (length(idx) > 0) results$Status[idx] <- "Answered but empty"

    # Return results
    return(results)
}

