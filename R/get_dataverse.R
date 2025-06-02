#' Download a specific CCES dataset from dataverse, with some indexing
#'
#' Wrapper function to get CCES/CES data from dataverse into the current R environment using the `dataverse` package.
#'
#'
#' @param name The name of the dataset as defined in \code{data(cces_dv_ids)}. e.g. `"cumulative"` or `"2018"`.
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
#' @details This function is a simple wrapper around the `dataverse` pacakge on CRAN.
#' It downloads the dataset from the dataverse, and loads it into a tibble with the appropriate
#' file data type.  Using \link{get_cces_question} does some standardization across years, for example,
#' the name of the case ID variable, so that it makes downstream.
#' As of v0.3.15, `dataverse` accepts a cache by default if you specify a dataverse version.
#' `get_cces_dataverse` does not specify a version and simplify re-downloads whatever
#' is the latest version of the dataset on dataverse at the time, it does not support caching.

#' You may be interested in customizing your download following  <https://cran.r-project.org/web/packages/dataverse/vignettes/C-download.html>,
#' or downloading the feather version of the CCES cumulative, which reads much
#' faster than the default .dta file in this function.
#'
#'
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
#' @seealso [ccc_std_demographics()] [cces_dv_ids]
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
                        year_subset = NULL,
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

  if (filetype == ".dta" & (yr %in% c(2009, 2022, 2024)))
    fun <- function(x) haven::read_dta(x, encoding = "latin1")

  if (filetype == ".sav")
    fun <- function(x) haven::read_sav(x, encoding = "latin1")

  if (filetype == ".Rds")
    fun <- readr::read_rds

  # read tempfile -----
  cces_raw <- get_dataframe_by_name(filename = glue("{y_info$filename}"),
                                    dataset = glue("doi:{doi}"),
                                    server = svr,
                                    original = TRUE,
                                    .f = fun)

  # subset ---
  if (name == "cumulative" & !is.null(year_subset)) {
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
