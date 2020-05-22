#' CCES-ACS variable recode keys
#'
#' These value-value tables are useful for recoding the values of
#' from one dataset (CCES) so that they can be merged immediately with another (ACS).
#'
#'
#' @format A tibble with one row per recoding value
#'  \describe{
#'  \item{race}{An labelled integer of class haven::labelled. Most compact form
#'  of all the data.}
#'  \item{race_chr, gender_chr, educ_chr}{Labels, in characters}
#'  \item{race_cces, edu_cces}{Corresponding labelled in the CCES cumulative common content}
#'  \item{race_acs}{Corresponding character in the ACS data via the tidycensus package}
#'  }
#'
"race_key"

#' @rdname  race_key
"gender_key"

#' @rdname  race_key
"educ_key"

#' @rdname  race_key
"age5_key"

#' @rdname  race_key
"age10_key"


#' @importFrom tibble tibble
