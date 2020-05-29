#' Collapse CCES data to be analyzed in binomial model
#'
#' Currently only is compatible with question of type \code{"yesno"}.
#'
#' @param data A cleaned CCES dataset, e.g. from \link{ccc_std_demographics} which is
#' then combined with outcome and contextual data in \link{cces_join_slim}. Currently, it
#'  assumes the outcome is named \code{response}. This variable need not be numeric or
#'  binarized, but it will be binarized with \link{yesno_to_binary}.
#' @param model_ff the model formula used to fit the multilevel regression model.
#' Currently only expects an binomial, of the brms form \code{y|trials(n) ~ x1 + x2 + (1|x3)}.
#' Only the RHS will be used but the LHS is necessary.
#' @param multiple_qIDs Does the data contain _multiple_ outcomes in long form and
#'  therefore require the counts to be built for each outcome? Defaults to \code{FALSE}.
#'
#' @importFrom haven as_factor is.labelled
#' @import rlang
#' @import dplyr
#' @importFrom stats as.formula
#'
#' @export
#'
#'
#' @examples
#'
#' library(dplyr)
#'
#' ccc_samp_std <- ccc_samp %>%
#'   mutate(response = sample(c("For", "Against"), size = n(), replace = TRUE)) %>%
#'   ccc_std_demographics()
#'
#' ccc_samp_out <- build_counts(ccc_samp_std,
#'                              "yes | trials(n_response) ~ age + gender + educ")
build_counts <- function(data, model_ff, multiple_qIDs = FALSE) {
  all_vars <- all.vars(as.formula(model_ff))[-c(1:2)]
  xvars <- setdiff(all_vars, "response")

  if (multiple_qIDs)
    xvars <- c("qID", xvars)

  n_na <- sum(is.na(yesno_to_binary(data$response)))
  if (n_na > 0) {
    warning(as.character(glue("{n_na} observations in the data have missing values,
                 which will be counted as failures\n")))
  }

  data_counts <- data %>%
    group_by(!!!syms(xvars)) %>%
    summarize(n_response = sum(!is.na(response)),
              yes = sum(yesno_to_binary(response), na.rm = TRUE),
              .groups = "drop") %>%
    filter(n_response > 0) %>%
    mutate_if(is.labelled, haven::as_factor) %>%
    mutate_if(is.logical, as.integer)

  attr(data_counts, "question") <- attr(data, "question")
  data_counts
}

