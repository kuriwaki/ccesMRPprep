#' Congressional District level information by Daily Kos
#'
#'
#' Some of the most consequential variables to include in MRP are at the
#' district-level. We include one such data for congressional districts. All data
#' is collected by Daily Kos. `cd_info_2018` is data on 2018 boundaries, `cd_info_2016`
#' uses 2016 boundaries and `cd_info_2020` uses 2020 (but with place descriptions
#' currently at 2016).
#'
#' @format Each `cd_info_20**` is a dataframe with the `r nrow(cd_info_2018)` Congressional
#'  Districts, one row per cd.
#'  \describe{
#'    \item{year}{The year for the district line. A congressional district's
#'    actual geography can change year to year, and significantly so in different
#'    redistricting cycles. Lines try to get the contemporaneous district map,
#'    so that cd_info_2016 uses 2016 maps and cd_info_2020 uses 2020 maps.
#'    However, this work relies on the hard work of assembling precinct results by Daily Kos.}
#'    \item{cd}{District code. The formatting corresponds to the CCES cumulative
#'    coding of \code{cd}: a two-letter abbreviation for the state followed by
#'    a dash, and the district number padded with zeros to the left to be of length
#'    2. At-large districts like Delaware are given a "-01" for the district number.}
#'    \item{presvotes_total}{In presidential years, the total number of votes cast for
#'     the office of President that year. Taken from Daily Kos estimates from precinct results.}
#'    \item{pct_trump, pct_romney, pct_mccain}{The two-party voteshare of Republican
#'    presidential candidates in that district for the given year. E.g. the
#'    \code{pct_mccain} data when \code{cd_year == 2018} represents the percent
#'    of the vote by McCain in 2008 for that district _under 2018 lines._
#'    The Trump value is for 2016 for `cd_info_2018` and ``cd_info_2020` but not
#'    for 2020 where we use Trump's 2020 vote against Biden and denote as
#'    `pct_trump16` the 2016 result.}
#'    \item{dailykos_name}{The unique descriptive name for the district code in
#'    2018 given by Daily Kos. Some edits are made for changing district. See
#'    Source for full citation.}
#'    \item{largest_place}{The largest place in the district code in 2018 given by Daily Kos. Multiple districts may
#'    have the same largest place.}
#'  }
#'
#'
#' @source
#'   The Daily Kos Elections naming guide to the nation's congressional districts.
#'   \url{https://bit.ly/2XsFI5W}
#'
#'   Daily Kos, "2008, 2012, & 2016 results for districts used in 2018."
#'   \url{https://bit.ly/3DRhPcj}

#'   DailyDaily Kos Elections 2012, 2016 & 2020 presidential election results for congressional districts in 2020"
#'   \url{https://bit.ly/3bXtAPB}
#'
#'   Pennsylvania 2016 CD names are named by Shiro Kuriwaki and Lara Putnam.
#'
#'   Also see Cha, Jeremiah; Kuriwaki, Shiro; Snyder, James M. Jr., 2021,
#'    "Candidates in American General Elections", https://doi.org/10.7910/DVN/DGDRDT,
#'    Harvard Dataverse.
#'
#' @importFrom tibble tibble
#'
#' @examples
#' head(cd_info_2018)
#' head(elec_NY)
"cd_info_2018"


#' @rdname cd_info_2018
"cd_info_2016"

#' @rdname cd_info_2018
"cd_info_2020"

#' @rdname cd_info_2018
"elec_NY"
