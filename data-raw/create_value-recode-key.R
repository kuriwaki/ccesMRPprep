library(dplyr)
library(tibble)
library(labelled)

# Recode variable df ------
ages5  <- c("18 to 24 years",
            "25 to 34 years",
            "35 to 44 years",
            "45 to 64 years",
            "65 years and over")
age5_lbl <- setNames(1:5L, ages5)
age5_key <- tibble(age_chr = ages5,
                   age = labelled(1:5L, age5_lbl))

ages10 <- c("18 and 19 years",
            "20 to 24 years",
            "25 to 29 years",
            "30 to 34 years",
            "35 to 44 years",
            "45 to 54 years",
            "55 to 64 years",
            "65 to 74 years",
            "75 to 84 years",
            "85 years and over")
age10_key <- tibble(age_chr = ages10) %>%
  mutate(age_num = case_when(
    age_chr %in% ages10[1:2] ~ 1L,
    age_chr %in% ages10[3:4] ~ 2L,
    age_chr %in% ages10[5] ~ 3L,
    age_chr %in% ages10[6:7] ~ 4L,
    age_chr %in% ages10[8:10] ~ 5L
  )) %>%
  mutate(age = labelled(age_num, age5_lbl))

# Education ----
educ_lbl <- setNames(1L:7L,
                     c("Less than 9",
                       "No HS",
                       "High School Graduate",
                       "Some College",
                       "2-Year",
                       "4-Year",
                       "Post-Grad"))
educ_lbl_clps <- setNames(1L:4L,
                          c("HS or Less", "Some College", "4-Year", "Post-Grad"))


## CCES lumps the first two, and let's also lump the 2-year
cces_edlbl <- tibble(educ_cces = names(educ_lbl)[2:7],
                     educ = labelled(c(1, 1, 2, 2, 3, 4), educ_lbl_clps))

educ_key  <- tribble(
  ~num, ~educ_chr, ~educ_cces,
  1L, "Less than 9th grade", "No HS",
  2L, "9th to 12th grade no diploma", "No HS",
  3L, "High school graduate (includes equivalency)", "High School Graduate",
  4L, "Some college no degree", "Some College",
  5L, "Associate's degree", "2-Year",
  6L, "Bachelor's degree", "4-Year",
  7L, "Graduate or professional degree", "Post-Grad"
) %>%
  left_join(cces_edlbl, by = "educ_cces") %>%
  select(-num)

# Gender ----
gender_key <- tibble(gender_chr = c("Male", "Female"),
                     gender = labelled(1:2L, c(Male = 1, Female = 2)))

# Race -----
my_racelbl <- setNames(1L:5L, c("White", "Black", "Hispanic", "Asian", "All Other"))

race_cces_key <- structure(list(
  race_cces = structure(1:5,
                        labels = structure(1:5, .Names = c("White", "Black", "Hispanic", "Asian", "All Other")), class = "haven_labelled"),
  race_cces_chr = c("White", "Black", "Hispanic", "Asian", "All Other")),
  class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -5L))

# this was created from cces cumulative file
# cc18 <- read_rds("data/input/CCES/by-person_cces-2018.Rds")
# race_cces_key <- distinct(cc18, race) %>%
#   mutate(race_cces_chr = as.character(as_factor(race))) %>%
#   rename(race_cces = race) %>%
#   arrange(race_cces)


race_key <- tribble(
  ~race_5, ~race_cces_chr, ~race_acs,
  1L, "White", "WHITE ALONE, NOT HISPANIC OR LATINO",
  2L, "Black", "BLACK OR AFRICAN AMERICAN ALONE",
  3L, "Hispanic", "HISPANIC OR LATINO",
  4L, "Asian", "ASIAN ALONE",
  4L, "Asian", "NATIVE HAWAIIAN AND OTHER PACIFIC ISLANDER ALONE",
  5L, "Native American", "AMERICAN INDIAN AND ALASKA NATIVE ALONE",
  5L, "Mixed", "TWO OR MORE RACES",
  5L, "Other", "SOME OTHER RACE ALONE",
  5L, "Middle Eastern", NA,
) %>%
  left_join(race_cces_key, by = "race_cces_chr") %>%
  mutate(race = labelled(race_5, my_racelbl))

# ACS variant
educ_key2 <- educ_key %>%
  mutate(
    educ_chr = replace(educ_chr, educ_chr == "9th to 12th grade no diploma", "9th to 12th grade, no diploma"),
    educ_chr = replace(educ_chr, educ_chr == "Some college no degree", "Some college, no degree")
  )

usethis::use_data(age5_key, age10_key, gender_key, educ_key, educ_key2, race_key,
                  overwrite = TRUE)
