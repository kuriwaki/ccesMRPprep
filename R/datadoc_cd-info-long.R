#' Congressional District level information - long version
#'
#' `cd_info_long` provides a "long" version of the yearly `cd_info_20**` datasets.
#'
#'
#' @format `cd_info_long` is a dataframe with `r nrow(cd_info_long)` rows,
#'  covering the maps of `r length(unique(cd_info_long$lines))` election years
#'  for each of the 435 congressional districts.
#'   \describe{
#'    \item{`lines`}{Is the year corresponding to the geography. For example, `lines = 2008` and `cd = "AL-01`
#'     indicates that the row is representing AL-01's geography as used in the 2008 election.}
#'    \item{`cd`}{Is the CD corresponding to the year of the lines.}
#'    \item{`elec`}{Is the year of the election for the presidential election data that follows}
#'    \item{`party`, `candidate`}{Define the presidential candidate that corresponds to the `elec`
#'     (which may not be the same as `lines`). For example, `lines = 2012, cd = AL-01` combined with
#'      `elec = 2008` represents the 2008 election results in the AL-01 of the pre-redistricting 2008
#'      lines.}
#'    \item{`pct`}{are the two party voteshares of the candidate}
#'    \item{`presvotes_total`}{Is the total number of votes for President in that CD}
#'    }
#'
#' @examples
#'  library(dplyr)
#'
#'  # get only data for proximate years
#'  cd_info_long |> filter((elec == lines) | (elec + 2 == lines))
#'
#'  # this subset returns exactly 2 * 435 districts per cycle:
#'  cd_info_long |> filter((elec == lines) | (elec + 2 == lines)) |> count(lines, party)
#'
#' # this will show where the districts lines changed between 2022 and 2024
#' # (same election, same candidate, different map)
#' cd_info_long |>
#'  filter(lines %in% c(2022, 2024), elec == 2020, candidate == "biden") |>
#'  arrange(cd, lines)
#'
"cd_info_long"
