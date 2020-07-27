#' CPS variable labels and counts
#'
#' One summary of the CPS, by reporting all year-by-year raw counts of the microdata
#' for main demographic variables. In other words, it tabulates all the unique
#' values of each main variable, and shows its sample size.
#
#'
#' @seealso The [Vignette on CPS](https://www.shirokuriwaki.com/ccesMRPprep/articles/cps.html).
#'
#' \describe{
#'  \item{variable}{Name of the variable, as it appears in the CPS extract}
#'  \item{year}{Year of the November supplement}
#'  \item{name}{Name (or label) of the value in the November supplement}
#'  \item{value}{The integer value of the value in the value. The name and value
#'   together form the labelled class. See the `vignette("derived")` vignette.}
#'  \item{n}{Number of raw observations (sample size) in the November supplement
#'   of the CPS.}
#' }
#'
#'
#' @examples
#' head(cps_onewaytabs)
"cps_onewaytabs"
