#' Collapse CCES data to be analyzed in binomial model
#'
#' Currently only is compatible with question of type \code{"yesno"}.
#'
#' @param data A cleaned CCES dataset, e.g. from \link{ccc_std_demographics} which is
#' then combined with outcome and contextual data in \link{cces_join_slim}.
#' By default it expects the LHS outcome to be named \code{response}, and expects
#' the dataset to have that variable.
#'  This variable must be binary or it must be a character vector that can be coerced
#'  by \link{yesno_to_binary} into a binary variable.
#' @param model_ff the model formula used to fit the multilevel regression model.
#' Currently only expects an binomial, of the brms form \code{y|trials(n) ~ x1 + x2 + (1|x3)}.
#' Only the RHS will be used but the LHS is necessary.
#' @param keep_vars Variables that will be kept as a cell variable, regardless
#'  of whether it is specified in a formula. Input as character vector.
#' @param y_named_as What is the original response / outcome variable called?
#'  Currently defaults to "response" from \link{get_cces_question}.
#' @param name_ones_as What to name the variable that represents the number of
#'  successes in the binomial
#' @param name_trls_as What to name the variable that represents the number of
#'  trials in the binomial.
#' @param multiple_qIDs Does the data contain _multiple_ outcomes in long form and
#'  therefore require the counts to be built for each outcome? Defaults to \code{FALSE}.
#' @param verbose Show warning messages? Defaults to TRUE
#'
#' @importFrom haven as_factor is.labelled
#' @import rlang
#' @import dplyr
#' @importFrom stats as.formula
#'
#' @export
#'
#' @return A dataframe of cells. The following variables have fixed names and
#'  will be assumed by `ccesMRPrun::fit_brms_binomial`:
#'
#'  - `yes`: the number of successes observed in the cell
#'  - `n_response` the number of non-missing responses, representing the number
#'   of trials.
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
#' ff <- "yes | trials(n_response) ~ age + gender + educ + (1|cd)"
#' ccc_samp_out <- build_counts(ccc_samp_std,
#'                              model_ff = ff)
#'
#' ccc_samp_out
#'
#' # alternative options
#' build_counts(ccc_samp_std, model_ff = ff, name_ones_as = "success", name_trls_as = "trials")
#' build_counts(ccc_samp_std, model_ff = ff, keep_vars = "state")
#'
build_counts <- function(data, model_ff,
                         keep_vars = NULL,
                         name_ones_as = "yes",
                         name_trls_as = "n_response",
                         y_named_as = "response",
                         multiple_qIDs = FALSE, verbose = TRUE) {

  all_vars <- all.vars(as.formula(model_ff))[-c(1:2)]
  xvars <- setdiff(c(all_vars, keep_vars), y_named_as)

  if (multiple_qIDs)
    xvars <- c("qID", xvars)

  # rename to y
  data$y <- data[[y_named_as]]

  # if character, then turn to Yes/No numeric
  if (is.character(data$y))
    data$y <- yesno_to_binary(data$y)

  if (!any(data$y == 0, na.rm = TRUE) | !any(data$y == 1, na.rm = TRUE) |
      any(data$y > 1, na.rm = TRUE)) {
    stop("outcome variable is not binary or has no variation")
  }

  # report missings due to outcome NA
  n_na <- sum(is.na(data$y))
  if (n_na > 0 & verbose) {
    warning(as.character(glue("{n_na} observations in the data have missing values,
                 which will be dropped from the counts.\n")))
  }

  data_counts <- data %>%
    group_by(!!!syms(xvars)) %>%
    summarize(!!sym(name_trls_as) := sum(!is.na(.data$y)),
              !!sym(name_ones_as) := sum(.data$y, na.rm = TRUE),
              .groups = "drop") %>%
    filter(!!sym(name_trls_as) > 0) %>%
    mutate_if(is.labelled, haven::as_factor) %>%
    mutate_if(is.logical, as.integer)


  if (!is.null(attr(data, "question")))
    attr(data_counts, "question") <- attr(data, "question")

  data_counts
}

