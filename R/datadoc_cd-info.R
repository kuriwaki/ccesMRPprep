#' Sample district level data
#'
#'
#' Some of the most consequential variables to include in MRP are at the
#' district-level. We include one such data for congressional districts. All data
#' is collected by Daily Kos.
#'
#' @format A dataframe with the `r nrow(cd_info_2018)` Congressional Districts, one row per cd.
#'  \describe{
#'    \item{cd_year}{The year for the district line. A congressional district's
#'    actual geography can change year to year, and significantly so in different
#'    redistricting cycles. 2019 indicates the data about voteshare and place names
#'    corresponds to district lines as of 2019.}
#'    \item{cd}{District code. The formatting corresponds to the CCES cumulative
#'    coding of \code{cd}: a two-letter abbreviation for the state followed by
#'    a dash, and the district number padded with zeros to the left to be of length
#'    2. At-large districts like Delaware are given a "-01" for the district number.}
#'    \item{pct_trump, pct_romney, pct_mccain}{The voteshare of presidential candidates
#'    in that district for the given year. E.g. the pct_mccain data when \code{cd_year == 2018}
#'    represents the percent of the vote by McCain in 2008 for that district _under 2018 lines._}
#'    \item{dailykos_name}{The unique descriptive name for the district given by Daily Kos.
#'    See Source}
#'    \item{largest_place}{The largest place in the district. Multiple districts may
#'    have the largest place.}
#'  }
#'
#'
#' @source
#'   The Daily Kos Elections naming guide to the nation's congressional districts.
#'   <https://bit.ly/2XsFI5W>
#'
#'   Daily Kos, "2008, 2012, & 2016 results for districts used in 2018."
#'    <https://bit.ly/3bXtAPB>
#'
#'
#' @importFrom tibble tibble
#'
#' @examples
#' head(cd_info_2018)
"cd_info_2018"
