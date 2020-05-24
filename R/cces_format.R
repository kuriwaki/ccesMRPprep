#' Build CCES Data by Joining Component Pieces
#'
#'
#' Produces a person-level dataset with question-level dataset. This will only
#' use the variables necessary for the model, thus its name "slim".  Therefore,
#' is model dependent.
#'
#'
#' @param ccq_df dataframe of outcomes, taken from \link{get_cces_question}. We
#'  currently assume the name for the outcome is named "response".
#' @param ccc_df dataframe of covariates, currently taken only from the cumulative
#'  common content. It should have passed \link{ccc_std_demographics} to be compatible
#'  with CAS.
#' @param cd_df dataframe of district-level predictors, see \link{cd_info_2018} for a sample.
#' @param model_ff the MRP model. Only the variables on the RHS will be kept.
#' @param subset_dist a character for the geography of cd to subset
#'
#' @import dplyr
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
#'                  model_ff = "yes | trials(n_response) ~ age + educ + (1|cd)")
#'   # A tibble: 133 x 7
#'   #    year  case_id qID   response   age             educ cd
#'   #  <int>     <int> <chr> <fct>    <int>        <int+lbl> <chr>
#'   # 1  2018 409942960 TCJA  Support     36 4 [2-Year]       VA-11
#'   # 2  2018 410934028 TCJA  Support     34 5 [4-Year]       UT-4
#'   # 3  2018 410946304 TCJA  Support     62 5 [4-Year]       OK-2
#'   # 4  2018 411717742 TCJA  Oppose      50 1 [No HS]        IL-3
#'   # 5  2018 412022838 TCJA  Oppose      66 5 [4-Year]       OH-8
#'   # 6  2018 412123052 TCJA  Oppose      35 3 [Some College] WA-4
#'   # 7  2018 412161131 TCJA  Support     32 3 [Some College] IN-3
#'   # 8  2018 412260240 TCJA  Support     66 5 [4-Year]       VA-1
#'   # 9  2018 412274191 TCJA  Support     75 6 [Post-Grad]    OR-2
#'   # ...
#'  }
#'
#' @export
cces_join_slim <- function(ccq_df, ccc_df, cd_df, model_ff, subset_dist = NA) {

  vars <- c("year", "case_id", "qID",
            "response",
            all.vars(as.formula(model_ff))[-c(1:2)]) # the outcome is sum(yes) | trials(n)

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

