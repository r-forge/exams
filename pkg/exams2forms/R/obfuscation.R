

#' Encode/Decode (Obfuscate) Answer
#'
#' Takes the correct answer (or the obfuscated correct answer) and an
#' obfuscation key to "enfuscate/defuscate" (encode/decode) the correct answer
#' using a combination of xOR "encryption" and base64 encoding.
#'
#' @param x character, correct (obfuscated) answer (character of length 1).
#' @param key character, obfuscation key. Must be length with 1 or more characters.
#' @param encrypt logical, if `TRUE` (default) argument `x` is encoded,
#'        else it is decoded (for testing).
#'
#' @return Returns the obfuscated (or defuscated) answer.
obfuscate <- function(x, key, encrypt = TRUE) {
  # convert input string and key to raw bytes
  x_raw <- if (encrypt) charToRaw(x) else base64enc::base64decode(x)
  key_raw <- charToRaw(key)

  # repeat the key to match the length of the input
  key_repeated <- rep(key_raw, length.out = length(x_raw))

  # perform XOR operation (convert to integer, XOR, then back to raw)
  raw <- as.raw(bitwXor(as.integer(x_raw), as.integer(key_repeated)))

  if (encrypt) {
    res <- base64enc::base64encode(raw)
  } else {
    res <- rawToChar(raw)
  }
  return(res)
}
