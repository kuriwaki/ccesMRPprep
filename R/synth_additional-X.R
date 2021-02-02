#' Model synthetic joint distribution of categorical variables
#'
#' Imputes the counts of a joint distribution of count variables for small areas
#' based on microdata. In this setup, the population distribution table (`poptable`)
#' has the joint distribution of `(A, X_{1}, ..., X_{K - 1})` categorical variables where
#' `A` denotes a categorical small area, `X`s denote categorical covariates, and
#' the missing covariate is `X_{K}`.
#'
#' Now, the survey data (`microdata`) has a sample joint distribution of
#' `(X_{1}, .., X_{K - 1}, X_{K})` categorical variables but the sample size is too small
#' for small areas. Therefore, the function models a multinomial outcome model roughly of the
#' form `X_{K} ~ X_{1} + ... X_{K}` and predicts onto `poptable` to estimate the
#' joint distribution of `(A, X_{1}, .., X_{K})`
#'
#' Currently, this function does not support post-stratifiation based on a known aggregate
#' distribution -- that is, further adjusting the probabilities based on
#' a known population distribution (see e.g. Leeman and Wasserfallen AJPS <https://doi.org/10.1111/ajps.12319>)
#'
#' @param formula A representation of the aggregate imputation or "outcome" model,
#'  of the form `X_{K} ~ X_1 + ... X_{K - 1}`
#' @param microdata The survey table that the multinomial model will be built off.
#'  Must contain all variables in the LHS and RHS of `formula`.
#' @param poptable The population table, collapsed in terms of counts. Must contain
#'  all variables in the RHS of `formula`, as well as the variables specified in
#'   `area_var` and `count_var` below.
#' @param area_var A character vector of the area of interest.
#' @param count_var A character variable that specifies which variable in `poptable`
#'  indicates the count
#'
#'
#' @returns A dataframe with a similar format as the `poptarget` table
#'  but with rows expanded to serve as a joint distribution. In general,
#'  if the variable of interest has `L` values, the final dataset will have
#'  `L` times more rows than `poptarget`. The data will have additional variables:
#'
#'  * `n_aggregate`: The sum of counts known in the aggregate. i.e., the number of
#'   trials the multinomial will consider. This is the sum of the original
#'   `count` variables.
#'  * The outcome variable of interest. For example if the LHS of the formula
#'     was `party_id`, then there would be a column called `party_id` containing the
#'     values of that variable in long form.
#'  * `pr_pred`: The predicted probability of taking the value of the outcome. This
#'   is the main output of the multinomial model.
#'  * `count`: A new count variable. Simply the product of `n_aggregate` and `pr_pred`.
#'
#'
#' @export
#' @importFrom Formula as.Formula
#' @importFrom emlogit emlogit
#' @importFrom dplyr bind_cols as_tibble count sym syms
#' @importFrom tidyr pivot_longer complete
#' @importFrom stats complete.cases
#'
#' @source
#'  Soichiro Yamauchi (2021). emlogit: Implementing the ECM algorithm for multinomial logit
#'   model. R package version 0.1.1. <https://github.com/soichiroy/emlogit>
#'
#'  Yair Ghitza and Mark Steitz (2020). DEEP-MAPS Model of the Labor Force.
#'    Working Paper. <https://github.com/Catalist-LLC/unemployment>
#'
#'
#'
#' @examples
#'  library(dplyr)
#'
#'  # Impute the joint distribution of party ID with race, sex, and age, using
#'  # survey data in NY.
#'
#'  imputed_acs <- synth_mlogit(pid3 ~ race + age + female,
#'                              microdata = cc18_NY,
#'                              poptable = acs_NY,
#'                              area_var = "cd")
#'
#'  # original (27 districts x 2 sex x 5 age x 6 race categories)
#'  count(acs_NY, cd, female, age, race, wt = count)
#'
#'  # new, modeled (original x 5 party categories)
#'  imputed_acs
#'
#'  # See the data elec_NY to see if these numbers look reasonable.
#'
#'
#'\dontrun{
#'   # another example -- imputing education
#'   library(ccesMRPrun)
#'   synth_mlogit(educ ~ age + female,
#'               microdata = cces_GA,
#'               poptable = acs_GA,
#'               area_var = "cd")
#'}
#'
synth_mlogit <- function(formula,
                        microdata,
                        poptable,
                        area_var,
                        count_var = "count") {
  # formula setup
  Form <- as.Formula(formula)
  outcome_var <- all.vars(formula(Form, lhs = 1, rhs = 0))
  y_form  <- as.formula(paste0("~ ", outcome_var, "- 1")) # ~ X_{K} - 1
  X_form  <- formula(Form, lhs = 0, rhs = 1) # ~ X1 + .... X_{K - 1}
  X_vars <- all.vars(X_form)

  # checks
  stopifnot(all(c(outcome_var, X_vars) %in% colnames(microdata)))
  stopifnot(all(c(area_var, X_vars) %in% colnames(poptable)))

  # Drop NAs
  microdata <- select(microdata, !!!syms(c(outcome_var, X_vars)))
  if (nrow(microdata) > sum(complete.cases(microdata))) {
    warning("NAs in the microdata -- dropping data")
    microdata <- filter(microdata, complete.cases(microdata))
  }


  # ys (in microdata)
  y_m_mat <- model.matrix(y_form, microdata)

  # Xs setup microdata
  X_m_mat <- model.matrix(X_form, microdata)[, -1]

  # Xs setup population table -- aggregate up to {A, X_1, ..., X_{K -1 }}
  X_p_df <-  count(poptable,
                   !!!syms(c(area_var, X_vars)),
                   wt = !!sym(count_var),
                   name = "n_aggregate") %>%
    complete(!!!syms(c(area_var, X_vars)), fill = list(n_aggregate = 0))

  if (any(X_p_df$n_aggregate == 0))
    warning("Some population combinations have zero people")

  X_p_mat <- model.matrix(X_form, X_p_df)[, -1]


  # fit model
  mlogit_fit <- emlogit(Y = y_m_mat, X = X_m_mat)

  # predict onto table
  pred_df <- as_tibble(predict(mlogit_fit, newdata = X_p_mat))
  pred_df <- bind_cols(X_p_df, pred_df)

  # tidy
  pred_long <- pred_df %>%
    pivot_longer(
      cols = -c(area_var, X_vars, "n_aggregate"),
      names_prefix = outcome_var, # because model.matrix will put these in prefix
      names_to = outcome_var, # name them as that
      values_to = "pr_pred") %>%
    mutate(!!sym(count_var) := n_aggregate*pr_pred)

  pred_long
}


#

