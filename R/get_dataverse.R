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
#' @param ver Version of the Dataverse dataset to extract. Use \code{":latest"}
#'  for the latest released version, or a concrete version such as \code{"9.0"}
#'  for reproducibility. \code{":draft"} is not supported.
#' @param cache Logical, whether to cache downloaded files on disk. The default,
#'  \code{TRUE}, resolves \code{":latest"} to the current released version number
#'  before downloading, which allows the \code{dataverse} package to use its disk
#'  cache. Set to \code{FALSE} to re-download.
#' @param dataverse_paths A dataframe where one row represents metadata for one
#' CCES dataset. Built-in data \link{cces_dv_ids} is used as a default and should
#' not be changed.
#'
#' @details This function is a simple wrapper around the `dataverse` pacakge on CRAN.
#' It downloads the dataset from the dataverse, and loads it into a tibble with the appropriate
#' file data type.  Using \link{get_cces_question} does some standardization across years, for example,
#' the name of the case ID variable, so that it makes downstream.
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
#' @importFrom dataverse get_dataframe_by_name get_file_by_name dataset_versions
#' @importFrom cli cli_alert_info
#' @importFrom memoise has_cache
#'
#' @seealso [ccc_std_demographics()] [cces_dv_ids]
#'
#' @examples
#'
#' # Read cumulative common content, subsetted to 2018. By default, this uses
#' # the latest released Dataverse version and keeps a local copy for next time.
#' \dontrun{
#'  ccc <- get_cces_dataverse("cumulative", year_subset = 2018)
#'  }
#'
#' # The default resolves to the latest released Dataverse version. As of
#' # June 24, 2026, that is version 5.0 for the 2006 dataset.
#' \dontrun{
#'  cc06 <- get_cces_dataverse("2006")
#'  #> i Using version "5.0" of "10.7910/DVN/Q8HC9N" (no existing cache on disk).
#'  #> Downloading and reading large dataset, can take about 3-5 minutes to complete.
#'
#'  # The same call uses the same versioned cache entry.
#'  cc06_again <- get_cces_dataverse("2006")
#'  #> i Using version "5.0" of "10.7910/DVN/Q8HC9N" (using existing disk cache).
#'
#'  # A different version is a different request; if version 4.0 is not already
#'  # cached, it downloads and keeps a separate local copy.
#'  cc06_v4 <- get_cces_dataverse("2006", ver = "4.0")
#'  #> i Using version "4.0" of "10.7910/DVN/Q8HC9N" (no existing cache on disk).
#'  #> Downloading and reading large dataset, can take about 3-5 minutes to complete.
#'  }
#'
#' # Example code to read and write a series of common content datasets
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
                        ver = ":latest",
                        cache = TRUE,
                        dataverse_paths = ccesMRPprep::cces_dv_ids) {

  y_info <- filter(dataverse_paths, .data$cces_name == as.character(name))
  filetype <- str_extract(y_info$filename, "\\.[A-z]+$")
  svr <- y_info$server
  caseid_var <- y_info$caseid_var
  yr <- y_info$year
  doi <- y_info$doi

  # resolve version for caching ----
  # dataverse only caches on disk when a *specific* version number is requested
  # (e.g. "11.0"). Dataverse's "special" version identifiers are the colon-prefixed
  # placeholders that resolve to whatever is newest at request time, so they can't
  # be cached. If the user wants caching but left `ver` as one of these, resolve it
  # to the concrete latest released version number so the download can be cached.
  if (identical(ver, ":draft")) {
    stop("`ver = \":draft\"` is not supported. Use a released Dataverse version.")
  }

  special_versions <- c(":latest", ":latest-published")
  if (cache && ver %in% special_versions) {
    ver <- latest_dataverse_version(doi = doi, server = svr)
  }

  use_cache <- if (cache) "disk" else "none"

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
  large_dataset <- isTRUE(yr %% 2 == 0) || identical(doi, "10.7910/DVN/II2DB6")
  file_cached <- dataverse_file_cached(filename = y_info$filename,
                                       dataset = glue("doi:{doi}"),
                                       server = svr,
                                       version = ver,
                                       use_cache = use_cache)
  cache_status <- if (!cache) {
    "disk cache disabled"
  } else if (file_cached) {
    "using existing disk cache"
  } else {
    "no existing cache on disk"
  }
  cli_alert_info("Using version {.val {ver}} of {.val {doi}} ({cache_status}).")
  if (large_dataset && !file_cached)
    cat("Downloading and reading large dataset, can take about 3-5 minutes to complete.", "\n")

  cces_raw <- get_dataframe_by_name(filename = glue("{y_info$filename}"),
                                    dataset = glue("doi:{doi}"),
                                    server = svr,
                                    original = TRUE,
                                    version = ver,
                                    use_cache = use_cache,
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


#' Resolve the latest released version number of a Dataverse dataset
#'
#' Internal helper. Queries Dataverse for all versions of a dataset and returns
#' the highest released version as a \code{"MAJOR.MINOR"} string (e.g. `"9.0"`),
#' which can be passed to \code{dataverse} as a concrete version so the download
#' is cached on disk.
#'
#' @param doi The dataset DOI (without the `doi:` prefix), e.g. `"10.7910/DVN/II2DB6"`.
#' @param server The Dataverse server, e.g. `"dataverse.harvard.edu"`.
#'
#' @return A length-one character string such as `"9.0"`.
#' @examples
#' \dontrun{
#' latest_dataverse_version("10.70122/FK2/PPIAXE", "demo.dataverse.org")
#' #> [1] "3.0"
#' }
#' @keywords internal
#' @noRd
latest_dataverse_version <- function(doi, server) {
  vers <- dataset_versions(dataset = glue("doi:{doi}"), server = server)

  released <- Filter(function(v) identical(v$versionState, "RELEASED"), vers)
  if (length(released) == 0)
    released <- vers

  versions <- data.frame(
    versionNumber = vapply(released, function(v) as.integer(v$versionNumber), integer(1)),
    versionMinorNumber = vapply(released, function(v) as.integer(v$versionMinorNumber), integer(1))
  )
  latest <- released[[tail(order(versions$versionNumber, versions$versionMinorNumber), 1)]]

  as.character(glue("{latest$versionNumber}.{latest$versionMinorNumber}"))
}


#' Check whether a Dataverse raw file request is already in the disk cache
#'
#' @examples
#' \dontrun{
#' dataverse_file_cached(
#'   filename = "nlsw88_rds-export.rds",
#'   dataset = "doi:10.70122/FK2/PPIAXE",
#'   server = "demo.dataverse.org",
#'   version = "3.0",
#'   use_cache = "disk"
#' )
#'
#' nlsw88 <- dataverse::get_dataframe_by_name(
#'   filename = "nlsw88_rds-export.rds",
#'   dataset = "doi:10.70122/FK2/PPIAXE",
#'   server = "demo.dataverse.org",
#'   version = "3.0",
#'   use_cache = "disk",
#'   original = TRUE,
#'   .f = readr::read_rds
#' )
#'
#' dataverse_file_cached(
#'   filename = "nlsw88_rds-export.rds",
#'   dataset = "doi:10.70122/FK2/PPIAXE",
#'   server = "demo.dataverse.org",
#'   version = "3.0",
#'   use_cache = "disk"
#' )
#' #> [1] TRUE
#' }
#' @keywords internal
#' @noRd
dataverse_file_cached <- function(filename, dataset, server, version, use_cache) {
  if (!identical(use_cache, "disk"))
    return(FALSE)

  request <- dataverse_file_request(filename = filename,
                                    dataset = dataset,
                                    server = server,
                                    version = version,
                                    use_cache = use_cache)

  has_cache(getFromNamespace("api_get_disk_cache", "dataverse"))(
    request$url,
    query = request$query,
    version = version,
    key = Sys.getenv("DATAVERSE_KEY"),
    as = "raw"
  )
}


#' Build the raw Dataverse file request used for reading and cache checks
#'
#' @examples
#' \dontrun{
#' dataverse_file_request(
#'   filename = "nlsw88_rds-export.rds",
#'   dataset = "doi:10.70122/FK2/PPIAXE",
#'   server = "demo.dataverse.org",
#'   version = "3.0",
#'   use_cache = "disk"
#' )
#' #> $url
#' #> [1] "https://demo.dataverse.org/api/access/datafile/1734016"
#' #>
#' #> $query
#' #> list()
#' }
#' @keywords internal
#' @noRd
dataverse_file_request <- function(filename, dataset, server, version, use_cache) {
  file_url <- get_file_by_name(filename = filename,
                               dataset = dataset,
                               server = server,
                               original = TRUE,
                               version = version,
                               use_cache = use_cache,
                               return_url = TRUE)
  url_parts <- strsplit(file_url, "?", fixed = TRUE)[[1]]
  url <- url_parts[[1]]
  query <- list()

  if (length(url_parts) > 1) {
    query_parts <- strsplit(url_parts[[2]], "&", fixed = TRUE)[[1]]
    query <- lapply(query_parts, function(x) {
      utils::URLdecode(strsplit(x, "=", fixed = TRUE)[[1]][[2]])
    })
    names(query) <- vapply(query_parts, function(x) {
      utils::URLdecode(strsplit(x, "=", fixed = TRUE)[[1]][[1]])
    }, character(1))
  }

  list(url = url, query = query)
}
