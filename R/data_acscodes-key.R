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
#' @seealso \link{acscodes_age_sex_race}
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
#' @seealso \link{acscodes_age_sex_educ}
#'
#' @examples
#' head(acscodes_age_sex_race)
"acscodes_age_sex_race"


#' ACS code lookup table
#'
#' A tidy dataframe where each row is a ACS code. This is useful internal
#' data to give meaning to variable codes e.g. \link{acscodes_age_sex_educ}
#'
#' @format A data frame where each row represents a column.
#' \describe{
#'  \item{variable}{the ACS code (2018)}
#'  \item{gender}{A labelled variable for gender. 1 is Male, 2 is Female. Use
#'    the \code{labelled} or \code{haven} package to see labels.}
#'  \item{age}{A labelled variable specifying which age biin the variable specifies}
#'  \item{race}{A labelled variable specifying which education bin the variable specifies}
#'  \item{educ}{A labelled variable specifying which race binthe variable specifies}
#'  }
#'
#' @details The 5-yr ACS at 2018 is used,
#' although codes should be fairly consistent across time. IF a demographic variable is NA,
#' that means the variable collapses over the levels of that variable. In other
#' wods, NA here can be thought of as meaning "all".
#'
#' @source Modifications around tidycensus::load_variables
#'
#' @importFrom labelled labelled
#' @importFrom tibble tibble
#'
#'
#' @examples
#'  head(acscodes_df)
#'
"acscodes_df"
