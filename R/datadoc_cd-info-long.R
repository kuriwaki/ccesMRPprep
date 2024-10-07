#' Congressional District level information - long version
#'
#' `cd_info_long` provides a "long" version of the yearly `cd_info_20**` datasets.
#'
#'
#' @format Each `cd_info_long*` is a dataframe with `r nrow(cd_info_long)`rows,
#'  covering the maps of `r length(unique(cd_info_long$map))` election years
#'  for each of the 435 congressional districts.
#'   \describe{
#'    \item{`map`}{Is the year corresponding to the geography. For example, `map = 2008` and `cd = "AL-01`
#'     indicates that the row is representing AL-01's geography as used in the 2008 election.}
#'    \item{`cd`}{Is the CD corresponding to the year of the map.}
#'    \item{`elec`}{Is the year of the election for the presidential election data that follows}
#'    \item{`party`, `candidate`}{Define the presidential candidate that corresponds to the `elec`
#'     (which may not be the same as `map`). For example, `map = 2012, cd = AL-01` combined with
#'      `elec = 2008` represents the 2008 election results in the AL-01 of the pre-redistricting 2008
#'      map.}
#'    \item{`pct`}{are the two party voteshares of the candidate}
#'    \item{`presvotes_total`}{Is the total number of votes for President in that CD}
#'    }
#'
#' @examples
#'  # get only data for proximate years
#'  cd_info_long |> filter((map == elec) | (elec + 2 == map))
#'
#'  # this subset returns exactly 2 * 435 districts per cycle:
#'  cd_info_long |> filter((map == elec) | (elec + 2 == map)) |> count(map, party)
#'
"cd_info_long"
