


#' Obtain a ACS tabulation from tidycensus
#'
#' This loads ACS counts via tidycensus and gives them additional labels and
#' renames some variables to later merge with CCES-based regression models.
#'
#' @param varlist a vector of variable codes to pull
#' @param .year The year of the ACS to get. Because of data availabilities, this is
#'  capped to 2010-2018.
#' @param varlab_df a dataframe that appends the categories based on the varcode
#' @param .geography the type of geography to pull. Currently only supports
#'  \code{"congressional district"}.
#'
#' @details To run this, you need to have a API token to run \link[tidycensus]{get_acs}.
#'  See \link[tidycensus]{census_api_key} for details.
#'
#' @seealso  \link{get_acs_cces}
#'
#' @importFrom tidycensus get_acs
#' @importFrom stats as.formula
#' @importFrom magrittr `%>%`
#' @importFrom stringr str_detect
#' @importFrom tidyr replace_na
#' @importFrom haven is.labelled as_factor
#' @import dplyr
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  fm_brm <- yes | responses(n_cell) ~  age + gender + educ + pct_trump + (1|cd)
#'  acs_tab <- get_acs_cces(
#'               varlist = acscodes_age_sex_educ,
#'               varlab_df = acscodes_df,
#'              .year = 2018)
#' #   year  cd    gender age            educ         race  count count_moe
#' #   <dbl> <chr> <fct>  <fct>          <fct>        <fct> <dbl>     <dbl>
#' # 1  2018 AL-01 Male   18 to 24 years HS or Less   NA      703       240
#' # 2  2018 AL-01 Male   18 to 24 years HS or Less   NA     5665       581
#' # 3  2018 AL-01 Male   18 to 24 years HS or Less   NA    11764       747
#' # 4  2018 AL-01 Male   18 to 24 years Some College NA     9528       750
#' # 5  2018 AL-01 Male   18 to 24 years Some College NA     1389       355
#' # 6  2018 AL-01 Male   18 to 24 years 4-Year       NA     1519       276
#'
#'
#'  poststrat <-  get_poststrat(acs_tab, cd_info_2018, fm_brm)
#' }
#'
get_acs_cces <- function(varlist, varlab_df,
                         .year = 2018,
                         .geography =  "congressional district") {

  get_acs(geography = .geography,
          year = min(max(.year, 2010), 2018),
          survey = "acs5",
          variable = varlist,
          geometry = FALSE) %>%
    filter(!str_detect(NAME, "Puerto Rico")) %>%
    rename(
      count = estimate,
      count_moe = moe,
      cdid = GEOID,
    ) %>%
    mutate(count = replace_na(count, 0)) %>%
    left_join(varlab_df, by = "variable") %>%
    mutate(year = .year,
           cd = cd_from_acs(NAME)) %>%
    mutate_if(haven::is.labelled, haven::as_factor) %>%
    select(year, cd, matches("(gender|age|educ|race)"), count, count_moe)
}

#' Formats a post-strat table from ACS and district-level data
#'
#'
#' @param cleaned_acs An output of \link{get_acs_cces}. The count of people in
#' each cell must be under the variable \code{count}
#' @param dist_data Distrit-level (in this case congressional district-level) information
#' to merge in
#' @param model_ff the model formula used to fit the multilevel regression model.
#' Currently only expects an binomial, of the form \code{y|responses(n) ~ x1 + x2 + (1|x3)}.
#' Only the RHS will be used but the LHS is necessary.
#'
#'
#' @importFrom tidycensus get_acs
#' @importFrom stats as.formula
#' @importFrom magrittr `%>%`
#' @importFrom stringr str_detect
#' @importFrom tidyr replace_na
#' @import dplyr
#'
#' @export
#'
#' @seealso \link{get_acs_cces}
#'
#' @examples
#' \dontrun{
#'  fm_brm <- yes | responses(n_cell) ~  age + gender + educ + pct_trump + (1|cd)
#'  acs_tab <- get_acs_cces(
#'               varlist = acscodes_age_sex_educ,
#'               varlab_df = acscodes_df,
#'              .year = 2018)
#'
#' poststrat <-  get_poststrat(acs_tab, cd_info_2018, fm_brm)
#' head(poststrat)
#' #   age            gender educ       pct_trump cd    count
#' #   <fct>          <fct>  <fct>          <dbl> <chr> <dbl>
#' # 1 18 to 24 years Male   HS or Less     0.049 NY-15 24216
#' # 2 18 to 24 years Male   HS or Less     0.054 NY-13 18014
#' # 3 18 to 24 years Male   HS or Less     0.068 CA-13 14153
#' # 4 18 to 24 years Male   HS or Less     0.07  PA-03 15750
#' # 5 18 to 24 years Male   HS or Less     0.087 CA-12  6270
#' # 6 18 to 24 years Male   HS or Less     0.092 IL-07 18734
#' }
#'
get_poststrat <- function(cleaned_acs, dist_data, model_ff) {

  xvars <- setdiff(all.vars(as.formula(model_ff))[-c(1:2)], "response")
  xvar_regex <- glue("^({str_c(xvars, collapse = '|')})$")

  cleaned_acs %>%
    left_join(dist_data) %>%
    filter_at(vars(matches(xvar_regex)), all_vars(!is.na(.))) %>%
    group_by(!!!syms(xvars), add = TRUE) %>%
    summarize(count = sum(count, na.rm = TRUE)) %>%
    filter(count > 0) %>%
    ungroup()
}



#' Format CD format from ACS
#'
#' Convert ACS' cd labels to the form "AK-01".
#'
#' @param vec a vector of strings from the ACS congressional district naming
#'
#' @importFrom stringr str_extract str_replace str_pad
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#' @importFrom dplyr add_row
#' @importFrom glue glue
#'
#' @examples
#'  cd_from_acs("Congressional District 32 (115th Congress), California")
#'
#'
#' @export
cd_from_acs <- function(vec) {

  st_to_state <- tibble(st = state.abb, state = state.name) %>%
    add_row(st = "DC", state = "District of Columbia")

  distnum <- vec %>%
    str_extract("([0-9]+|at Large)") %>%
    str_replace("at Large", "1") %>%
    str_pad(width = 2, pad = "0")
  cong <- vec %>% str_extract("1[01][0-9]")
  states <- vec %>% str_extract("(?<=,\\s)[A-z\\s]+")
  st <- map_chr(states, function(x) st_to_state$st[x == st_to_state$state])

  as.character(glue("{st}-{distnum}"))
}
