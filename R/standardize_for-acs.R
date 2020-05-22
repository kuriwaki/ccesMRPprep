#' Recode CCES variables so that they merge to ACS variables
#'
#' @param tbl A subset of the cumulative common content. Must include variables
#'  \code{age}, \code{race}, \code{educ}, and \code{gender}.
#' @param only_demog Drop variables besides demographics? Defaults to FALSE
#'
#'
#' @return The output is of the same dimensions as the input (unless \code{only_demog = TRUE})
#' but with the following exceptions. \code{age_bin} is coded to match up with the ACS
#' bins and the recoding occurs in a separate function, \code{ccc_bin_age}.
#'\code{educ} is recoded (coarsened and relabelled) to match up with the ACS.
#' (the original version is left as \code{educ_cces_chr}), and the same goes for
#' \code{race}. These recodings are governed by the key-value pairs \link{educ_key} and
#' \link{race_key}.
#'
#' @import dplyr
#' @importFrom glue glue
#' @importFrom haven as_factor
#' @importFrom magrittr `%>%`
#'
#' @examples
#' \dontrun{
#'  library(dataverse)
#'
#'  # Load Cumulative dataset (need your own Token)
#'  cumulative_rds <- get_file(file = "cumulative_2006_2018.Rds",
#'                             dataset = "doi:10.7910/DVN/II2DB6")
#'  tmp <- tempfile(fileext = ".Rds")
#'  writeBin(cumulative_rds, tmp)
#'  cumulative_rds <- readr::read_rds(tmp)
#'
#'  cumulative_std <- ccc_std_demographics(cumulative_rds)
#'
#'  }
#'
#' @export
#'
#'
ccc_std_demographics <- function(tbl, only_demog = FALSE) {


  race_cces_to_acs <- race_key %>% distinct(race_cces_chr, race)
  educ_cces_to_acs <- educ_key %>% distinct(educ_cces_chr, educ)


  tbl_modified <- tbl %>%
    # age
    mutate(age_bin = ccc_bin_age(age)) %>%
    # race
    rename(race_cces_chr = race) %>%
    mutate(race_cces_chr = as.character(as_factor(race_cces_chr))) %>%
    left_join(race_cces_to_acs, by = "race_cces_chr") %>%
    # education
    rename(educ_cces_chr = educ) %>%
    mutate(educ_cces_chr = as.character(as_factor(educ_cces_chr))) %>%
    left_join(educ_cces_to_acs, by = "educ_cces_chr")

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



#' Discretize a vector of age integers into labelled variables
#'
#' @details The recoding is governed by \code{age5_key}. IT currently only accepts
#' 5-way binning, following the ACS.
#'
#' @param agevec a vector of integers
#' @param agelbl a value-key pair to be passed into recode,
#'  with values as the things to be recoded and labels as the labels for each
#'  value.
#'
#' @importFrom tibble deframe
#' @importFrom haven labelled
#'
#'
#' @examples
#'   ccc_bin_age(c(15:100, NA))
#'
#' @export
ccc_bin_age <- function(agevec,
                        agelbl = deframe(age5_key)) {
  int_bin <- case_when(agevec %in% 18:24 ~ 1L,
                       agevec %in% 25:34 ~ 2L,
                       agevec %in% 35:44 ~ 3L,
                       agevec %in% 45:64 ~ 4L,
                       agevec >=   65    ~ 5L,
                       TRUE ~ NA_integer_)

  labelled(int_bin, labels = agelbl)
}
