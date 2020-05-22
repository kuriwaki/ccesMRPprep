#' Recode CCES variable values so that they merge to ACS variables
#'
#' @param tbl A subset of the cumulative common content. Must include variables
#'  \code{age}, \code{race}, \code{educ}, and \code{gender}.
#' @param only_demog Drop variables besides demographics? Defaults to FALSE
#' @importFrom glue glue
#' @importFrom haven as_factor
#'
#' @examples
#'  library(dataverse)
#'
#'  # Load Cumulative dataset
#'  cumulative_rds <- get_file("cumulative_2006_2018.Rds", "doi:10.7910/DVN/II2DB6")
#'  tmp <- tempfile(fileext = ".Rds")
#'  writeBin(cumulative_rds, tmp)
#'  cumulative_rds <- readr::read_rds(tmp)
#'
#'  cumulative_std <- ccc_std_demographics(cumulative_rds)
#'
#' @export
#'
#'
ccc_std_demographics <- function(tbl, only_demog = FALSE) {
  tbl_modified <- tbl %>%
    # geography
    mutate(cd = as.character(glue("{st}-{str_pad(dist, width = 2, pad = '0')}"))) %>%
    # age
    mutate(age_bin = rcces::ccc_bin_age(age)) %>%
    # race
    mutate(race = as.character(as_factor(race))) %>%
    rename(race_cces_chr = race) %>%
    left_join(distinct(race_key, race_cces_chr, race), by = "race_cces_chr") %>%
    # education
    rename(educ_cces = educ) %>%
    mutate(educ_cces = as.character(as_factor(educ_cces))) %>%
    left_join(distinct(select(educ_key, educ_cces, educ)), by = "educ_cces")

    tbl_out <- tbl_modified %>%
      select(matches("year"),
           matches("case_id"),
           matches("weight"),
           matches("(state|st|cd|dist)"),
           matches("gender"),
           matches("pid3$"),
           matches("age"),
           matches("educ"),
           matches("^race"),
           matches("faminc"),
           matches("citizen"),
           matches("marstat"),
           matches("vv"),
           everything())

    if (only_demog)
      tbl_out <- select(tbl_out, year:marstat, matches("vv"))

    tbl_out %>%
      select_if(~any(!is.na(.x))) %>%
      distinct()
}
