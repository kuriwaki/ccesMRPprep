#' Recode CCES variables so that they merge to ACS variables
#'
#' @param tbl A subset of the cumulative common content. Must include variables
#'  \code{age}, \code{race}, \code{educ}, \code{gender}, \code{st}, \code{state},
#'  and \code{cd}. See \link{ccc_samp} for an example.
#' @param only_demog Drop variables besides demographics? Defaults to FALSE
#' @param age_key The vector key to use to bin age. Can be `deframe(age5_key)` or `deframe(age10_key)`
#'
#'
#' @return The output is of the same dimensions as the input (unless \code{only_demog = TRUE})
#' but with the following exceptions:
#'
#' * \code{age} is coded to match up with the ACS bins and the recoding occurs
#'  in a separate function, \code{ccc_bin_age}. The unbinned age is left instead to
#'  \code{age_orig}.
#' * \code{educ} is recoded (coarsened and relabelled) to match up with the ACS.
#'  (the original version is left as \code{educ_cces_chr}). Recoding is governed by
#'  the key-value pairs \link{educ_key}
#' * the same goes for \code{race}. These recodings are governed by the
#'  key-value pair \link{race_key}.
#' * \code{cd} is standardized so that at large districs are given "01" and
#'  single-digit districts are padded with 0s. e.g. \code{"WY-01"} and \code{"CA-02"}.
#'
#' @import dplyr
#' @importFrom glue glue
#' @importFrom haven as_factor
#' @importFrom tibble deframe
#' @importFrom magrittr `%>%`
#' @importFrom rlang .data
#' @importFrom utils data
#' @importFrom stringr str_c str_pad
#'
#' @examples
#' \dontrun{
#'  library(dataverse)
#'
#'  # Load Cumulative dataset (need your own Token)
#'  cumulative_rds <- get_cces_dv("cumulative")
#'
#'  cumulative_std <- ccc_std_demographics(cumulative_rds)
#'
#'  }
#'
#' @export
#'
#'
ccc_std_demographics <- function(tbl, only_demog = FALSE, age_key = deframe(ccesMRPprep::age5_key)) {

  race_cces_to_acs <- race_key %>% distinct(race_cces_chr, race)
  educ_cces_to_acs <- educ_key %>% distinct(educ_cces_chr, educ)

  # districts
  if (inherits(tbl$st, "haven_labelled"))
    tbl$st <- as.character(as_factor(tbl$st))
  if (inherits(tbl$state, "haven_labelled"))
    tbl$state <- as.character(as_factor(tbl$state))

  # cd pad 0s
  if ("dist" %in% colnames(tbl)) {
    tbl <- tbl %>%
      mutate(cd = str_c(st, "-", str_pad(dist, width = 2, pad = "0")))
  }
  # no single digits and "AL" notation
  if ("cd" %in% colnames(tbl)) {
    stopifnot(!any(str_detect(tbl$cd, "[A-Z][A-Z]-[1-9]$")))
    stopifnot(!any(str_detect(tbl$cd, "[A-Z][A-Z]-AL")))
  }


  # demographics
  age_vec <-  tbl$age # to check

  tbl_mod <- tbl %>%
    # age
    mutate(age_orig = age,
           age = ccc_bin_age(age, agelbl = age_key)) %>%
    # race
    rename(race_cces_chr = race) %>%
    mutate(race_cces_chr = as.character(as_factor(race_cces_chr))) %>%
    left_join(race_cces_to_acs, by = "race_cces_chr") %>%
    # education
    rename(educ_cces_chr = educ) %>%
    mutate(educ_cces_chr = as.character(as_factor(educ_cces_chr))) %>%
    left_join(educ_cces_to_acs, by = "educ_cces_chr")

    tbl_out <- tbl_mod %>%
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

    if (!identical(age_vec, tbl_mod$age))
      cat("age variable modified to bins. Original age variable is now in age_orig.", "\n")

    if (only_demog)
      tbl_out <- select(tbl_out, .data$year:.data$marstat, matches("vv"))

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
#' @importFrom utils data
#'
#'
#' @examples
#'   ccc_bin_age(c(15:100, NA))
#'
#' @export
ccc_bin_age <- function(agevec,
                        agelbl = deframe(age5_key)) {
  data("age5_key", envir = environment())


  int_bin <- case_when(agevec %in% 18:24 ~ 1L,
                       agevec %in% 25:34 ~ 2L,
                       agevec %in% 35:44 ~ 3L,
                       agevec %in% 45:64 ~ 4L,
                       agevec >=   65    ~ 5L,
                       TRUE ~ NA_integer_)

  labelled(int_bin, labels = agelbl)
}
