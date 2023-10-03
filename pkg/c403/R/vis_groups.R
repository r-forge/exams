#' Randomly Assign VIS Participants into Groups (as HTML Table)
#'
#' Randomly assign a vector of names (typically obtained from a VIS registration)
#' into groups and display the result as an HTML table.
#'
#' @param x character. Either a vector of names or a file name (csv or xls/xlsx from VIS)
#' from which the \code{Name} column can be extracted.
#' @param nrow,ncol numeric. Number of rows and columns into which the students should be assigned.
#' @param ... additional arguments passed to \code{\link{read_vis}} or \code{\link[utils]{read.csv2}}.
#'
#' @return A character vector with the HTML code is returned invisibly.
#'
#' @importFrom tools file_ext
#' @importFrom utils browseURL read.csv2
#' @aliases vis_groups
#' @keywords utilities
#' @export
vis_groups <- function(x, nrow = 5L, ncol = 2L, ...) {
  ## extract names
  if(is.character(x) && length(x) == 1L) {
    x <- if(file_ext(x) == "csv") read.csv2(x, colClasses = "character", ...) else read_vis(x, ...)
  }
  if(is.data.frame(x)) {
    if(!("Name" %in% names(x))) stop("no 'Name' column in data")
    x <- x$Name
  }
  if(!is.character(x)) x <- as.character(x)
  
  ## shuffle names
  x <- sample(x)
  
  ## split n participants into ngroups with nmembers
  n <- length(x)
  ngroups <- nrow * ncol
  nmembers <- rep.int(ceiling(n/ngroups), ngroups)
  nround <- sum(nmembers) - n
  nmembers[(ngroups - nround + 1):ngroups] <- nmembers[(ngroups - nround + 1):ngroups] - 1

  ## split up names
  y <- split(x, rep.int(1L:ngroups, nmembers))
  
  ## collapse names with HTML formatting
  z <- matrix(rep.int("", ngroups), nrow = ncol)
  z[1:ngroups] <- sprintf("<td>%s</td>", vapply(y, paste, "", collapse = "<br/>"))
  z <- t(z)
  z <- sapply(1L:nrow(z), function(i) sprintf('<tr class="%s"><td>%s</td>%s</tr>', if(i %% 2 > 0) "odd" else "even", i, paste(z[i, ], collapse = "")))
  
  ## column names
  colnames <- switch(ncol,
    "1" = "Gruppe",
    "2" = c("Links", "Rechts"),
    "3" = c("Links", "Mitte", "Rechts"),
    as.character(1:ncol))
  
  ## format as HTML table
  tab <- c(
    '<html>',
    '<head>',
    '<style type="text/css" rel="stylesheet">',
    'body{',
    '    font-family: Arial, Helvetica, Sans;',
    '}',
    '.table_shade {',
    '    border-collapse: collapse;',
    '    border-spacing: 0;',
    '    border:1px solid #FFFFFF;',
    '    background-color: #FFFFFF;',
    '}',
    '.table_shade th {',
    '    padding: 5px;',
    '    border: 2px solid #FFFFFF;',
    '    background: #CCCCCC;',
    '    text-align: left;',
    '}',
    '.table_shade td {',
    '    padding: 5px;',
    '    border: 2px solid #FFFFFF;',
    '    vertical-align: top;',
    '}',
    '.table_shade .odd {',
    '    background: #EEEEEE;',
    '}',
    '.table_shade .even {',
    '    background: #D4D4D4;',
    '}',
    '</style>',
    '</head>',
    '<body>',
    '<table class="table_shade">',
    '<thead>',
    sprintf('<tr class="header">%s</tr>', paste("<th>", c("Reihe", colnames), "</th>", sep = "", collapse = "")),
    '</thead>',
    '<tbody>',
    z,
    '</tbody>',
    '</table>',
    '</body>',
    '</html>'
  )

  ## display HTML
  dir.create(tmp <- tempfile())
  tmp <- file.path(tmp, "table.html")
  writeLines(tab, tmp)
  browseURL(normalizePath(tmp))

  ## return HTML invisibly
  invisible(tab)
}
