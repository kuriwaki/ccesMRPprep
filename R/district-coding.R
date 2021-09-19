#' Concatenate to Congressional District code
#'
#'
#'@param state A vector of state names, preferably abbreviations
#'@param num A vector of district codes
#'
#'@importFrom stringr str_pad
#'@importFrom glue glue
#'
#' @examples
#'  to_cd(c("AL", "AK"), c("5", "AL"))
#'
#' @export
to_cd <- function(state, num) {

  if (is.character(num)) {
    num <- replace(num, num == "AL", "01")
    num <- as.numeric(num)
  }

  num <- replace(num, num == 0, "01") # at large becomes one
  numchr  <- str_pad(num, width = 2, pad = "0")

  glue("{state}-{numchr}")
}
