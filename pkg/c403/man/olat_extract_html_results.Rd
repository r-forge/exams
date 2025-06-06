% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/olat_extract_html_results.R
\name{olat_extract_html_results}
\alias{olat_extract_html_results}
\title{Extracting OpenOLAT Results from HTML Results Files}
\usage{
olat_extract_html_results(rds, zipfile = NULL, verbose = TRUE)
}
\arguments{
\item{rds}{character, name of the RDS file procuded by \link{exams2openolat} when the
test was generated.}

\item{zipfile}{character, name/path to the ZIP file (exported via OpenOlat)
oontaining the HTML results files (amongst other files needed).}

\item{verbose}{logical, if \code{TRUE} some information is written to stdout.}
}
\value{
Returns a \code{data.frame} of dimension \verb{N x 13} where \code{N} corresponds to the total
number of questions. If 100 participants have taken a test with 20 questions each,
this would result in \code{N = 2000}. The columns contain:
\itemize{
\item \code{ID}: OpenOLAT question identifier.
\item \code{Name}/\code{User}: Participant name and username extracted from the path to the HTML file.
\item \code{html_Name}/\code{html_Email}: Participant name and email as shown in the HTML file.
\item \code{Status}: Status provided by OpenOLAT.
\item \code{Score}: The participant's score for this question ("My Score" in the HTML file).
\item \code{Answer}: The participant's answer, can be \code{NA} if empty.
\item \code{Solution}: The correct solution.
\item \code{filename}: Source file name (modified), path/name of the original R/exams file (Rmd/Rnw).
\item \code{exname}: Name of the question (the exname meta-information from the R/exams question).
\item \code{Section}/\code{Item}: The original section/item provided by the \code{rds} file.
}

Besides \code{Score} (numeric), \code{Section}/\code{Item} (int) everything is of class character.
}
\description{
Warning: This function has been written in December 2024 for a specific
analysis and is not yet feature complete and tested properly. Use at your own risk!
}
\details{
To get detailed information from the individual questions of a test, this function
processes the HTML results files (test summaries) created by OpenOLAT, and combines
this the data with the information provided by \link{exams2openolat} to create the link to the
question source files (i.e., R/exams Rmd/Rnw questions).

A brief summary of the individual steps:
\enumerate{
\item Reading and flattening the \code{rds} file (source file name, and question name (\code{exname})).
\item Unzips the \code{zipfile}, tries to guess the language of the content in the ZIP file,
and checks if the content looks as expected.
\item Searching for the manifest (\code{imsmanifest.xml}) containing the OpenOLAT IDs;
combine with the information from step (1) to create the link between source files
and OpenOLAT IDs.
\item Identifying all HTML results files (HTML test summary) containing the required
detailed information.
\item Parsing all HTML files, extracting user information and details about each
individual question (OpenOLAT ID, Score, user Answer, correct Solution).
This is combined with the information from step (2).
}

After that a few small modifications are made on the resulting \code{data.frame}
before it is returned.
}
\section{Disclaimer and missing features}{


TODO: This is a first implementation of this feature and there is a series of
todo's and missing features. Incomplete list of known missing features:
\itemize{
\item Depending on the (user specific) OpenOLAT language setting, the exported ZIP file
comes in different languages. We 'auto guess' the language based on the content of
the ZIP archive.
\item Originally implemented for string, num, and schoice questions.
Not sure if it works for mchoice, definitively no support for cloze questions at the moment.
\item Handling of multiple attempts (evaluate first, second, last attempt?).
\item Support for multiple tests (if the "Results" folder contains multiple "test*" directories).
\item Variations of questions (limited support; import works but post-processing might get
difficult/impossible).
}
}

\section{Adding functionality}{


TODO: The plan is to add additional functionality to produce output similar to what has been
implemented already for the "nops workflow", to allow performing the same checks/analysis
no matter where the results come from. See:
\itemize{
\item \url{https://git.uibk.ac.at/econstat/exams/demo/-/tree/main/gp-2024-02}
}
}

\examples{
\dontrun{

# 'Minimal' of the analysis performed in December 2024 (for which this
# function was originally written); few ggplot2 plots plus code to prepare
# the data matrix for estimating a Rasch model. Can't be run by end-users as
# we can't provide the data needed to run the example, this serves as a
# template for future developments/ideas.
library("c403")

rds     <- "GP06Dezember2024.rds"
zipfile <- "results_GP06Dezember2024.zip"
results <- olat_extract_html_results(rds, zipfile)


# ------------------------------------------------------------------
# Some plotting
# ------------------------------------------------------------------

library("ggplot2")
library("patchwork")

# Some demo plots; assumes that the students could only
# gain 0 points (incorrect) or 2 points (correct)
results$label <- with(results, paste(file, exname, sep = "\n"))
results$scoreLabel <- factor(results$Score > 0,
                             levels = c(FALSE, TRUE),
                             labels = c("Score == 0 (incorrect)",
                                        "Score > 0 (counted as correct)"))

g1 <- ggplot(results) + geom_bar(aes(y = label, fill = Status), stat = "count") +
          labs(title = "Stacked barplot of answered/unanswerd questions") +
          labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
          theme_minimal()
g2 <- ggplot(results) + geom_bar(aes(y = label, fill = scoreLabel), stat = "count") +
          labs(title = "Stacked barplot of answered/unanswerd questions") +
          labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
          theme_minimal()

plot(g1 + g2) # Patchwork plot

# Histogram of Score distribution; here assuming the threshold was 22 points
library("dplyr")
results \%>\% group_by(Name) \%>\% summarize(Score = sum(Score)) \%>\%
    ggplot() + geom_histogram(aes(x = Score), binwidth = 1) +
        geom_vline(xintercept = 22, col = "tomato", lwd = 2) + 
        labs(title = "Histogram of total Score") +
        labs(subtitle = paste("Number of participants: ", length(unique(results$User)))) +
        theme_minimal()

# ------------------------------------------------------------------
# Estimating Rasch model
# ------------------------------------------------------------------

library("tidyr")
library("psychotools")

# Prepare result to binary matrix for Rasch model
tmp <- transform(subset(results, select = c(Name, file, Score)), Score = as.integer(Score > 0)) |>
        pivot_wider(names_from = file, values_from = Score) |>
        as.data.frame()
tmp <- as.matrix(tmp[, !grepl("^Name$", names(tmp))])

# Estimate Rasch model
mr <- raschmodel(tmp)

# Default plots
hold <- par(no.readonly = TRUE)
par(mar = c(20, 12, 2.5, 1))
plot(mr, type = "profile")
par(hold)
plot(mr, type = "piplot")

}

}
\author{
Reto
}
