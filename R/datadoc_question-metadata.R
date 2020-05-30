#' Question metadata (sample)
#'
#'
#' @format A tibble with `r nrow(questions_samp)` rows, each row corresponding
#' to a variable (column) in a particular CCES dataset. It contains metadata about
#' the question in columns.
#'
#' \describe{
#' \item{q_ID}{A unique identifier for the question. This is roughly a concatenation
#'  of \code{cces_year} and \code{q_code}, with some standardization.}
#' \item{q_label}{A short descriptive label of the question, based on a reading of the
#'  actual question wording.}
#' \item{cces_data}{The dataset the variable column comes from. Because the CCES is fielded
#' each year, this is often a year, with the exception of \code{"cumulative"}}
#' \item{q_code}{A string of the variable as it appears in the dataset.}
#' \item{response_type}{A classification of the response option. Currently it consists
#'  of \code{"yesno"}, \code{"categorical"} (discrete but not ordered), \code{"ordinal"}
#'  (discrete and ordered). All of these presume a discrete response.}
#' }
#'
#' @importFrom tibble tibble
#'
#' @examples
#'  questions_samp
#'
"questions_samp"
