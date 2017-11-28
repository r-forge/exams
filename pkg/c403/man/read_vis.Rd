\name{read_vis}
\alias{read_vis}
\alias{vis_register}

\title{Reading VIS Registrations}

\description{
  Read registration lists (for exams or courses) from the Excel export
  of VIS (which actually may or may not be XLS or HTML files).
}

\usage{
  read_vis(file, \dots)

  vis_register(file = Sys.glob("*.xls"), subset = TRUE)
}

\arguments{
  \item{file}{character with file name of an XLS file from VIS.}
  \item{\dots, subset}{logical. Should students without confirmed registration be omitted?}
}

\details{
  VIS offers Excel exports but in case of registration lists these are
  typically HTML files containing an HTML table. These are read using the XML
  package. However, some exports are actually Excel files which are read
  using the xlsx package. In either case some basic cleaning is done and
  additional meta-information is extracted.
}

\value{
  A \code{data.frame} with an additional attribute \code{"info"} providing
  details about the type of course (\code{"LV"}) or exam (\code{"GP"}).
}

\keyword{utilities}
