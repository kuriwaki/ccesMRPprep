#' Download a specific CCES dataset from dataverse, with some indexing
#'
#' Get the data from dataverse into the current R environment. You must use
#' the development version of [IQSS/dataverse-client-r](https://github.com/IQSS/dataverse-client-r).
#' The function also does
#'
#'
#' @param name The name of the dataset as defined in \code{data(cces_dv_ids)}.
#' @param year_subset The year (or years, a vector) to subset too. If `name` is a year
#' specific dataset, this argument is redundant, but if `name == "cumulative"`, then
#' the output will be the cumulative dataset subsetted to that year. This is useful
#' when using the cumulative dataset for its harmonized variables.
#' @param std_index Whether to standardize the unique case identifier. These
#' have different column names in different datasets, but setting this to \code{TRUE}
#' (the default) will all rename them \code{"case_id"} and also add the year of the dataset.
#' This way, every dataset that gets downloaded will have the unique identifier
#' defined by the variables \code{c("year", "case_id")}.
#' @param dataverse_paths A dataframe where one row represents metadata for one
#' CCES dataset. Built-in data \link{cces_dv_ids} is used as a default and should
#' not be changed.
#'
#' @details The current dataverse package downloads the raw data, so this function writes
#' the raw binary into a tempfile and loads it into a tibble with the appropriate
#' file data type. We find it convenient to loop over this function for all values in
#' \link{cces_dv_ids} and populate the MRP directory with all datasets (about 2GB
#' in total). Each dataset has slightly different formats; using \link{get_cces_question}
#' will standardize, for example, the name of the case ID.
#'
#' @importFrom glue glue
#' @importFrom stringr str_extract
#' @importFrom haven read_dta read_sav
#' @importFrom readr read_rds
#' @importFrom dplyr select rename everything filter
#' @importFrom tibble add_column
#' @importFrom magrittr `%>%`
#' @importFrom rlang sym `!!` .data
#' @importFrom dataverse get_file get_dataframe_by_name
#'
#' @examples
#'
#' # read in cumulative common content, subsetted to 2018, into environemt
#' \dontrun{
#'  ccc <- get_cces_dataverse("cumulative", year_subset = 2018)
#'  }
#'
#' # Example code to read _and_ write a series of common content datasets
#' # in a directory "data/input/cces/
#' \dontrun{
#' dir_create("data/cces")
#' for (d in c("cumulative", "2018")) {
#' if (file_exists(glue("data/input/cces/cces_{d}.rds")))
#'     next
#'   write_rds(get_cces_dataverse(d), glue("data/input/cces/cces_{d}.rds")) # takes a few minutes
#' }
#' }
#'
#' @export
#'
#'
get_cces_dataverse <- function(name = "cumulative",
                        year_subset = 2006:2019,
                        std_index = TRUE,
                        dataverse_paths = ccesMRPprep::cces_dv_ids) {

  y_info <- filter(dataverse_paths, .data$cces_name == as.character(name))
  filetype <- str_extract(y_info$filename, "\\.[A-z]+$")
  svr <- y_info$server
  caseid_var <- y_info$caseid_var
  yr <- y_info$year
  doi <- y_info$doi


  # warning
  if (yr %% 2 == 0 | doi == "10.7910/DVN/II2DB6")
    cat("Downloading and reading large dataset, can take about 3-5 minutes to complete.", "\n")


  # set function ---
  if (filetype == ".tab" | filetype == ".dta")
    fun <- haven::read_dta

  if (filetype == ".dta" & isTRUE(yr == 2009))
    fun <- function(x) haven::read_dta(x, encoding = "latin1")

  if (filetype == ".sav")
    fun <- function(x) haven::read_sav(x, encoding = "latin1")

  if (filetype == ".Rds")
    fun <- readr::read_rds

  # read tempfile -----
  cces_raw <- get_dataframe_by_name(file = glue("{y_info$filename}"),
                                    dataset = glue("doi:{doi}"),
                                    server = svr,
                                    original = TRUE,
                                    .f = fun)

  # subset ---
  if (name == "cumulative") {
    cces_raw <- filter(cces_raw, .data$year %in% year_subset)
  }

  # rename indexing variables ----
  if (std_index) {
    cces <- cces_raw %>%
      rename(case_id = !!sym(caseid_var)) %>%
      select(.data$case_id, everything())

    if (!is.na(y_info$year))
      cces <- add_column(cces, year = yr, .before = 1)
  } else {
    cces <- cces_raw
  }

  return(cces)
}
