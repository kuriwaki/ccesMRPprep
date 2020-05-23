#' CCES-ACS variable recode keys
#'
#' @details These value-value tables are useful for recoding the values of
#' from one dataset (CCES) so that they can be merged immediately with another
#' (ACS). These get used internally in \link{ccc_std_demographics}, but they are
#' available as built in datasets
#'
#'
#' @format A tibble with one row per recoding value
#'  \describe{
#'  \item{race, educ, gender}{An labelled integer of class haven::labelled.
#'     Most compact form of both sources and the values both will get recoded
#'     to in MRP.}
#'  \item{race_chr, gender_chr, educ_chr}{Labels for the first column, in characters}
#'  \item{race_cces_chr, edu_cces_chr}{Corresponding labelled in the CCES cumulative
#'        common content}
#'  \item{race_acs}{Corresponding character in the ACS data via the tidycensus package}
#'  }
#'
#'
#' @examples
#'  library(ccesMRPprep)
#'  educ_key
#'  race_key
#'
#'
#'
"race_key"

#' @rdname  race_key
"gender_key"

#' @rdname  race_key
"educ_key"

#' @rdname  race_key
"educ_key2"

#' @rdname  race_key
"age5_key"

#' @rdname  race_key
"age10_key"


#' @importFrom tibble tibble
