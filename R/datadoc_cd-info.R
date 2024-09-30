#' Congressional District level information by The Downballot (formerly Daily Kos)
#'
#'
#' Some of the most consequential variables to include in MRP are at the
#' district-level. We include one such data for congressional districts. All data
#' is collected by The Downballot `cd_info_2018` is data on 2018 boundaries, `cd_info_2016`
#' uses 2016 boundaries and `cd_info_2020` uses 2020 (but with place descriptions
#' currently at 2016).  `cd_info_2022` is data on 2022 boundaries; `cd_info_2024`
#' uses 2024 boundaries.
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
#'    \code{pct_mccain} data for `cd_info_2018` represents the percent
#'    of the vote by McCain in 2008 for that district _under 2018 lines._\cr
#'    `pct_trump` denotes the 2016 election for `cd_info_2018` and `cd_info_2016`.\cr
#'    `pct_trump` denotes the 2020 election for `cd_info_2020`, `cd_info_2022`, and `cd_info_2024`.\cr
#'    `pct_trump16` denotes the 2016 result for `cd_info_2020`.}
#'    \item{dailykos_name}{The unique descriptive name for the district code in
#'    2018 given by Daily Kos (later renamed to The Downballot). Some edits are made for changing district. See
#'    Source for full citation.}
#'    \item{largest_place}{The largest place in the district code in 2018 given by Daily Kos. Multiple districts may
#'    have the same largest place.}
#'  }
#'
#'
#' @source
#'   The Downballot (formerly Daily Kos Elections), \url{https://www.the-downballot.com/p/data}
#'
#'   The Daily Kos Elections naming guide to the nation's congressional districts.
#'   \url{https://bit.ly/2XsFI5W}
#'
#'   Daily Kos, "2008, 2012, & 2016 results for districts used in 2018."
#'   \url{https://bit.ly/3bXtAPB}
#'
#'   Daily Kos, "2012, 2016 & 2020 presidential election results for congressional districts in 2020"
#'   \url{https://bit.ly/3DRhPcj}
#'
#'   Daily Kos, 2020 presidential election results by later congressional districts:\cr
#'   2022 congressional districts: \url{https://bit.ly/4gLYnBK}\cr
#'   2024 congressional districts: \url{https://bit.ly/47KTvZw}
#'
#'   Daily Kos, congressional district geography and most populous places: \cr
#'   119th Congress: \url{https://bit.ly/geography_119}\cr
#'   118th Congress: \url{https://bit.ly/geography_118}
#'
#'   Daily Kos, "2008 results for districts used in 2006, 2008, 2010"
#'   \url{https://bit.ly/4entUrV}
#'
#'   Daily Kos, "2008, 2012 results for districts used in 2012, 2014"
#'   \url{https://bit.ly/3N4PDZK}
#'
#'   Pennsylvania 2016 CD names are named by Shiro Kuriwaki and Lara Putnam.
#'
#'   Also see Cha, Jeremiah; Kuriwaki, Shiro; Snyder, James M. Jr., 2021,
#'    "Candidates in American General Elections", https://doi.org/10.7910/DVN/DGDRDT,
#'    Harvard Dataverse.
#'
#'
#' @examples
#' head(cd_info_2018)
#' head(elec_NY)
"cd_info_2018"

#' @rdname cd_info_2018
"cd_info_2006"

#' @rdname cd_info_2018
"cd_info_2012"

#' @rdname cd_info_2018
"cd_info_2016"

#' @rdname cd_info_2018
"cd_info_2020"

#' @rdname cd_info_2018
"cd_info_2022"

#' @rdname cd_info_2018
"cd_info_2024"

#' @rdname cd_info_2018
"elec_NY"
