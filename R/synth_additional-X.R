#' Decompose formula into parts useful for subsequent analyses
#'
#' Outputs a list. You can use `base::list2env` on the output to release
#'  the items of the list on your environment.
#'
#' @inheritParams synth_mlogit
#' @importFrom Formula as.Formula
#' @keywords internal
formula_parts <- function(formula) {
  Form         <- as.Formula(formula)
  outcome_var  <- all.vars(formula(Form, lhs = 1, rhs = 0))
  outcome_form <- as.formula(paste0("~ ", outcome_var, "- 1")) # ~ X_{K} - 1

  X_form       <- formula(Form, lhs = 0, rhs = 1) # ~ X1 + .... X_{K - 1}
  X_vars       <- all.vars(X_form)

  list(Form = Form,
       outcome_var = outcome_var,
       outcome_form = outcome_form,
       X_form = X_form,
       X_vars = X_vars)
}


#' Reduce the dimensionality of the table
#'
#' @param X_vars A character vector of the variables to keep. By design, this
#'  should be fewer variables than what is available in `poptable`.
#' @param report Should the output be in simple counts (the default, `"counts"`) or
#'  the proportion that count represents in the area (`"proportions"`)?
#' @param new_name What should the new count (or proportion) variable be called?
#'
#' @inheritParams synth_mlogit
#'
#' @returns A dataframe of counts or proportions. By design, it will include the
#'  variables `area_var`, `X_vars`, and whatever is specified in `new_name`.
#'
#' @importFrom dplyr count transmute group_by ungroup rename
#' @importFrom tidyr complete
#' @export
#'
#' @examples
#'
#'  # If you want to estimate education by female and age
#'  collapse_table(acs_NY, area_var = "cd", X_vars = c("female", "age"),
#'                 count_var = "count")
#'
#'  # Report proportions
#'  collapse_table(acs_NY, area_var = "cd", X_vars = c("female", "age"),
#'                 count_var = "count",
#'                 report = "proportions", new_name = "prop_in_cd")
#'
collapse_table <- function(poptable,
                           area_var,
                           X_vars,
                           count_var,
                           report = "counts",
                           new_name = "n_aggregate") {

  # collapse
  out <- count(poptable,
               !!!syms(c(area_var, X_vars)), #  by
               wt = !!sym(count_var), # sum the counts
               name = "new_count") %>%
    complete(!!!syms(c(area_var, X_vars)), fill = list(new_count = 0))

  if (any(out$new_count == 0))
    warning("Some population combinations have zero people")

  # change into proportions
  if (report == "proportions") {
    if (grepl("(n_|count_|_n$|_count)", new_name)) {
      warning("You asked for proporitons but the value of `new_name` looks more appropriate for a count.")
    }

    out <- out %>%
      group_by(!!!syms(area_var)) %>%
      transmute(!!!syms(area_var),
                !!!syms(X_vars),
                !!sym(new_name) := new_count/sum(new_count)) %>% # turn into fraction
      ungroup()
  }

  if (report == "counts")
    out <- rename(out, !!sym(new_name) := "new_count")

  out
}


#' Model synthetic joint distribution with simple product
#'
#' Estimates joint distribution by simply assuming independence and multiplying
#' proportions.
#'
#' @details That is, we already know `p(X_{1}, ..., X_{K - 1}, A)` from `poptable`
#'  and a marginal `p(X_{K}, A)`from the additional distribution to weight to. Then
#'  `p(X_{1}, .., X_{K - 1}, X_{K}, A) = p(X_{1}, ..., X_{K - 1}, A) x p(X_{K}, A)`.
#'
#' @inheritParams synth_mlogit
#' @param newtable A dataset that contains marginal counts or proportions. Will be
#'  collapsed internally to get simple proportions.
#'
#' @seealso `synth_mlogit()` for a more nuanced model that uses survey data as
#'  the basis of the joint estimation.
#'
#' @importFrom dplyr full_join mutate
#' @export
#'
#' @examples
#'
#' library(dplyr)
#'
#' # suppose we want know the distribution of (age x female) and we know the
#' # distribution of (race), by CD, but we don't know the joint of the two.
#'
#' race_agg <- count(acs_NY, cd, race, wt = count, name = "count")
#'
#' pop_prod <- synth_prod(race ~ age + female,
#'                        poptable = acs_NY,
#'                        newtable = race_agg,
#'                        area_var = "cd")
#'
#' # In this example, we know the true joint. Does it match?
#' pop_val <- left_join(pop_prod,
#'                      count(acs_NY,  cd, age, female, race, wt = count, name = "count"),
#'                      by = c("cd", "age", "female", "race"),
#'                      suffix = c("_est", "_truth"))
#'
#' # AOC's district in the bronx
#' pop_val %>%
#'   filter(cd == "NY-14", age == "35 to 44 years", female == 0) %>%
#'   select(cd, race, count_est, count_truth)
#'
synth_prod <- function(formula,
                       poptable,
                       newtable,
                       area_var,
                       count_var = "count") {
  # formula setup
  list2env(formula_parts(formula), envir = environment())

  # N_Area
  N_area <- collapse_table(newtable, area_var, X_vars = NULL, count_var,
                           report = "counts", new_name = "N_area")

  # margins to start with
  X_p_df <- collapse_table(poptable, area_var, X_vars, count_var,
                           report = "proportions", new_name = "pr_Xs")

  # target proportions
  X_t_df <- collapse_table(newtable, area_var, X_vars = outcome_var, count_var,
                           report = "proportions", new_name = "pr_outcomes")

  # merge and get new counts
  N_area %>% # |A|
    full_join(X_p_df, by = area_var) %>% # |X1| * .... |X{K-1}|
    full_join(X_t_df, by = area_var) %>% # * |XK|
    mutate(!!sym(count_var) := N_area * pr_Xs * pr_outcomes)
}


#' Model synthetic joint distribution with multinomial logit
#'
#' Imputes the counts of a joint distribution of count variables for small areas
#' based on microdata. `synth_smoothfix()` is basically `synth_mlogit()()` which is then corrected by
#' if one knows the marginals.See Details.
#'
#' @details
#'
#' In this setup, the population distribution table (`poptable`)
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
#'
#' @importFrom emlogit emlogit
#' @importFrom dplyr bind_cols as_tibble count sym syms
#' @importFrom tidyr pivot_longer
#' @importFrom stats complete.cases
#'
#' @source
#'  Jonathan P. Kastellec, Jeffrey R. Lax, Michael Malecki, and Justin H.
#'   Phillips (2015). Polarizing the electoral connection: Partisan representation in
#'   Supreme Court confirmation politics. _The Journal of Politics_ 77:3 <http://dx.doi.org/10.1086/681261>
#'
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
#'  synth_acs <- synth_mlogit(pid3 ~ race + age + female,
#'                            microdata = cc18_NY,
#'                            poptable = acs_NY,
#'                            area_var = "cd")
#'
#'  # original (27 districts x 2 sex x 5 age x 6 race categories)
#'  count(acs_NY, cd, female, age, race, wt = count)
#'
#'  # new, modeled (original x 5 party categories)
#'  synth_acs
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


  # ys (in microdata)
  y_m_mat <- model.matrix(outcome_form, microdata)

  # Xs setup microdata
  X_m_mat <- model.matrix(X_form, microdata)[, -1]

  # Xs setup population table -- aggregate up to {A, X_1, ..., X_{K -1 }}
  X_p_df <- collapse_table(poptable, area_var, X_vars, count_var)

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

  # if original factor, make it back into a factor
  # (it was deconstructed in model.matrix)
  if (inherits(microdata[[outcome_var]], "factor")) {
    pred_long[[outcome_var]] <- factor(pred_long[[outcome_var]],
                                       levels = levels(microdata[[outcome_var]]))

  }

  pred_long
}



#' @rdname synth_mlogit
#'
#' @param fix_to A dataset with only marginal counts or proportions of the outcome
#'  in question, by each area. Proportions will be corrected so that the margins
#'  of the synthetic joint will match these, with a simple ratio.
#'
#' @examples
#'
#' # synth_mlogit WITH MARGINS CORRECTION -----
#'
#' library(dplyr)
#' # suppose we want know the distribution of (age x female) and we know the
#' # distribution of (race), by CD, but we don't know the joint of the two.
#'
#' race_agg <- count(acs_NY, cd, race, wt = count, name = "count")
#' pop_syn <- synth_smoothfix(race ~ age + female,
#'                    microdata = cc18_NY,
#'                    fix_to = race_agg,
#'                    poptable = acs_NY,
#'                    area_var = "cd")
#'
#'
#'
#' # In this example, we know the true joint. Does it match?
#' pop_val <- left_join(pop_syn,
#'                      count(acs_NY,  cd, age, female, race, wt = count, name = "count"),
#'                      by = c("cd", "age", "female", "race"),
#'                      suffix = c("_est", "_truth"))
#'
#' # AOC's district in the bronx
#' pop_val %>%
#'   filter(cd == "NY-14", age == "35 to 44 years", female == 0) %>%
#'   select(cd, race, count_est, count_truth)
#' @export
synth_smoothfix <- function(formula,
                            microdata,
                            poptable,
                            fix_to,
                            area_var,
                            count_var = "count") {
  # formula setup
  list2env(formula_parts(formula), envir = environment())

  # estimate cells
  smooth_tbl <- synth_mlogit(formula, microdata, poptable, area_var, count_var)


  # aggregate this to the estimated X_{K}s
  smooth_agg <- collapse_table(smooth_tbl,
                               area_var = area_var,
                               X_vars = outcome_var,
                               count_var = count_var,
                               report = "proportions",
                               new_name = "pr_outcome_mlogit")

  target_agg <- collapse_table(fix_to,
                               area_var = area_var,
                               X_vars = outcome_var,
                               count_var = count_var,
                               report = "proportions",
                               new_name = "pr_outcome_tgt")

  # correction factor
  change_agg <- left_join(smooth_agg,
                          target_agg,
                          by = c(area_var, outcome_var)) %>%
    transmute(
      !!!syms(area_var),
      !!sym(outcome_var),
      correction = pr_outcome_tgt / pr_outcome_mlogit
      )

  # back to estimates
  smooth_tbl %>%
    left_join(change_agg, by = c(area_var, outcome_var)) %>%
    mutate(!!sym(count_var) := !!sym(count_var)*correction) %>%
    select(-pr_pred, -correction) # pr_pred is outdated. correction is redudant with count.

  # fix margins
  # WHY DOES THIS GIVE SAME ANSWER AS THE PROD without survey
  # fixed_tbl <- synth_prod(formula,
  #                         poptable = smooth_agg,
  #                         newtable = fix_to,
  #                         area_var,
  #                         count_var = "n_aggregate")

}
