#' ACS codes for a age-sex-education partition
#'
#'
#' @details Each element of the vector is a code for a ACS variable, which can be used
#' for example  in the \code{variables} argument of \code{tidycensus::get_acs()}.
#' There are 70 codes in \code{acscodes_age_sex_edu} because they specify cells
#' interacting age (5 bins), sex (2 bins), and education (7 bins). Some of
#' these will be collapsed for MRP to form a common denominator with the CCES; see
#' \link{educ_key}
#'
#' @seealso \link{acscodes_age_sex_rac}
#'
#' @examples
#' head(acscodes_age_sex_educ)
"acscodes_age_sex_educ"


#' ACS codes for a age-sex-race partition
#'
#'
#' @details Each element of the vector is a code for a ACS variable, which can be used,
#' for example  in the \code{variables} argument of \code{tidycensus::get_acs()}.
#' There are 160 codes in \code{acscodes_age_sex_rac} because they specify cells
#' interacting age (10 bins), sex (2 bins), and race/ethnicity (8 bins).  Some of
#' these will be collapsed for MRP to form a common denominator with the CCES; see
#' \link{race_key}
#'
#' @seealso \link{acscodes_age_sex_edu}
#'
#' @examples
#' head(acscodes_age_sex_race)
"acscodes_age_sex_race"
