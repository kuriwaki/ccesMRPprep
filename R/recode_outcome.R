#' Translate a Yes/No variable into 1/0
#'
#' Operationalizes outcomes of type yes/no to binary variables. It is internally
#' given the values to count as a "Yes" by regular expression, e.g. not only "Yes"
#' but also "Support" and "For"
#'
#' @param vec A vector of CCES response values, in character
#'
#' @return A vector of integers
#'
#' @importFrom stringr str_detect
#'
#' @examples
#'  yesno_to_binary(
#'   c("Yes",
#'     "No",
#'     "Support",
#'     "Oppose",
#'     "Somewhat support",
#'     "Somewhat oppose",
#'     "For this bill",
#'     "Against this bill",
#'     NA_character_)
#' )
#' @export
yesno_to_binary <- function(vec) {
  as.integer(vec %in% c("For", "for", "Support", "support",  "yes", "Yes") |
               str_detect(vec, "For this bill"))
}
