# Written by Claude Code
library(tidyverse)
library(tidycensus)

# Seed for get_acs_race_cells(): 2020 Census DHC, United States. P12A White alone, P12B Black alone,
# P12H Hispanic, P12I non-Hispanic White alone, P12J non-Hispanic Black alone. Lines 3-25 are male,
# 27-49 female.
dhc <- map(c("P12", "P12A", "P12B", "P12H", "P12I", "P12J"),
           \(x) get_decennial("us", table = x, year = 2020, sumfile = "dhc")) |>
  list_rbind()

age_bins <- tibble(line = 3:25,
                   age = rep(c("Under 5 years", "5 to 9 years", "10 to 14 years", "15 to 17 years",
                               "18 to 24 years", "25 to 34 years", "35 to 44 years", "45 to 64 years",
                               "65 years and over"),
                             times = c(1, 1, 1, 1, 4, 2, 2, 5, 6)))

# Black alone by Hispanic origin among people other than White alone, by sex and age
black_hispanic_seed <- dhc |>
  mutate(table = str_remove(variable, "_.*"), line = as.integer(str_sub(variable, -4, -2)),
         female = as.integer(line >= 27), line = if_else(female == 1L, line - 24L, line)) |>
  inner_join(age_bins, by = "line", relationship = "many-to-one") |>
  summarize(value = sum(value), .by = c(age, female, table)) |>
  pivot_wider(names_from = table, values_from = value) |>
  mutate(black_hispanic = P12B - P12J,
         black_other = P12J,
         nonblack_hispanic = P12H - (P12A - P12I) - black_hispanic,
         nonblack_other = P12 - P12A - P12B - nonblack_hispanic,
         log_odds_ratio = log(black_hispanic * nonblack_other / (black_other * nonblack_hispanic))) |>
  transmute(age = factor(age, levels = unique(age_bins$age)), female, log_odds_ratio) |>
  arrange(female, age)

stopifnot(nrow(black_hispanic_seed) == 18, all(is.finite(black_hispanic_seed$log_odds_ratio)))

# Paste into `black_hispanic_seed` in R/get_acs-race-cells.R (male ages, then female ages)
dput(round(black_hispanic_seed$log_odds_ratio, 2))
