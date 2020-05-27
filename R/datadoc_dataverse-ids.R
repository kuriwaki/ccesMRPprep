#' Identifiers for datasets in CCES dataverse
#'
#' @format A tibble with one row per dataverse dataset. The \code{doi},
#' \code{filename}, and \code{server} can uniquely define a file in
#' \link{dataverse::get_file}.
#'  \describe{
#'  \item{cces_name}{The unique name/shorthand for this dataset}
#'  \item{year}{Specific year the data surveys, if there is one unique year}
#'  \item{doi}{The DOI for the dataverse dataset (instead of the specific file). The URL is therefore https://doi.org/
#'  followed by the DOI}
#'  \item{filename}{The name of the data file, as it appears in the dataverse.}
#'  \item{server}{The particular dataverse instance.}
#'  \item{caseid_var}{The variable in that dataset that specifies
#'   the unique case (respondent/person) identifier. Use a string. }
#'  }
#'
#' @importFrom tibble tibble
#' @examples
#'  cces_dv_ids
"cces_dv_ids"
