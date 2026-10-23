# Written by Codex
local_dataverse_download <- function(data, filetype, version, .env = parent.frame()) {
  tmp <- tempfile(fileext = glue::glue(".{filetype}"))
  on.exit(unlink(tmp), add = TRUE)
  if (filetype == "dta") {
    haven::write_dta(data, tmp)
  } else {
    arrow::write_feather(data, tmp)
  }
  payload <- readBin(tmp, "raw", n = file.info(tmp)$size)
  expected_version <- version
  expected_id <- if (filetype == "dta") 1L else 2L
  expected_url <- as.character(glue::glue("https://dataverse.harvard.edu/api/access/datafile/{expected_id}"))

  local_mocked_bindings(
    dataset_files = function(dataset, server, version, use_cache) {
      expect_identical(version, expected_version)
      list(
        list(label = "cumulative_2006-2024.dta", dataFile = list(id = 1L)),
        list(label = "cces_cumulative_2006-2024.feather", dataFile = list(id = 2L)),
        list(label = "cumulative_2006-2024_codebook.dta", dataFile = list(id = 3L))
      )
    },
    has_cache = function(f) {
      function(url, ...) {
        expect_identical(url, expected_url)
        FALSE
      }
    },
    .package = "ccesMRPprep",
    .env = .env
  )
  local_mocked_bindings(
    api_get = function(url, query, ...) {
      expect_identical(url, expected_url)
      expect_identical(query, list())
      payload
    },
    .package = "dataverse",
    .env = .env
  )
}

test_that("the default reads a uniquely identified cumulative dta from the requested version", {
  data <- tibble::tibble(case_id = c(1, 2), year = c(2022, 2024))
  local_dataverse_download(data, "dta", version = "11.0")

  output <- capture.output(result <- suppressMessages(get_cces_dataverse(
    "cumulative", year_subset = 2024, std_index = FALSE,
    ver = "11.0"
  )))

  expect_equal(haven::zap_formats(result), data[2, ])
  expect_match(output, "Downloading large dataset", fixed = TRUE)
})

test_that("filetype feather reads the uniquely identified Feather file", {
  skip_if_not_installed("arrow")
  data <- tibble::tibble(case_id = c(1, 2), year = c(2022, 2024))
  local_dataverse_download(data, "feather", version = "10.0")

  output <- capture.output(result <- suppressMessages(get_cces_dataverse(
    "cumulative", filetype = "feather", year_subset = 2024, std_index = FALSE,
    ver = "10.0"
  )))

  expect_equal(result, data[2, ])
  expect_length(output, 0L)
})

test_that("cumulative files must have exactly one match of the requested format", {
  labels <- character()
  local_mocked_bindings(
    dataset_files = function(...) {
      lapply(seq_along(labels), function(i) {
        list(label = labels[[i]], dataFile = list(id = as.integer(i)))
      })
    },
    .package = "ccesMRPprep"
  )

  for (filetype in c("dta", "feather")) {
    filename <- as.character(glue::glue("cumulative_2006-2025.{filetype}"))
    request <- function() {
      dataverse_file_request(filename, "doi:example", "dataverse.harvard.edu",
                             version = "11.0", use_cache = "none")
    }

    labels <- "cumulative_2006-2025.rds"
    expect_error(request(), "version 11.0; found 0", fixed = TRUE)

    labels <- c(filename, as.character(glue::glue("cumulative_2006-2024.{filetype}")))
    expect_error(request(), "version 11.0; found 2", fixed = TRUE)
    expect_error(request(), paste(labels, collapse = ", "), fixed = TRUE)
  }
})

test_that("unsupported filetypes are rejected before downloading", {
  expect_error(get_cces_dataverse(filetype = "csv"), "'arg' should be one of")
})
