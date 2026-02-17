


#' Extracting OpenOLAT Results from HTML Results Files
#'
#' To get detailed information from the individual questions of a test, this function
#' processes the HTML results files (test summaries) created by OpenOLAT, and (if required) combines
#' this the data with the information provided by [exams2openolat] to create the link to the
#' question source files (i.e., R/exams Rmd/Rnw questions). Is able to process results
#' exported via Open Olat (`zipfile`) in both German or English for now.
#'
#' TODO(R): Note that this function is still under development and is missing
#' a few features, see Sections 'Disclaimer' and 'Adding functionality'.
#'
#' @param rds `NULL` or character. If character, name of the RDS file procuded
#'        by [exams2openolat] when the test was generated used to extract original
#'        exam question file name and 'exname'. If `NULL` only the information from
#'        the zipfile is used.
#' @param zipfile character, name/path to the ZIP file (exported via OpenOlat)
#'        oontaining the HTML results files (amongst other files needed).
#' @param verbose logical, if `TRUE` some information is written to stdout.
#'
#' @return Returns a (tibble) data frame of dimension `N x K` where `N` corresponds to the total
#' number of questions. If 100 participants have taken a test with 20 questions each,
#' this would result in `N = 2000`. The columns contain:
#'
#' - `Username`: Participants user name (c-Kennung).
#' - `Institution`: Institution identifier (Matrikelnummer)
#' - `Name`: Full name of the participant.
#' - `ID`: OpenOLAT question identifier.
#' - `Email`: Participant email as shown in the HTML results file.
#' - `Status`: Status provided by OpenOLAT.
#' - `Score`: The participant's score for this question ("My Score" in the HTML file).
#' - `Answer`: The participant's answer, can be `NA` if empty.
#' - `Solution`: The correct solution.
#' - `RawText`: Raw question text, unformatted, can be used to search for keywords in the text.
#' - `Section`/`Item`: Section and item ID extracted from the exams olat identifier.
#'
#' If an additional RDS file (argument `rds`) is provided, the following columns are added:
#'
#' - `file`: Source file name (modified), path/name of the original R/exams file (Rmd/Rnw).
#' - `exname`: Name of the question (the exname meta-information from the R/exams question).
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
#'   the ZIP archive, tested for German and English.
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
#' rds     <- "GP06Dezember2024.rds"
#' zipfile <- "results_GP06Dezember2024.zip"
#' results <- olat_extract_html_results(rds, zipfile)
#'
#'
#' # ------------------------------------------------------------------
#' # Some plotting
#' # ------------------------------------------------------------------
#'
#' library("ggplot2")
#' library("patchwork")
#'
#' # Some demo plots; assumes that the students could only
#' # gain 0 points (incorrect) or 2 points (correct)
#' results$label <- with(results, paste(file, exname, sep = "\n"))
#' results$scoreLabel <- factor(results$Score > 0,
#'                              levels = c(FALSE, TRUE),
#'                              labels = c("Score == 0 (incorrect)",
#'                                         "Score > 0 (counted as correct)"))
#'
#' g1 <- ggplot(results) + geom_bar(aes(y = label, fill = Status), stat = "count") +
#'           labs(title = "Stacked barplot of answered/unanswerd questions") +
#'           labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
#'           theme_minimal()
#' g2 <- ggplot(results) + geom_bar(aes(y = label, fill = scoreLabel), stat = "count") +
#'           labs(title = "Stacked barplot of answered/unanswerd questions") +
#'           labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
#'           theme_minimal()
#'
#' plot(g1 + g2) # Patchwork plot
#'
#' # Histogram of Score distribution; here assuming the threshold was 22 points
#' library("dplyr")
#' results %>% group_by(Name) %>% summarize(Score = sum(Score)) %>%
#'     ggplot() + geom_histogram(aes(x = Score), binwidth = 1) +
#'         geom_vline(xintercept = 22, col = "tomato", lwd = 2) + 
#'         labs(title = "Histogram of total Score") +
#'         labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
#'         theme_minimal()
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
#' tmp <- as.matrix(tmp[, !grepl("^Name$", names(tmp))])
#'
#' # Estimate Rasch model
#' mr <- raschmodel(tmp)
#'
#' # Default plots
#' hold <- par(no.readonly = TRUE)
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
        "argument `rds` input incorrect or file not found" = is.null(rds) || isTRUE(file.exists(rds)),
        "argument `zipfile` incorrect or file not found" = isTRUE(file.exists(zipfile))
    )

    # We require openxlsx to read the user details later on (step 6)
    if (!requireNamespace("openxlsx", quietly = TRUE))
        stop("Requires openxlsx to be installed (reading XLSX files)")

    # ---------------------------------------------------------------
    # (1) Unzipping the `zipfile` archive (requires unzip) and
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

        # This is a hardcoded, but trying to guess the language. If the results folder is called
        # - Resultate: German language
        # - Results: English language
        # - Else: No idea, stop.
        # The named vector $userdetails is used as a lookup to identify and rename
        # the required columns. Can be regex (handed over to grepl(..., perl = FALSE)).
        if (lang$resultsdir == "Resultate") {
            lang$lang <- "de"
            lang$userdetails <- c("Username"    = "Anmeldename",
                                  "First"       = "Vorname",
                                  "Last"        = "Nachname",
                                  "Institution" = "Matrikelnummer")
        } else if (lang$resultsdir == "Results") {
            lang$lang <- "en"
            lang$userdetails <- c("Username"    = "Username",
                                  "First"       = "First.*name",
                                  "Last"        = "Last.*name",
                                  "Institution" = "Institution.*identifier.*")
        } else {
            stop("Not able to guess the language from the results directory name which is \"", lang$resultsdir, "\".")
        }

        # Next we need to auto-guess the language of the folders containing
        # the attempts. In EN it is "Attempt_X", in German "Versuch_*", we try to guess it here.
        dirs <- list.dirs(file.path(d, lang$resultsdir, "userdata"), recursive = FALSE)
        dirs <- unlist(lapply(dirs, function(x) list.dirs(x, recursive = FALSE, full.names = FALSE)))
        # Extracting language dependent name
        att  <- unique(regmatches(dirs, regexpr("^.*?(?=(_))", dirs, perl = TRUE)))
        if (!is.character(att) & length(att) == 1)
            stop("issues guessing language of folder name for 'attempts', got ", paste(att, collapse = ", "))
        lang$attempt <- att

        # Searching for 'root xlsx' file which contains Name, Matrikelnummer, ... (detailed user details)
        tmp <- Sys.glob(file.path(d, lang$resultsdir, "*.xlsx"))
        stopifnot("can't find XLSX file with user details (in Results/Resultate)" = isTRUE(file.exists(tmp)))
        lang$userdetails_file <- tmp

        if (verbose) {
            message("- Quick check: Structure of the ZIP content looks fine")
            message("- Automatic language check:")
            message("       Name of results directory:     ", lang$resultsdir)
            message("       Name of 'attempt' directories: ", lang$attempt)
            message("       File with user details:        ", basename(lang$userdetails))
        }
        invisible(lang)
    }
    lang <- check_tmpdir_content_and_guess_language(tmpdir)


    # ---------------------------------------------------------------
    # (2) Next we need to read the imsmanifest.xml file which is the
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



    # ---------------------------------------------------------------
    # (3) Reading content of the RDS file (if provided). Reduce the list by
    #     one level (remove the 'section' segmentation) and coerce
    #     to data.frame, storing question name (exname) and source file name.
    #     Finally, attach the additional meta information from the RDS file
    #     to 'olat_ids' (currently name of the original exams file and
    #     the exname; could be extended in the future).
    # ---------------------------------------------------------------
    if (!is.null(rds)) {
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

        stopifnot("number of elements read from manifest does not match number of questions read from the rds" =
                  nrow(olat_ids) == nrow(rds))

        # Column-bind `rds` and `olat_ids` to create the link from R/exams to the
        # Open OLAT results files (HTML files) read next.
        olat_ids <- cbind(olat_ids, rds)
        rm(rds)
    }


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
            pattern  <- paste0("(?<=(\\/))\\w+(?=(\\/", lang$attempt, "))")
            tmp      <- regmatches(htmlfile, regexpr(pattern, htmlfile, perl = TRUE))
            Username <- regmatches(tmp, regexpr("(?<=(_))[A-Za-z0-9]+$", tmp, perl = TRUE))

            # Extracting name and email as shown in the HTML file
            #Name  <- xml_find_all(x, ".//div[contains(@class, 'o_userShortDescription')]//tr[contains(@class, 'o_user')]/td")
            #Name  <- trimws(xml_text(Name))
            Email <- xml_find_all(x, ".//div[contains(@class, 'o_userShortDescription')]//tr[contains(@class, 'o_email')]/td")

            return(list(Username = Username, Email = trimws(xml_text(Email))))
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

                # Input field (text/numeric) interaction
                if (is.na(tmp)) {
                    x   <- xml_find_first(x, ".//span[contains(@class, 'textEntryInteraction')]/input")
                    res <- xml_attr(x, "value")
                    if (nchar(res) == 0) res <- NA_character_

                # Choice interaction
                } else {
                    # Legacy mode, before 2026 single choice questions used 'input's,
                    tmp_old <- xml_find_all(tmp, ".//table/tr[contains(@class, 'choiceinteraction')]/td[contains(@class, 'control')]/input")
                    if (length(tmp_old) > 0L) {
                        tmp_old <- ifelse(xml_attr(tmp_old, "checked") == "checked", 1L, 0L)
                        res     <- paste(ifelse(is.na(tmp_old), 0, 1), collapse = "|")
                    # Adjustment to newer (2026?) Open Olat output format
                    } else {
                        tmp_new <- xml_find_all(tmp, ".//table//tr[contains(@class, 'choiceinteraction')]/td[contains(@class, 'control')]/i")
                        tmp_new <- as.integer(grepl("_radio_on", xml_attr(tmp_new, "class")))
                        res     <- paste(tmp_new, collapse = "|")
                    }
                }

                return(res)
            }

            # Using header as starting point for solution
            ans <- xml_find_first(x, ".//div[contains(@class, 'panel-body')]/div[not(contains(@class, 'o_qti21_solution'))]")
            sol <- xml_find_first(x, ".//div[contains(@class, 'panel-body')]/div[contains(@class, 'o_qti21_solution')]")

            # Extracting question text (HTML -> xml_text)
            txt <- xml_find_first(x, ".//div[contains(@class, 'panel-body')]/h4/following-sibling::div[1]")
            txt <- trimws(xml_text(xml_find_all(txt, ".//text()[not(ancestor::script)]"), trim = TRUE))
            txt <- trimws(paste(txt, collapse = " "))

            # Extract solution and answer, return
            result <- c(Answer = extract(ans), Solution = extract(sol), RawText = txt)
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
    # and combine it with the olat_ids (information from the manifest and
    # potentially information from the rds file)
    worker <- function(html, olat_ids) {
        user_results <- get_exam_results(html, long = TRUE)
        return(merge(user_results, olat_ids, by = "ID", all.x = TRUE, all.y = FALSE))
    }

    results_list <- lapply(htmlfiles, worker, olat_ids = olat_ids)
    results      <- do.call(rbind, results_list)

    # ---------------------------------------------------------------
    # (6) Reading information from the 'userdetails' file (the XLSX file
    #     in the main folder) and attach these details to 'results'.
    # ---------------------------------------------------------------
    read_userdetails <- function(x) {
        res <- openxlsx::read.xlsx(x$userdetails_file, sheet = 1L, startRow = 2L, cols = 1:5)

        # Renaming columns -- standardize column names
        for (i in seq_along(lang$userdetails))
            names(res)[grepl(lang$userdetails[[i]], names(res))] <- names(lang$userdetails)[i]

        ## Ensure we have all the columns we need
        if (length(idx <- which(!names(lang$userdetails) %in% names(res))) > 0L) {
            stop("Unable to identify all required columns in the data from the user details file (XLSX file). ",
                 "Missing: ", paste(names(lang$userdetails)[idx], collapse = ", "), " (Debug info: currently have ",
                 paste(names(res), collapse = ", "))
        }

        # Dropping unnecessary columns, combine Name (remove first and last name afterwards) and return
        res <- res[, names(lang$userdetails)]
        res$Name <- paste(res$First, res$Last, sep = " ")
        res$First <- res$Last <- NULL
        return(res)
    }
    results <- merge(read_userdetails(lang), results, by = "Username", all = TRUE)

    # `results$Status` contains a status provided by Open OLAT
    # - Answered: Participant answered the question (used 'save answer'). It is, however,
    #   possible that they saved an "empty field". Thus, we replace "Answered" with
    #   "Answered but empty" if the user's Answer is NA.
    idx <- results$Status == "Answered" & is.na(results$Answer)
    if (length(idx) > 0) results$Status[idx] <- "Answered but empty"

    # Final message before returning the data
    if (verbose) {
        message("- Got ", nrow(results), " individual questions/answers from ", length(htmlfiles), 
                " HTML results files,\n  in other words ", nrow(results) / length(htmlfiles),
                " questions/results from ", length(htmlfiles), " users/participants.")
    }

    # Return tibble if possible
    if (requireNamespace("tidyr", quietly = TRUE)) results <- tidyr::as_tibble(results)

    # Return results
    return(results)
}


