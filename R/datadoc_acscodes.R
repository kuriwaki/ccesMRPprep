#' ACS codes for partitions
#'
#' Each vector defines a partition, or at least an attempt at one. Each element of
#' the vector is a code for a ACS variable, which can be used,
#' for example in the \code{variables} argument of \code{tidycensus::get_acs()}. Some of
#' these will be collapsed for MRP to form a common denominator with the CCES; see
#' \link{keyvalue}.
#'
#' @name acscodes_partitions
#'
#' @seealso \link{acscodes_df} for a definition of all codes,
#' and the [Vignette on ACS value pairs](https://www.shirokuriwaki.com/ccesMRPprep/articles/acs.html).
#'
#'
#' @examples
#' head(acscodes_age_sex_race)
#' head(acscodes_age_sex_educ)
#' head(acscodes_sex_educ_race)
NULL

#' @rdname acscodes_partitions
#'
#' @format ### acscodes_age_sex_race
#'
#' There are `r length(acscodes_age_sex_race)` codes in \code{acscodes_age_sex_race} because they specify cells
#' interacting age (10 bins), sex (2 bins), and race/ethnicity (8 bins).
#'
"acscodes_age_sex_race"


#' @rdname acscodes_partitions
#'
#'
#' @format ### acscodes_age_sex_educ
#'
#' There are `r length(acscodes_age_sex_educ)` codes in \code{acscodes_age_sex_educ} because they specify cells
#' interacting age (5 bins), sex (2 bins), and education (7 bins).
#'
"acscodes_age_sex_educ"

#' @rdname acscodes_partitions
#'
#'
#' @format ### acscodes_sex_educ_race
#'
#' There are `r length(acscodes_sex_educ_race)` codes in \code{acscodes_sex_educ_race} because they specify cells
#' interacting sex (2 bins), education (3 bins), and race (8 bins). The entire partition
#' is not actually exhaustive; it appears to only limit to 25 years and above
#' and not include postgraduate degrees. Cross-check with \link{acscodes_df} to verify.
#'
"acscodes_sex_educ_race"


#' ACS code lookup table
#'
#' A tidy dataframe where each row is a ACS code. This is useful internal
#' data to give meaning to variable codes e.g. \link{acscodes_age_sex_educ}
#'
#' @format A data frame with `r format(nrow(acscodes_df), big.mark = ',')` rows where
#' each row represents a variable in the ACS for which there is a count (e.g.
#' 18-24 year olds who identify as Hispanic).
#'
#' \describe{
#'  \item{variable}{the ACS code (2018)}
#'  \item{gender}{A labelled variable for gender. 1 is Male, 2 is Female. Use
#'    the \code{labelled} or \code{haven} package to see labels.}
#'  \item{age}{A labelled variable specifying which age bin the variable specifies}
#'  \item{race}{A labelled variable specifying which education bin the variable specifies}
#'  \item{educ}{A labelled variable specifying which race bin the variable specifies}
#'  }
#'
#' @details The 5-yr ACS at 2018 is used,
#' although codes should be fairly consistent across time. IF a demographic variable is \code{NA},
#' that means the variable collapses over the levels of that variable. In other
#' words, \code{NA} here can be thought of as meaning "all".
#'
#' @source Modifications around `tidycensus::load_variables`
#'
#' @importFrom haven labelled
#' @importFrom tibble tibble
#'
#'
#' @examples
#'  head(acscodes_df)
#'
"acscodes_df"
