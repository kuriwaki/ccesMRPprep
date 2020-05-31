#' Download a specific CCES dataset from dataverse
#'
#' The current dataverse package downloads
#'  the raw data, so this function writes the raw binary into a tempfile and
#'  loads it into a tibble with the appropriate file data type.
#' You must download the development version of
#' [IQSS/dataverse-client-r](https://github.com/IQSS/dataverse-client-r).
#'
#'
#' @param name The name of the dataset as defined in \code{data(cces_dv_ids)}.
#' @param year_subset The year (or years, a vector) to subset too. If `name` is a year
#' specific dataset, this argument is redundant, but if `name == "cumulative"`, then
#' the output will be the cumulative dataset subsetted to that year. This is useful
#' when using the cumulative dataset for its harmonized variables.
#' @param dataverse_paths A dataframe where one row represents metadata for one
#' CCES dataset. Built-in data \link{cces_dv_ids} is used as a default and should
#' not be changed.
#'
#' @details We find it convenient to loop over this function for all values in
#' \link{cces_dv_ids} and populate the MRP directory with all datasets (about 2GB
#' in total). Each dataset has slightly different formats; using \link{get_cces_question}
#' will standardize, for example, the name of the case ID.
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
  svr <- y_info$server


  cces_dv <- get_file(file = glue("{y_info$filename}"),
                      dataset = glue("doi:{y_info$doi}"),
                      server = svr)
  tmp <- tempfile(fileext = filetype)
  writeBin(cces_dv, tmp)

  # read data  into df ---
  if (filetype == ".tab")
    filetype <- ".dta"

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
