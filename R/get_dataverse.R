#' Download a specific CCES dataset from dataverse
#'
#' You must download the development version of https://github.com/IQSS/dataverse-client-r
#'  and get your own dataverse API Key. The current dataverse package downloads
#'  the raw data, so this function writes the raw binary into a tempfile and
#'  loads it into a tibble with the appropriate file data type.
#'
#'  To get a user key, you need to have your own dataverse account. Go to your account
#'  online and look for "API Token". Generate a API Token. You can then save your
#'  token by following \code{dataverse::get_user_key}, or directly saving
#'  \code{Sys.setenv("DATAVERSE_KEY" = "YOUR KEY HERE")}
#'  \code{Sys.setenv("DATAVERSE_SERVER" = "dataverse.harvard.edu")}
#'
#'
#'
#' @param name The name of the dataset as defined in \code{data(cces_dv_ids)}.
#' @param year_subset The year (or years, a vector) to subset too. If `name` is a year specific dataset, this
#' argument is redundant, but if `name == "cumulative"`, then the output
#' will be the cumulative dataset subsetted to that year. This is useful when
#' using the cumulative dataset for its harmonized variables.
#' @param dataverse_paths A dataframe where one row represents metadata for one
#' CCES dataset. Built-in data \code{cces_dv_ids} is used as a default and should
#' not be changed.
#'
#' @importFrom glue glue
#' @importFrom stringr str_extract
#' @importFrom haven read_dta read_sav
#' @importFrom readr read_rds
#' @importFrom dplyr filter
#' @importFrom dataverse get_file
#'
#' @examples
#'
#' \dontrun{
#'  ccc <- get_cces_dv("cumulative", year = 2018)
#'  }
#'
#' @export
#'
#'
get_cces_dv <- function(name = "cumulative",
                        year_subset = 2006:2019,
                        dataverse_paths = cces_dv_ids) {

  y_info <- filter(dataverse_paths, cces_name == as.character(name))
  filetype <- str_extract(y_info$filename, "\\.[A-z]+$")

  if (filetype == ".tab")
    filetype <- ".dta"

  cces_dv <- get_file(glue("{y_info$filename}"), glue("doi:{y_info$doi}"))
  tmp <- tempfile(fileext = filetype)
  writeBin(cces_dv, tmp)

  # read select columns ---
  if (filetype == ".dta")
    cces_raw <- haven::read_dta(tmp)

  if (filetype == ".sav")
    cces_raw <- haven::read_sav(tmp)

  if (filetype == ".Rds")
    cces_raw <- readr::read_rds(tmp)

  if (name == "cumulative") {
    cces_raw <- filter(cces_raw, year %in% year_subset)
  }
  return(cces_raw)
}