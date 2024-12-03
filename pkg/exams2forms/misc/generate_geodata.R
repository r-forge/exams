#!/usr/bin/env Rscript
# -------------------------------------------------------------------
# Generating data sets for two R/exams geography related questions.
#
# Requirements:
# - rnaturalearth:  provides geoinformation and country data
# - sf:             simple feature for processing geodata
#
# Creates two different data sets, written to two R-files which
# can be copied into the R/exams question.
#
# _geodata_flags.R
# ----------------
# List of countries and their primary (direct) neighbors as well
# as secondary neighbors (neighbors of direct neighbors). In addition,
# a vector is stored with ISO2 country codes used to generate
# unicode flags for these countries.
# - Ignores non-sovern countries
# - Ignores countries with non-standard ISO2 code
# - Depending on input argument `N` reduces the countries
#   tho those which have at least one primary (direct) neighbor, at least one
#   secondary neighbor, and - overall - at least six primary/secondary
#   neighbors.
#
# _geodata_neighbors.R
# --------------------
# List of countries and their direct neighbors.
# - Ignores non-sovern countries
# - Depending on input `N` reduces the countries to those which
#   have at least 2 primary (direct) neighbors.
# -------------------------------------------------------------------
rm(list = objects())

suppressPackageStartupMessages(require("sf"))
suppressPackageStartupMessages(require("rnaturalearth"))

##################################################################
get_data <- function(language = "en", country = TRUE, N = c(continent = 10L, primary = 1L, secondary = 1L, neighbors = 6L)) {

    stopifnot(
        "argument `language` must be single character" = is.character(language) && length(language) == 1L,
        "argument `N` must be named numeric vector" = is.numeric(N) && !is.null(names(N)),
        "`N` must contain 'continent', 'primary', 'secondary', 'neighbors'" = all(c("continent", "primary", "secondary", "neighbors") %in% names(N)),
        "`N` must contain values >= 1" = all(N >= 0),
        "argument `country` must be TRUE or FALSE" = isTRUE(country) || isFALSE(country)
    )
    ne <- ne_countries("medium", returnclass = "sf")
    # Select only 'Country' or 'Souvern country'
    if (country) ne <- subset(ne, grepl("country", type, ignore.case = TRUE))

    # Removing countries with non-standard iso_a2_eh; not perfect, though.
    ne <- subset(ne, nchar(iso_a2_eh) == 2L)

    # Check if 'language' is available
    language <- paste("name", language, sep = "_")
    if (!language %in% names(ne))
        stop("Cannot find column \"", language, "\" (language does not exist)")
    ne$name   <- ne[[language]]
    neighbors <- st_touches(ne, ne) # Calculate touching geometries

    # Initialize resulting data.frame
    res <- data.frame(name = ne$name, iso2 = ne$iso_a2_eh, continent = ne$continent)

    # Getting primary neighbors
    get_primary <- function(x, ne, neighbors) {
        fn <- function(i) {
            tmp <- ne$name[neighbors[[i]]]
            if (length(tmp) == 0) list() else as.list(tmp)
        }
        lapply(seq_len(nrow(x)), fn)
    }
    res$primary <- get_primary(res, ne, neighbors)

    # Getting secondary neighbors
    get_secondary <- function(x) {
        fn <- function(i) {
            if (is.na(x[i, "primary"])) return(NA_character_)
            tmp <- subset(x, name %in% unlist(x$primary[i]), select = name, drop = TRUE)
            tmp <- unique(unlist(subset(x, name %in% tmp, select = primary)))
            tmp <- tmp[!tmp %in% c(x$name[i], unlist(x$primary[i]))]
            if (length(tmp) == 0) list() else as.list(tmp)
        }
        lapply(seq_len(nrow(x)), fn)
    }
    res$secondary <- get_secondary(res)

    # Get flag lookup vector
    iso2 <- setNames(res$iso2, res$name)

    # Removing continents with less than N countries
    tab <- table(res$continent)
    res <- subset(res, continent %in% names(tab)[tab > N["continent"]] &
                  lengths(primary) >= N["primary"] & lengths(secondary) >= N["secondary"] &
                  (lengths(primary) + lengths(secondary)) >= N["neighbors"],
                  select = -iso2)

    # Reducing flags
    iso2 <- iso2[unique(c(res$name, unlist(res$primary), unlist(res$secondary)))]

    return(list(data = res, iso2 = iso2))
}


# -------------------------------------------------------------------
# _geodata_flags.R
# -------------------------------------------------------------------
RFILE <- "_geodata_flags.R"
message("Generating data for ", RFILE)
t <- system.time(res_flags <- get_data())
message(sprintf(" - Data generation took %.2f seconds", as.numeric(t["elapsed"], unit = "secs")))
##DT::datatable(res_flags$data, options = list(paging = FALSE))

# Convert resulting data.frame into a list of named lists
fn <- function(y) if (length(y) == 0) NA_character_ else paste(unlist(y), collapse = ";")
lst <- lapply(seq_len(nrow(res_flags$data)), function(i, x) as.list(transform(x[i, ], primary = fn(primary), secondary = fn(secondary))), x = res_flags$data)

generate_geodata_flags <- function(x, iso2, width.cutoff = 300) {
    stopifnot(is.list(x), all(sapply(x, is.list)))
    res <- c("data <- list(")
    for (i in seq_along(x)) {
        msg <- sprintf("   list(name = \"%s\", continent = \"%s\", primary = \"%s\", secondary = \"%s\")",
                                   x[[i]]$name, x[[i]]$continent, x[[i]]$primary, x[[i]]$secondary)
        msg <- paste0(msg, if (i == length(x)) "" else ",")
        res <- c(res, msg)
    }
    res <- c(res, ")", "",
             "data <- do.call(rbind, lapply(data, as.data.frame))",
             "fn <- function(x) unname(sapply(x, function(y) if (is.na(y)) list() else strsplit(y, \";\")[[1]]))",
             "data <- transform(data, primary = fn(primary), secondary = fn(secondary))",
             "rm(fn)", "")
    # ISO2 codes (lookup)
    iso2 <- deparse(iso2, width.cutoff = width.cutoff)
    iso2[1]  <- paste0("iso2 <- ", iso2[1])
    iso2[-1] <- paste0("   ", iso2[-1])

    # Helper function to convert iso2 to unicode flag
    fn <- "iso_to_flag <- function(x) {
      fn <- function(y) paste(intToUtf8(as.integer(charToRaw(toupper(y))) + 127397, multiple = TRUE), collapse = \"\")
      return(sapply(x, fn))
    }"
    iso_to_flag_fun <- readLines(textConnection(fn))

    return(c(res, iso2, "", iso_to_flag_fun))
}
str_flags <- generate_geodata_flags(lst, res_flags$iso2)
message(" - Writing into ", RFILE)
writeLines(str_flags, RFILE)
message(" - Done ...")


# -------------------------------------------------------------------
# _geodata_neighbor.R
# -------------------------------------------------------------------
RFILE <- "_geodata_neighbor.R"
message("Generating data for ", RFILE)
t <- system.time(res_nb <- get_data(N = c(continent = 10L, primary = 2L, secondary = 0L, neighbors = 0L)))
message(sprintf(" - Data generation took %.2f seconds", as.numeric(t["elapsed"], unit = "secs")))
##DT::datatable(res_flags$data, options = list(paging = FALSE))

# Convert resulting data.frame into a list of named lists
fn <- function(y) if (length(y) == 0) NA_character_ else paste(unlist(y), collapse = ";")
lst <- lapply(seq_len(nrow(res_nb$data)), function(i, x) as.list(transform(x[i, ], primary = fn(primary), secondary = NULL)), x = res_nb$data)

generate_geodata_neighbors <- function(x) {
    stopifnot(is.list(x), all(sapply(x, is.list)))
    res <- c("data <- list(")
    for (i in seq_along(x)) {
        msg <- sprintf("   list(name = \"%s\", continent = \"%s\", primary = \"%s\")",
                                   x[[i]]$name, x[[i]]$continent, x[[i]]$primary)
        msg <- paste0(msg, if (i == length(x)) "" else ",")
        res <- c(res, msg)
    }
    return(c(res, ")", "", "data_df <- x <- do.call(rbind, lapply(data, as.data.frame))", ""))
}
str_nb <- generate_geodata_neighbors(lst)
message(" - Writing into ", RFILE)
writeLines(str_nb, RFILE)
message(" - Done ...")
