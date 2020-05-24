

#' Join and slim person-level dataset with question-level dataset
#'
#' @param subset_dist a character for the geography of cd to subset
#'
join_slim <- function(ccq_df, ccc_df, cd_df, formula, subset_dist = NA) {

  vars <- c("year", "case_id", "qID",
            "response", # assume this is the name for the outcome
            all.vars(as.formula(formula))[-c(1:2)]) # the outcome is sum(yes) | trials(n)

  joined_df <- left_join(ungroup(ccc_df), ungroup(ccq_df), by = c("case_id", "year")) %>%
    left_join(cd_df, by = "cd")

  # if party reg, also update by only giving 1s to active registrants
  if (attr(ccq_df, "question") == "CL_party") {

  }

  # select only necessary models ---
  df_sel <- select(joined_df, !!!vars)

  # subset to state
  if (!is.na(subset_dist))
    df_sel <- filter(df_sel, str_detect(cd, subset_dist))

  attr(df_sel, "question") <- attr(ccq_df, "question")
  df_sel
}

