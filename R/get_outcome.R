#' Obtain the dataset that contains the question
get_cces_question <- function(.qcode, .year, .q_df = q_df) {

  # data
  # rename outcome to "response"
  cces_resp <- read_rds(glue("data/input/cces/cces_{.year}.rds")) %>%
    select(case_id, response = !!.qcode)

  # turnout is special. If missing, means they didn't turn out.
  if (.qcode == "CL_2018gvm") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), .missing = "No", .default = "Yes"))
  }
  # we wil code Rs as 1 for CL_party
  if (.qcode == "CL_party") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `11` = "Yes", .missing = "No", .default = "No"))
  }
  if (.qcode == "pid7") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `4` = "Yes", .missing = "No", .default = "No"))
  }
  if (.qcode == "ideo5") {
    cces_resp <- cces_resp %>%
      mutate(response = recode(as.integer(response), `3` = "Yes", .missing = "No", .default = "No"))
  }

  # back out qID
  .qID <- filter(.q_df, cces_year == .year, q_code == .qcode) %>%
    pull(qID) %>%
    unique()

  cces_df <- cces_resp %>%
    transmute(year = as.integer(.year),
              case_id = as.integer(case_id),
              qID = .qID,
              response = as_factor(response))

  attr(cces_df, "question") <- .qID

  return(cces_df)
}
