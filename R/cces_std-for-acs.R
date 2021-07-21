#' Recode CCES variables so that they merge to ACS variables
#'
#' @param tbl The cumulative common content. It can be any subset but must include variables
#'  \code{age}, \code{race}, \code{educ}, \code{gender}, \code{st}, \code{state},
#'  and \code{cd}. Factor variables must a haven_labelled class variable as is
#'  the output of \code{get_cces_dataverse("cumulative")}. See \link{ccc_samp} for an example.
#'  Any other file (for example, year-specific common contents) are not compatible with
#'  this function.
#' @param only_demog Drop variables besides demographics? Defaults to FALSE
#' @param age_key The vector key to use to bin age. Can be `deframe(age5_key)` or `deframe(age10_key)`
#' @param wh_as_hisp Should people who identify as both White and Hispanic be
#'  coded as "Hispanic",  thereby leaving all remaining "Whites" as Non-Hispanic Whites
#'  by definition? For more information, see https://twitter.com/A_agadjanian/status/1385760354953662466
#' @param bh_as_hisp Same as `wh_as_hisp` but for Black Hispanics. Defaults to TRUE.
#'
#' @section Input Requirements:
#'  This function requires data to have the following columns:
#'   * A string column called `st` that is a two-letter abbreviation of the state, or a labelled
#'     variable coercible to a string.
#'   * A string column called `cd` that has the congressional district that is of the form
#'    `"WY-01"`, OR a numeric column called `dist` that has the numeric district number.
#'     `cd_up` can also be used for the district in the upcoming election.
#'   * A <numeric+labelled> column called `educ` for education, `race` for race,
#'    `age` for age, and `gender` for gender, with values following
#'    the cumulative content.
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
#' * \code{cd} is standardized so that at large districts are given "01" and
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
#'
#'  ccc_std_demographics(ccc_samp)
#'  cc_std_demographics(ccc_samp, wh_as_hisp = FALSE) %>% count(race)
#'  cc_std_demographics(ccc_samp, bh_as_hisp = FALSE, wh_as_hisp = FALSE) %>% count(race)
#'
#' \dontrun{
#'  # For full data (takes a while)
#'  library(dataverse)
#'  cumulative_rds <- get_cces_dataverse("cumulative")
#'  cumulative_std <- ccc_std_demographics(cumulative_rds)
#'  }
#'
#' \dontrun{
#'  wrong_cd_fmt <- mutate(ccc_samp, cd = str_replace_all(cd, "01", "1"))
#'  wrong_cd_fmt %>% filter(st == "HI") %>% count(cd)
#'
#'  # throws error because CD is formatted the wrong way
#'  ccc_std_demographics(wrong_cd_fmt)
#' }
#'
#'
#' @export
#'
#'
ccc_std_demographics <- function(tbl,
                                 only_demog = FALSE,
                                 age_key = deframe(ccesMRPprep::age5_key),
                                 wh_as_hisp = TRUE,
                                 bh_as_hisp = TRUE) {

  race_cces_to_acs <- ccesMRPprep::race_key %>% distinct(.data$race_cces_chr, .data$race)
  educ_cces_to_acs <- ccesMRPprep::educ_key %>% distinct(.data$educ_cces_chr, .data$educ)

  # districts
  if (inherits(tbl$st, "haven_labelled"))
    tbl$st <- as.character(as_factor(tbl$st))
  if (inherits(tbl$state, "haven_labelled"))
    tbl$state <- as.character(as_factor(tbl$state))

  # cd pad 0s
  if ("dist" %in% colnames(tbl)) {
    tbl$cd <- str_c(tbl$st, "-", str_pad(tbl$dist, width = 2, pad = "0"))
    message("Re-creating cd from st and dist, in standard form.")
  }

  if ("dist_up" %in% colnames(tbl)) {
    tbl$cd_up <- str_c(tbl$st, "-", str_pad(tbl$dist_up, width = 2, pad = "0"))
    message("Re-creating cd_up from st and dist_up, in standard form.")
  }

  # CHECK for no single digits and "AL" notation
  if ("cd" %in% colnames(tbl)) {
    if (any(str_detect(tbl$cd, "[A-Z][A-Z]-[1-9]$"), na.rm = TRUE))
      stop("CD must be of the form MA-01, not MA-1. Give a dataset with numeric variable
           called dist so it can make that for you.")

    if (any(str_detect(tbl$cd, "[A-Z][A-Z]-AL"), na.rm = TRUE))
      stop("CD must be of the form AK-01, not AK-AL, for at large districts.
           Give a dataset with numeric variable called dist so it can make that for you.")
  }


  # demographics
  age_vec <-  tbl$age # to check

  tbl_mod <- tbl %>%
    # age
    mutate(age_orig = .data$age,
           age = ccc_bin_age(.data$age, agelbl = age_key)) %>%
    # gender
    mutate(female = as.numeric(.data$gender == 2)) %>%
    # race
    rename(race_cces_chr = .data$race) %>%
    mutate(race_cces_chr = as.character(as_factor(.data$race_cces_chr))) %>%
    left_join(race_cces_to_acs, by = "race_cces_chr") %>%
    # education
    rename(educ_cces_chr = .data$educ) %>%
    mutate(educ_cces_chr = as.character(as_factor(.data$educ_cces_chr))) %>%
    left_join(educ_cces_to_acs, by = "educ_cces_chr")

  # hispanic conversion
  if (wh_as_hisp) {
    tbl_mod <- tbl_mod %>%
      mutate(race = replace(race, race_cces_chr == "White" & hispanic == 1, race_cces_to_acs$race[3]))
  }

  if (bh_as_hisp) {
    tbl_mod <- tbl_mod %>%
      mutate(race = replace(race, race_cces_chr == "Black" & hispanic == 1, race_cces_to_acs$race[3]))
  }

  tbl_out <- tbl_mod %>%
    select(matches("year"),
           matches("case_id"),
           matches("weight"),
           matches("(state|st|cd|dist)"),
           matches("gender"),
           female,
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
                        agelbl = deframe(ccesMRPprep::age5_key)) {
  data("age5_key", envir = environment())


  int_bin <- case_when(agevec %in% 18:24 ~ 1L,
                       agevec %in% 25:34 ~ 2L,
                       agevec %in% 35:44 ~ 3L,
                       agevec %in% 45:64 ~ 4L,
                       agevec >=   65    ~ 5L,
                       TRUE ~ NA_integer_)

  labelled(int_bin, labels = agelbl)
}
