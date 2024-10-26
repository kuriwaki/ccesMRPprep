#' Congressional District level information by The Downballot
#'
#'
#' Some of the most consequential variables to include in MRP are measured at the
#' district-level. We include one such data for congressional districts. All data
#' is collected by The Downballot.
#'
#' @name cd_info
#' @details `cd_info_2008` is data on boundaries used in 2006, 2008, and 2010;
#' `cd_info_2012` is data on boundaries used in 2012 and 2014; `cd_info_2016`
#' uses 2016 boundaries; `cd_info_2018` is data on 2018 boundaries;
#' `cd_info_2020` uses 2020 boundaries; `cd_info_2022` is
#' data on 2022 boundaries; `cd_info_2024` uses 2024 boundaries.
#'
#' District lines change before and after each decennial Census, e.g. 2010 vs. 2012 and
#'  2020 vs. 2022. There is also change in district lines due to court interventions.
#'
#'  * Between the 2022 and 2024 data, 4 districts changed their
#'    districts: AL, GA, LA, and NC. In these changes, AL-02, GA-06, and LA-06 became
#'    a majority minority district; the NC state supreme court plan in 2022 expired; and
#'    the NY court struck down the initial 2022 NY plan.
#'   * Between the 2018 and 2020 data, NC changed their districts
#'   * Between the 2016 and 2018 data, PA changed their districts
#'   * Between the 2012-14 and 2016 data, FL, NC, VA changed their districts
#'
#' These can be seen by, for example, the following code:
#'   `cd_info_2022 |> left_join(cd_info_2024, by = "cd") |> select(cd, matches("trump")) |> mutate(diff = abs(pct_trump - pct_trump20))`
#'
#' @format Each `cd_info_20**` is a dataframe with the `r nrow(cd_info_2018)` Congressional
#'  Districts, one row per cd.
#'  \describe{
#'    \item{`year`}{The year for the district map. A congressional district's
#'    actual geography can change year to year. Lines represent the contemporaneous
#'    district geography,
#'    so that `cd_info_2016` uses 2016 maps and `cd_info_2020` uses 2020 maps.
#'    Corresponds to `line` in `cd_info_long`.
#'    This work relies on the hard work of assembling precinct results by Daily Kos.}
#'    \item{`cd`}{District code. The formatting corresponds to the CCES cumulative
#'    coding of \code{cd}: a two-letter abbreviation for the state followed by
#'    a dash, and the district number padded with zeros to the left to be of length
#'    2. At-large districts like Delaware are given a "-01" for the district number. See `to_cd()`}
#'    \item{`presvotes_total`}{In presidential years, the total number of votes cast for
#'     the office of President that year. }
#'    \item{`presvotes_DR`}{Same as `presvotes_total` but only the sum of Democratic and Republican candidate's votes}
#'    \item{`pct_trump`, `pct_romney`, `pct_mccain`}{The two-party voteshare of Republican
#'    presidential candidates in that district for the given year. E.g. the
#'    \code{pct_mccain} data for `cd_info_2018` represents the percent
#'    of the vote by McCain in 2008 for that district _under 2018 lines._\cr
#'    `pct_trump` denotes the 2016 election for `cd_info_2018` and `cd_info_2016`.\cr
#'    `pct_trump` denotes the 2020 election for `cd_info_2020`, `cd_info_2022`, and `cd_info_2024`.\cr
#'    `pct_trump16` denotes the 2016 result for `cd_info_2020`.}
#'    \item{`dailykos_name`}{The unique descriptive name for the district code in
#'    2018 given by Daily Kos (later renamed to The Downballot). Some edits are made for changing district. See
#'    Source for full citation.}
#'    \item{`largest_place`}{The largest place in the district code in 2018 given by Daily Kos. Multiple districts may
#'    have the same largest place.}
#'  }
#'
#' @seealso `cd_info_long`
#'
#' @source
#'   The Downballot (formerly Daily Kos Elections), \url{https://www.the-downballot.com/p/data}
#'
#'   The Daily Kos Elections naming guide to the nation's congressional districts.
#'   \url{https://bit.ly/2XsFI5W}
#'
#'   Daily Kos, "2008 results for districts used in **2006, 2008, 2010**"
#'   \url{https://bit.ly/4entUrV}
#'
#'   Kiernan Park-Egan, "U.S. Presidential Election Results by Congressional District, 1952 to 2020"
#'   \url{https://bit.ly/4fk6UKx} (used for 2008 values only when Daily Kos has missing data)
#'
#'   Daily Kos, "2008, 2012 results for districts used in **2012, 2014**"
#'   \url{https://bit.ly/3N4PDZK}
#'
#'   Daily Kos, "2008, 2012, & 2016 results for districts used in **2018**." \url{https://bit.ly/3bXtAPB}
#'
#'   Daily Kos, "2012, 2016 & 2020 presidential election results for congressional districts in **2020**", \url{https://bit.ly/3DRhPcj}
#'
#'   Daily Kos, 2020 presidential election results by later congressional districts:
#'
#'   * __2022__ congressional districts: \url{https://bit.ly/4gLYnBK}
#'   * __2024__ congressional districts: \url{https://bit.ly/47KTvZw}
#'
#'   Daily Kos, congressional district geography and most populous places:
#'
#'   * 119th Congress: \url{https://bit.ly/geography_119}\cr
#'   * 118th Congress: \url{https://bit.ly/geography_118}
#'
#'   Pennsylvania 2016 CD names are named by Shiro Kuriwaki and Lara Putnam.
#'
#'   Also see Cha, Kuriwaki, and Snyder, 2024,
#'    "Candidates in American General Elections", \url{https://doi.org/10.7910/DVN/DGDRDT},
#'    Harvard Dataverse, for congressional candidate's (instead of President's) vote totals.
#'
#'
#' @examples
#' head(cd_info_2018)
#' head(elec_NY)
NULL

#' @rdname cd_info
#' @format NULL
"cd_info_2008"

#' @rdname cd_info
#' @format NULL
"cd_info_2012"

#' @rdname cd_info
#' @format NULL
"cd_info_2016"

#' @rdname cd_info
#' @format NULL
"cd_info_2018"

#' @rdname cd_info
#' @format NULL
"cd_info_2020"

#' @rdname cd_info
#' @format NULL
"cd_info_2022"

#' @rdname cd_info
#' @format NULL
"cd_info_2024"

#' @rdname cd_info
#' @format NULL
"elec_NY"
