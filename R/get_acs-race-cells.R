# Written by Codex

# Allocate the observed Black–Hispanic overlap over age and sex ----

allocate_black_hispanic <- function(black, hispanic, population, district_overlap,
                                    log_odds_seed = 0) {
  # Within each age-sex cell the non-White population is a 2 x 2 table:
  # Black alone / other, crossed with Hispanic / non-Hispanic. The race and
  # origin margins are observed. B03002 supplies the Black-Hispanic overlap
  # for the district across ALL ages, including the children in this function.
  log_odds_seed <- rep_len(log_odds_seed, length(black))
  stopifnot(all(is.finite(c(black, hispanic, population, log_odds_seed))),
            all(black >= 0 & black <= population),
            all(hispanic >= 0 & hispanic <= population))
  lower <- pmax(0, black + hispanic - population)
  upper <- pmin(black, hispanic)
  target <- unique(district_overlap)
  stopifnot(length(target) == 1L, target >= sum(lower), target <= sum(upper))
  if (target == sum(lower)) return(lower)
  if (target == sum(upper)) return(upper)

  # Rake a seed table to the observed margins. Raking keeps each cell's seed
  # odds ratio up to one factor per district, so the seed enters only through
  # `log_odds_seed`. A flat seed (0) gives one odds ratio across age and sex.
  # Given each cell's odds ratio, the margins determine its 2 x 2 table.
  free <- upper > lower
  black_left <- black[free] - lower[free]
  hispanic_left <- hispanic[free] - lower[free]
  opposite <- abs(population[free] - black[free] - hispanic[free])
  overlap <- function(log_odds_ratio) {
    odds <- exp(log_odds_ratio + log_odds_seed[free])
    # Solve odds * (black_left - x) * (hispanic_left - x) = x * (opposite + x)
    # for x, the overlap in excess of the lower bound.
    linear <- opposite + odds * (black_left + hispanic_left)
    discriminant <- opposite^2 + 2 * opposite * odds * (black_left + hispanic_left) +
      (odds * (black_left - hispanic_left))^2 + 4 * odds * black_left * hispanic_left
    result <- lower
    result[free] <- lower[free] +
      2 * odds * black_left * hispanic_left / (linear + sqrt(discriminant))
    result
  }
  log_odds <- stats::uniroot(function(x) sum(overlap(x)) - target,
                      interval = c(-60, 60), tol = 1e-12)$root
  result <- pmin(upper, pmax(lower, overlap(log_odds)))
  stopifnot(abs(sum(result) - target) < 1e-5)
  result
}

# 2020 Census, United States, DHC tables P12, P12A, P12B, P12H, P12I and P12J:
# log odds ratio of Black alone by Hispanic origin among people other than White
# alone, by age and sex. data-raw/create_black-hispanic-seed.R computes it.
seed_ages <- c("Under 5 years", "5 to 9 years", "10 to 14 years", "15 to 17 years", "18 to 24 years",
               "25 to 34 years", "35 to 44 years", "45 to 64 years", "65 years and over")
black_hispanic_seed <- tibble(
  age = rep(seed_ages, 2), female = rep(0:1, each = 9),
  log_odds_seed = c(-3.13, -3.28, -3.41, -3.55, -3.64, -3.77, -4.14, -4.50, -4.45,
                    -3.15, -3.29, -3.40, -3.53, -3.56, -3.59, -3.92, -4.33, -4.47)
)

# ACS five-year district race cells ----

#' Adult ACS population by district, age, sex and mutually exclusive race
#'
#' @param year End year of the five-year ACS estimates. District boundaries
#'   correspond to the ACS release for that year.
#' @param states State abbreviations or state FIPS codes accepted by
#'   [tidycensus::get_acs()]. The default retrieves the 50 states.
#' @returns A tibble with one row per `cd`, `age`, `female` and `race`.
#'   At-large voting districts use district 01. The five adult age groups
#'   run from 18–24 to 65 and older. `female` is coded 0 for male and 1 for
#'   female. The `race` levels are White (non-Hispanic White alone), Black
#'   (non-Hispanic Black alone), Hispanic (any race), and Other (remaining
#'   non-Hispanic adults). `count` is the estimated population and may be
#'   fractional. The output includes zero-count cells.
#' @details The ACS publishes Hispanic origin across races. Its sex-by-age
#'   tables give Hispanic, non-Hispanic White alone, White alone and Black
#'   alone counts. Table B03002 gives the Black-alone Hispanic overlap for
#'   each district across all ages. To allocate that overlap across age and
#'   sex among people other than White alone, the function rakes a 2020 Census
#'   national seed to these margins. Each age-sex cell keeps the national
#'   Black-by-Hispanic odds ratio for its age and sex, times one factor per
#'   district that matches B03002. Children contribute to this allocation
#'   before the adult cells are selected. The four counts sum to the ACS
#'   population in each age-sex cell.
#'
#'   [ACS sex by age (Black alone)](https://api.census.gov/data/2024/acs/acs5/groups/B01001B.html)
#'   and [ACS Hispanic origin by race](https://api.census.gov/data/2024/acs/acs5/groups/B03002.html)
#'   describe the source tables.
#' @seealso [get_acs_cces()], [acscodes_age_sex_race]
#' @examples
#' \dontrun{
#' get_acs_race_cells(year = 2024, states = "PA")
#' }
#' @export
get_acs_race_cells <- function(year = 2018, states = NULL) {
  # B01001A/B include Hispanic respondents, H is non-Hispanic White alone,
  # and I contains all Hispanics. B03002_014 is Hispanic and Black alone.
  # https://api.census.gov/data/2024/acs/acs5/groups/B03002.html
  race_tables <- c(B01001A = "white_alone", B01001B = "black_alone",
                   B01001H = "White", B01001I = "Hispanic")
  # B01001 and its race iterations have the same four under-18 age bins.
  # Female cells start at row 27 in B01001 and row 18 in its iterations.
  lookup <- ccesMRPprep::acscodes_df |>
    mutate(acs_table = stringr::str_remove(.data$variable, "_.*"),
           line = as.integer(str_sub(.data$variable, -3)),
           child_bin = .data$line - case_when(.data$female == 0 ~ 2L, .data$acs_table == "B01001" ~ 26L,
                                        TRUE ~ 17L),
           child = .data$child_bin %in% 1:4,
           adult_age = haven::as_factor(coalesce(.data$age_5, .data$age_10))) |>
    filter((.data$acs_table %in% names(race_tables) & (.data$child | !is.na(.data$age_10))) |
           (.data$acs_table == "B01001" & .data$child) |
           (.data$acs_table == "B15001" & !is.na(.data$age_5) & is.na(.data$educ))) |>
    transmute(variable = .data$variable, female = .data$female,
              age = if_else(is.na(.data$adult_age), seed_ages[match(.data$child_bin, 1:4)],
                            as.character(.data$adult_age)),
              measure = coalesce(unname(race_tables[.data$acs_table]), "total"))

  variables <- c(lookup$variable, "B15001_001", "B03002_004", "B03002_014")
  fetch_state <- function(state) {
    get_acs(geography = "congressional district", state = state, year = year,
            survey = "acs5", variables = variables)
  }
  estimates <- if (length(states) > 1L) bind_rows(lapply(unique(states), fetch_state)) else fetch_state(states)
  estimates <- estimates |>
    mutate(st_fips = as.integer(str_sub(.data$GEOID, 1, 2))) |>
    inner_join(select(ccesMRPprep::states_key, "st_fips", "st"),
               by = "st_fips", relationship = "many-to-one") |>
    # ZZ denotes areas outside a congressional district, and 00 denotes at large.
    filter(.data$st %in% datasets::state.abb, !stringr::str_ends(.data$GEOID, "ZZ")) |>
    mutate(district = recode(str_sub(.data$GEOID, 3, 4), `00` = "01"),
           cd = as.character(glue::glue("{st}-{district}")))
  stopifnot(all(is.finite(estimates$estimate)), all(estimates$estimate >= 0),
            !anyDuplicated(estimates[c("cd", "variable")]),
            all(table(estimates$cd) == nrow(lookup) + 3))
  district_totals <- estimates |>
    filter(.data$variable %in% c("B15001_001", "B03002_004", "B03002_014")) |>
    select("cd", "variable", "estimate") |>
    tidyr::pivot_wider(names_from = "variable", values_from = "estimate")
  cells <- estimates |>
    inner_join(lookup, by = "variable", relationship = "many-to-one") |>
    summarize(count = sum(.data$estimate), .by = c("cd", "age", "female", "measure")) |>
    tidyr::pivot_wider(names_from = "measure", values_from = "count") |>
    left_join(district_totals, by = "cd", relationship = "many-to-one") |>
    left_join(black_hispanic_seed, by = c("age", "female"), relationship = "many-to-one") |>
    mutate(black_hispanic = allocate_black_hispanic(
             .data$black_alone, .data$Hispanic - (.data$white_alone - .data$White),
             .data$total - .data$white_alone, .data$B03002_014, .data$log_odds_seed
           ),
           Black = .data$black_alone - .data$black_hispanic,
           Other = .data$total - .data$White - .data$Hispanic - .data$Black, .by = "cd")

  age_levels <- levels(haven::as_factor(ccesMRPprep::age5_key$age))
  checks <- cells |>
    summarize(n_cells = n(), black_error = sum(.data$Black) - first(.data$B03002_004),
              vap_error = sum(.data$total[.data$age %in% age_levels]) - first(.data$B15001_001), .by = "cd")
  stopifnot(nrow(checks) > 0, all(checks$n_cells == 18),
            all(abs(checks$black_error) < 1e-5), all(checks$vap_error == 0),
            all(cells$Other >= -1e-8))
  cells |>
    filter(.data$age %in% age_levels) |>
    select("cd", "age", "female", "White", "Black", "Hispanic", "Other") |>
    tidyr::pivot_longer(c("White", "Black", "Hispanic", "Other"), names_to = "race", values_to = "count") |>
    mutate(age = factor(.data$age, levels = age_levels),
           race = factor(.data$race, levels = c("White", "Black", "Hispanic", "Other")),
           count = pmax(0, .data$count))
}
