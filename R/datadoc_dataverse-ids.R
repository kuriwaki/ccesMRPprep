#' Identifiers for datasets in CCES dataverse
#'
#' @format A tibble with one row per dataverse dataset
#'  \describe{
#'  \item{cces_name}{The unique name/shorthand for this dataset}
#'  \item{year}{Specific year the data surveys, if there is one unique year}
#'  \item{caseid_var}{The variable in that dataset that specifies
#'   the unique case (respondent/person) identifier. Use a string. }
#'  \item{doi}{The DOI for the dataverse dataset. The URL is therefore https://doi.org/[doi]}
#'  \item{filename}{The name of the data file, as it appears in the dataverse.}
#'  }
#'
#' @importFrom tibble tibble
#' @examples cces_dv_ids
"cces_dv_ids"
