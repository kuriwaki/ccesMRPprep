#' Concatenate to Congressional District code
#'
#'
#'@param state A vector of state names, preferably abbreviations.
#' If it is numeric, the function will assume they are FIPS codes
#' and translate them accordingly. If they have full names like "California"
#' instead of "CA", it will trnslate that too.
#'@param num A vector of district codes
#'
#'@importFrom stringr str_pad
#'@importFrom dplyr recode
#'@importFrom tibble deframe
#'@importFrom glue glue
#'
#' @examples
#' library(dplyr)
#'
#'  to_cd(c("AL", "AK"), c("5", "AL"))
#'  to_cd(c(1, 2), c("5", "AL"))
#'  to_cd(c("Alabama", "Alaska"), c("5", "AL"))
#'
#'  transmute(cc18_samp,
#'            inputstate,
#'            cdid115,
#'            cd = to_cd(inputstate, cdid115))
#'
#' @export
to_cd <- function(state, num) {

  # State
  if (inherits(state, "haven_labelled") | is.numeric(state)) {
    fips_to_st <- deframe(select(states_key, st_fips, st))
    state <- recode(as.numeric(state), !!!fips_to_st)
  }

  if (all(state %in% c(states_key$state))) {
    state_to_st <- deframe(select(states_key, state, st))
    state <- recode(state, !!!state_to_st)
  }

  if (is.character(num)) {
    num <- replace(num, num == "AL", "01")
    num <- as.numeric(num)
  }

  # number coding
  num <- replace(num, num == 0, "01") # at large becomes one
  numchr  <- str_pad(num, width = 2, pad = "0")

  as.character(glue("{state}-{numchr}"))
}
