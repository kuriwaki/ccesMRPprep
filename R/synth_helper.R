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
