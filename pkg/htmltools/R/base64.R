b64decode <- function(input, output = tempfile()) {
  invisible(.Call("decode_", input, output, PACKAGE = "htmltools"))
}

b64encode <- function(input, output = tempfile(), linesize = 72L) {
  invisible(.Call("encode_", input, output, as.integer(linesize), PACKAGE = "htmltools"))
}

b64img <- function(file, Rd = FALSE, alt = file){
  tf <- tempfile()
  on.exit(unlink(tf))
  b64encode(file, tf)
  sprintf('%s<img src="data:image/png;base64,\n%s" alt="%s" />%s', 
    if(Rd) "\\out{" else "", 
    paste(readLines(tf), collapse = "\n"),
    alt,
    if(Rd) "}" else ""
  )
}
