#' Build CCES Data by Joining Component Pieces
#'
#'
#' Produces a person-level dataset with question-level dataset. This will only
#' use the variables necessary for the model, thus its name "slim".  Therefore,
#' is model dependent.
#'
#'
#' @param ccq_df dataframe of outcomes, taken from \link{get_cces_question}. We
#'  currently assume the name for the outcome is named "response", although this
#'  can be modified with the `y_named_as` argument
#' @param ccc_df dataframe of covariates, currently taken only from the cumulative
#'  common content. It should have passed \link{ccc_std_demographics} to be
#'  compatible with ACS.
#' @param cd_df dataframe of district-level predictors, see \link{cd_info_2018}
#'  for a sample. Currently, we join this to the rest of the data on the column
#'  called \code{"cd"} and \code{"year"}.
#' @param coerce_to_char Whether to coerce the case identifier to character class,
#'  this enables the join.
#' @param keep_vars Variables that will be kept as a cell variable, regardless
#'  of whether it is specified in a formula. Input as character vector.
#' @param subset_dist a character for the geography of cd to subset
#'
#' @inheritParams build_counts
#' @import dplyr
#' @importFrom rlang .data
#' @importFrom stats as.formula
#' @importFrom stringr str_detect
#'
#'
#' @examples
#'  \dontrun{
#'   # need data/input/cces/cces_2018.rds to run this
#'   ccq_tcja <- get_cces_question("CC18_326", "2018", "TCJA")
#'
#'   cces_join_slim(ccq_df = ccq_tcja,
#'                  ccc_df = filter(ccc_samp, year == 2018),
#'                  cd_df = cd_info_2018,
#'                  formula = "response ~ age + educ + (1|cd)")
#'
#'   # alternative - cd and state not in the formula, but cells follow this
#'   cces_join_slim(ccq_df = ccq_tcja,
#'                  ccc_df = filter(ccc_samp, year == 2018),
#'                  cd_df = cd_info_2018,
#'                  keep_vars = c("st", "cd"),
#'                  formula = "response ~ age + educ")
#'
#' # A tibble: 133 x 7
#' #        year case_id   qID   response   age educ             cd
#' #       <dbl> <chr>     <chr> <fct>    <dbl> <dbl+lbl>        <chr>
#' #     1  2018 409942960 TCJA  Support     36 4 [2-Year]       VA-11
#' #     2  2018 410934028 TCJA  Support     34 5 [4-Year]       UT-04
#' #     3  2018 410946304 TCJA  Support     62 5 [4-Year]       OK-02
#' #     4  2018 411717742 TCJA  Oppose      50 1 [No HS]        IL-03
#' #     5  2018 412022838 TCJA  Oppose      66 5 [4-Year]       OH-08
#' #     6  2018 412123052 TCJA  Oppose      35 3 [Some College] WA-04
#' #     7  2018 412161131 TCJA  Support     32 3 [Some College] IN-03
#' #     8  2018 412260240 TCJA  Support     66 5 [4-Year]       VA-01
#' #     9  2018 412274191 TCJA  Support     75 6 [Post-Grad]    OR-02
#'  }
#'
#' @export
cces_join_slim <- function(ccq_df,
                           ccc_df,
                           cd_df,
                           formula,
                           coerce_to_char = TRUE,
                           keep_vars = NULL,
                           subset_dist = NA) {

  y_named_as <- all.vars(as.formula(formula))[1L]

  vars <- c("year", "case_id", "qID",
            y_named_as,
            keep_vars,
            # the outcome is reponse
            all.vars(as.formula(formula))[-c(1)])

  if (coerce_to_char) {
    ccq_df$case_id <- as.character(ccq_df$case_id)
    ccc_df$case_id <- as.character(ccc_df$case_id)
  }

  joined_df <- ungroup(ccc_df) %>%
    inner_join(ungroup(ccq_df), by = c("case_id", "year")) %>%
    left_join(cd_df, by = c("cd", "year"))

  # if party reg, also update by only giving 1s to active registrants
  if (attr(ccq_df, "question") == "CL_party") {
  }

  # select only necessary models ---
  df_sel <- select(joined_df, !!!vars)

  # subset to state
  if (!is.na(subset_dist))
    df_sel <- filter(df_sel, str_detect(.data$cd, subset_dist))

  attr(df_sel, "question") <- attr(ccq_df, "question")
  df_sel
}

