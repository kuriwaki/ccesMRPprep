#' Synthetic joint estimation with balancing
#'
#' @param fix_to A dataset with only marginal counts or proportions of the outcome
#'  in question, by each area. Proportions will be corrected so that the margins
#'  of the synthetic joint will match these, with a simple ratio.
#' @param tol Tolerance for balance
#'
#' @seealso `synth_mlogit()`
#'
#' @importFrom bmlogit bmlogit
#' @examples
#'
#' educ_target <- count(acs_educ_NY, cd, educ, wt = count, name = "count")
#' pop_syn <- synth_bmlogit(educ ~ race + age + female,
#'                          microdata = cc18_NY,
#'                          fix_to = educ_target,
#'                          poptable = acs_race_NY,
#'                          area_var = "cd")
#'
#' @keywords internal
synth_bmlogit <- function(formula,
                          microdata,
                          poptable,
                          fix_to,
                          area_var,
                          count_var = "count",
                          tol = 0.01) {
  # formula setup
  list2env(formula_parts(formula), envir = environment())

  # checks
  stopifnot(all(c(outcome_var, X_vars) %in% colnames(microdata)))
  stopifnot(all(c(area_var, X_vars) %in% colnames(poptable)))

  # Drop NAs
  microdata <- select(microdata, !!!syms(c(outcome_var, X_vars)))
  if (nrow(microdata) > sum(complete.cases(microdata))) {
    warning("NAs in the microdata -- dropping data")
    microdata <- filter(microdata, complete.cases(microdata))
  }

  # microdata ----
  # ys (in microdata)
  y_m_mat <- model.matrix(outcome_form, microdata)

  # Xs setup microdata
  X_m_mat <- model.matrix(X_form, microdata)

  # population ----
  # Xs setup population table -- aggregate up to {X_1, ..., X_{K -1 }}
  X_p_df  <- collapse_table(poptable, area_var = NULL, X_vars, count_var)
  X_p_mat <- model.matrix(X_form, X_p_df)

  # N_Area
  X_counts_vec <- collapse_table(poptable, area_var = NULL, X_vars, count_var,
                                 new_name = "N_X") %>%
    pull(N_X)

  # Targets --
   outcome_df <- collapse_table(
     fix_to,
     area_var = NULL,
     X_vars = outcome_var,
     count_var = count_var,
     report = "proportions",
     new_name = "pr_outcome_tgt")
   pr_outcome_tgt <- pull(outcome_df, pr_outcome_tgt)

  # fit model
  fit <- bmlogit(
    Y = y_m_mat,
    X = X_m_mat,
    target_Y = pr_outcome_tgt, # vector
    pop_X = X_p_mat, # matrix
    count_X = X_counts_vec, # vector
    control = list(intercept = FALSE, tol_pred = tol)
  )

  # predict
  predict_longer(fit,
                 poptable = poptable,
                 microdata = microdata,
                 X_form = X_form,
                 X_vars = X_vars,
                 area_var = area_var,
                 count_var = count_var,
                 outcome_var = outcome_var)
}

