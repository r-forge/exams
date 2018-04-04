include_tikz <- function(tikz, name = "tikzpicture", format = NULL, library = NULL, width = NULL, ...)
{
  ## defaults
  if(is.null(format)) format <- "png"
  if(is.null(library)) library <- TRUE
  if(is.null(width)) width <- ""
  if(nchar(width) > 1L && substr(width, 1L, 1L) != "[") width <- sprintf("[width=%s]", width)
  
  ## add {tikzpicture} if necessary
  if(!(any(grepl("begin{tikzpicture}", tikz, fixed = TRUE)) &
       any(grepl("end{tikzpicture}", tikz, fixed = TRUE)))) {
    tikz <- c("\\begin{tikzpicture}", tikz, "\\end{tikzpicture}")
  }

  if(format == "tex") {
    writeLines(tikz)
  } else {
    ## call tex2image
    tex2image(tikz, name = name, dir = ".", format = format, tikz = library, show = FALSE, ...)
    writeLines(sprintf("\\includegraphics%s{%s}", width, paste(name, format, sep = ".")))
  }
}

if(FALSE) {

tz <- '
  \\node[left,draw, logic gate inputs=nn, xor gate US,fill=white,,scale=2.5] (G1) at (0,0) {};
  \\draw (G1.output) --++ (0.5,0) node[right] (y) {$y$};
  \\draw (G1.input 1) --++ (-0.5,0) node[left] {$x_1$};
  \\draw (G1.input 2) --++ (-0.5,0) node[left] {$x_2$};
'
include_tikz(tz, library = c("arrows", "shapes.gates.logic.US", "calc"))

}
