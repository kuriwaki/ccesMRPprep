#' Obtain a ACS tabulation from tidycensus
#'
#' This loads ACS counts via tidycensus and gives them additional labels and
#' renames some variables to later merge with CCES-based regression models.
#'
#' @param varlist a vector of variable codes to pull
#' @param varlab_df a dataframe that appends the categories based on the varcode
#' @param year The year of the ACS to get. Because of data availability limitations, this is
#'  capped to 2010-2018.
#' @param dataset Which type of ACS to get. Defaults to `"acs1"` for ACS-5 year.
#'  Use `"acs5"` for 5-year.
#' @param states A vector of states to subset to. Gets passed onto the new `state`
#'  argument in `tidycensus::get_acs()`, which defaults to NULL.
#' @param geography the type of geography to pull. Currently only supports
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
#' @importFrom rlang .data
#' @importFrom stringr str_detect str_sub
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
#'               year = 2018)
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
get_acs_cces <- function(varlist,
                         varlab_df = ccesMRPprep::acscodes_df,
                         year = 2018,
                         states = NULL,
                         dataset = "acs1",
                         geography =  "congressional district") {

  acs_df <- get_acs(geography = geography,
                    year = min(max(year, 2010), as.numeric(str_sub(Sys.time(), 1, 4))),
                    survey = dataset,
                    variables = varlist,
                    state = states,
                    geometry = FALSE) %>%
    filter(!str_detect(.data$NAME, "Puerto Rico")) %>%
    rename(
      count = .data$estimate,
      count_moe = .data$moe,
      cdid = .data$GEOID,
    ) %>%
    mutate(count = replace_na(.data$count, 0))

  acs_lbl <- acs_df %>%
    left_join(varlab_df, by = "variable") %>%
    mutate(year = year,
           cd = std_acs_cdformat(.data$NAME)) %>%
    mutate_if(haven::is.labelled, haven::as_factor) %>%
    mutate(age = coalesce(.data$age_5, .data$age_10)) %>%
    select(acscode = .data$variable,
           .data$year,
           .data$cd,
           matches("(gender|female|age|educ|race)"), .data$count, .data$count_moe) %>%
      select(-matches("age_(5|10)"))

  acs_lbl
}


#' Obtain CVAP proportions by race
#'
#' Returns the Citizen Voting Age Population by Congressional District. A custom
#'  call to `get_acs_cces`. In the output, `cvap_total` is the total CVAP of
#'  all races, `cvap_race` is the count of CVAP for the given race, and `cvap_frac`
#'  is the fraction.
#'
#' Future versions will allow CVAP race fractions by geographies other than CD.
#'
#' @param race Race of interest. Either `"white"` (for non-Hispanic Whites),
#'  `"hispanic"`, `"black"`, `"native"` (for Native Americans including American
#'   Indians and Alaskan Natives), `"asian"`.
#' @inheritParams get_acs_cces
#' @seealso \link{get_acs_cces}
#'
#'
#' @examples
#'  get_acs_cvap("white")
#'
#' @importFrom stringr str_c
#' @import dplyr
#' @export
get_acs_cvap <- function(race = "white",
                         varlab_df = ccesMRPprep::acscodes_df,
                         year = 2018,
                         states = NULL,
                         dataset = "acs1") {

  race_v <- switch(race, white = "H", hispanic = "I", asian = "D", black = "B", native = "C")
  # 9 is Native, 11 is foreign born naturalized. 9, 11 is Male, 20, 22 is Female
  v_denom <- str_c("B05003", c("009", "011", "020", "022"), sep = "_")
  # same but for a specific race. numerator
  v_numer <- str_c(str_c("B05003", race_v), c("009", "011", "020", "022"),
                   sep = "_")
  df_acs <- get_acs_cces(c(v_denom, v_numer),
                         varlab_df,
                         year,
                         states,
                         dataset,
                         geography = "congressional district")

  df_denom <- filter(df_acs, acscode %in% v_denom) %>% group_by(year, cd) %>% summarize(cvap_total = sum(count), .groups = "drop")
  df_numer <- filter(df_acs, acscode %in% v_numer) %>% group_by(year, cd) %>% summarize(cvap_race = sum(count), .groups = "drop")

  left_join(df_numer, df_denom, by = c("year", "cd")) %>%
    ungroup() %>%
    mutate(race = race,
           cvap_frac = cvap_race / cvap_total) %>%
    relocate(year, cd, cvap_total, race, cvap_race, cvap_frac)
}

#' Formats a post-strat table from ACS and district-level data
#'
#'
#' @param cleaned_acs An output of \link{get_acs_cces}. The count of people in
#' each cell must be under the variable \code{count}
#' @param dist_data District-level (in this case congressional district-level) information
#' to merge in
#' @param formula the model formula used to fit the multilevel regression model, with one
#' term on the LHS: e.g. \code{y ~ x1 + x2 + (1|x3)}.
#' Only the RHS will be used but the LHS is necessary for now.
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
#'  fm_brm <- response ~  age + gender + educ + pct_trump + (1|cd)
#'  acs_tab <- get_acs_cces(
#'               varlist = acscodes_age_sex_educ,
#'               varlab_df = acscodes_df,
#'              year = 2018)
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
get_poststrat <- function(cleaned_acs, dist_data = NULL, formula) {

  xvars <- setdiff(all.vars(as.formula(formula))[-1], "response")
  xvar_regex <- glue("^({str_c(xvars, collapse = '|')})$")

  if (!is.null(dist_data))
    cleaned_acs <- left_join(dist_data, cleaned_acs)

  cleaned_acs %>%
    filter(across(matches(xvar_regex), ~!is.na(.x))) %>%
    group_by(!!!syms(xvars), .add = TRUE) %>%
    summarize(count = sum(count, na.rm = TRUE), .groups = "drop") %>%
    filter(count > 0)
}



#' Format CD format from ACS
#'
#' Convert ACS' cd labels to the form "AK-01".
#'
#' @param vec a vector of strings from the ACS congressional district naming
#'
#' @importFrom stringr str_extract str_replace str_pad
#' @importFrom furrr future_map_chr
#' @importFrom tibble tibble
#' @importFrom dplyr add_row
#' @importFrom glue glue
#'
#' @examples
#'  std_acs_cdformat("Congressional District 32 (115th Congress), California")
#'
#'
#' @export
std_acs_cdformat <- function(vec) {

  st_to_state <- tibble(st = datasets::state.abb, state = datasets::state.name) %>%
    add_row(st = "DC", state = "District of Columbia")

  distnum <- vec %>%
    str_extract("([0-9]+|at Large)") %>%
    str_replace("at Large", "1") %>%
    str_pad(width = 2, pad = "0")

  cong <- vec %>% str_extract("1[01][0-9]")
  states <- vec %>% str_extract("(?<=,\\s)[A-z\\s]+")
  st <- future_map_chr(states, function(x) st_to_state$st[x == st_to_state$state])

  as.character(glue("{st}-{distnum}"))
}
