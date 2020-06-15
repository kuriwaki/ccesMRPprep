#' Translate a Yes/No variable into 1/0
#'
#' Operationalizes outcomes of type yes/no to binary variables. It is internally
#' given the values to count as a "Yes" by regular expression, e.g. not only "Yes"
#' but also "Support" and "For"
#'
#' @param vec A vector of CCES response values, in character
#' @param DK_to_NA Whether don't knows should be treated as NA. Defaults to TRUE.
#'
#' @return A vector of integers
#'
#' @importFrom stringr regex str_detect str_replace_all
#' @importFrom dplyr recode
#' @importFrom magrittr `%>%`
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
#'     "Not sure",
#'     "Don't Know",
#'     NA_character_)
#' )
#' @export
yesno_to_binary <- function(vec, DK_to_NA = TRUE) {

  # Yes
  vec_char <- as.character(vec) %>%
    replace(str_detect(., regex("^Against", ignore_case = TRUE)), "Against") %>%
    replace(str_detect(., regex("^For", ignore_case = TRUE)), "For") %>%
    str_replace_all(regex("somewhat\\s+", ignore_case = TRUE), "") %>%
    replace(. %in% c("Against", "Oppose", "oppose", "against", "no", "No"), "N") %>%
    replace(. %in% c("For", "for", "Support", "support",  "yes", "Yes"), "Y") %>%
    replace(. %in% c("Don't Know", "Don't know", "dk", "don't know",  "Not Sure", "not sure", "not sure "), "DK") %>%
    replace(. %in% c("Not Asked", "Skipped", "skipped"), NA)

  recode(vec_char, Y = 1, N = 0, DK = ifelse(DK_to_NA, NA_real_, 0), .default = NA_real_)
}
