#' Get one column of outcome questions for each model
#'
#' @param qcode A string, the variable name of the outcome variable of interest,
#'  exactly as it appears in the CCES dataset. Together with \code{year}, uniquely identifies
#'  the outcome question data
#' @param year A string for the year the question was asked, which will correspond
#' to the dataset. If using a dataset from the cumulative, set to \code{"cumulative"}.
#' Together with \code{qcode}, uniquely identifies the outcome question data
#' @param qID A string, the user's unique name for the question. For example, we use the
#'  syntax in our question table.
#' @param data_dir A path for the directory where flat files for the CCES common content is
#'  stored.  Currently the data must be of the form `cces_{year}.rds`  in that directory
#'  to be read in. For a general script that uses \link{get_cces_dv}, see
#'  <https://github.com/kuriwaki/CCES_district-opinion/blob/master/R/initialize-cces-downloads.R>
#'  which is still private.
#'
#' @details This transformation currently only supports Yes/No questions. For some common
#'  ordinal questions that ca n be, with manual recodes, be set to a Yes/No question,
#'  there is some hard-coding of the recode in the question. In the future, this should be
#'  defined outside of the function in a taxanomy.
#'
#' @return A three-column dataframe with the columns
#' \describe{
#' \item{year}{The year}
#' \item{case_id}{The respondent identifier within year}
#' \item{qID}{The question ID}
#' \item{response}{The outcome question, of class factor}
#' }
#' The object will also have an attribute called \code{question}, which will save
#' the question identifier \code{qID}
#'
#' @import dplyr
#' @importFrom magrittr `%>%`
#' @importFrom readr read_rds
#' @importFrom glue glue
#' @importFrom fs path
#'
#'
#' @examples
#'  \dontrun{
#'   # need data/input/cces/cces_2018.rds to run this
#'   get_cces_question(qcode = "CC18_326", year = "2018", qID = "TCJA")
#'
#'   # A tibble: 60,000 x 4
#'   # year   case_id qID   response
#'   # <int>     <int> <chr> <fct>
#'   # 1  2018 123464282 TCJA  Support
#'   # 2  2018 170169205 TCJA  Support
#'   # 3  2018 175996005 TCJA  Support
#'   # 4  2018 176818556 TCJA  Oppose
#'   # 5  2018 202120533 TCJA  Oppose
#'   # 6  2018 226449148 TCJA  Oppose
#'   # 7  2018 238205342 TCJA  Oppose
#'   # 8  2018 238806466 TCJA  Support
#'   # 9  2018 267564481 TCJA  Support
#'   # … with 59,991 more rows
#'  }
#'
#' @export
get_cces_question <- function(qcode, year, qID, data_dir = "data/input/cces") {

  # data
  # rename outcome to "response"
  cces_resp <- read_rds(path(data_dir, glue("cces_{year}.rds"))) %>%
    select(case_id, response = !!qcode)

  # turnout is special. If missing, means they didn't turn out.
  if (qcode == "CL_2018gvm") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), .missing = "No", .default = "Yes"))
  }
  # we wil code Rs as 1 for CL_party
  if (qcode == "CL_party") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `11` = "Yes", .missing = "No", .default = "No"))
  }
  if (qcode == "pid7") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `4` = "Yes", .missing = "No", .default = "No"))
  }
  if (qcode == "ideo5") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `3` = "Yes", .missing = "No", .default = "No"))
  }

  cces_df <- cces_resp %>%
    transmute(year = as.integer(year),
              case_id = as.integer(case_id),
              qID = qID,
              response = as_factor(response))

  attr(cces_df, "question") <- qID

  return(cces_df)
}
