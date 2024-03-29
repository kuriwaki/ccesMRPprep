library(ccesMRPprep)
library(tidycensus)
library(tidyverse)
library(glue)

# categories in ACS
ages  <- c("18 to 24 years",
           "25 to 34 years",
           "35 to 44 years",
           "45 to 64 years",
           "65 years and over",
           "18 and 19 years",
           "20 to 24 years",
           "25 to 29 years",
           "30 to 34 years",
           "35 to 44 years",
           "45 to 54 years",
           "55 to 64 years",
           "65 to 74 years",
           "75 to 84 years",
           "85 years and over")
education <- c("Less than high school diploma",
               "Nursery to 4th grade",
               "No schooling completed",
               "Less than 9th grade",
               "5th and 6th grade",
               "7th and 8th grade",
               "9th grade",
               "10th grade",
               "11th grade",
               "12th grade, no diploma",
               "Less than 9th grade",
               "Less than high school graduate",
               "9th to 12th grade,? no diploma",
               "High school graduate \\(includes equivalency\\)",
               "High school graduate, GED, or alternative",
               "Some college",
               "Some college or associate's degree",
               "Associate's degree",
               "Bachelor's degree$",
               "Doctorate degree",
               "Master's degree",
               "Professional school degree",
               "Graduate or professional degree",
               "Bachelor's degree or higher")
races <- c("White alone, not Hispanic or Latino",
           "Hispanic or Latino",
           "Black or African American alone",
           "American Indian and Alaska Native alone",
           "Asian alone",
           "Native Hawaiian and Other Pacific Islander alone",
           "Some other race alone",
           "Two or more races" #,
           # "Two or more races!!Two races including Some other race",
           # "Two or more races!!Two races excluding Some other race, and three or more races"
)

ages_regex  <- as.character(glue("({str_c(ages, collapse = '|')})"))
edu_regex   <- as.character(glue("({str_c(education, collapse = '|')})"))
races_regex <- as.character(glue("({str_c(races, collapse = '|')})"))


# get vars ----
vars_raw_16 <- tidycensus::load_variables(2016, "acs5")

# format these and recode
# to strings ----
vars <- vars_raw_16 %>%
  mutate(variable = name) %>%
  separate(name, sep = "_", into = c("table", "num")) %>%
  select(variable, table, concept, num, label, everything()) %>%
  filter(str_detect(label, "Total")) %>%
  mutate(label = str_remove(label, "Estimate!!Total")) %>%
  mutate(gender = str_extract(label, "(Male|Female)"),
         age = str_extract(label, ages_regex),
         educ = str_extract(label, edu_regex),
         race = coalesce(str_extract(label, regex(races_regex, ignore_case = TRUE)),
                         str_extract(concept, regex(races_regex, ignore_case = TRUE))))

# partition vars to pull
acscodes_age_sex_educ <- vars %>%
  filter(!is.na(gender), !is.na(age), !is.na(educ)) %>%
  filter(str_detect(table, "^B")) %>%
  pull(variable)

acscodes_age_sex_race <- vars %>%
  filter(str_detect(table, "B01001[B-I]")) %>%
  filter(!is.na(gender), !is.na(age), !is.na(race)) %>%
  pull(variable)

acscodes_sex_educ_race <- vars %>%
  filter(!is.na(educ), !is.na(gender), !is.na(race)) %>%
  pull(variable)

library(tidylog)
# to labelled
acscodes_df <- vars %>%
  mutate(race = str_to_upper(race)) %>%
  rename(gender_chr = gender, age_chr = age, educ_chr = educ, race_acs = race) %>%
  left_join(gender_key, by = "gender_chr") %>%
  # age 10 if using race interactions consider binding while keeping the label
  left_join(age5_key, by = "age_chr", relationship = "many-to-one") %>%
  left_join(age10_key, by = "age_chr", suffix = c("_5", "_10")) %>%
  left_join(educ_key, by = "educ_chr", relationship = "many-to-one") %>%
  left_join(educ3_key, by = "educ_chr", relationship = "many-to-one", suffix = c("", "_3")) %>%
  left_join(filter(race_key, !is.na(race_acs)), by = "race_acs", relationship = "many-to-one") %>%
  mutate(female = as.integer(gender == 2)) %>%
  select(variable, gender, female, matches("age_(5|10)"), matches("educ($|_3)"), race) |>
  mutate(table = str_sub(variable, 1, 6), .after = variable)

# Distinguish between two types of educ
educ_type <- acscodes_df |>
  summarize(
    use_educ3 = all(1:3 %in% educ_3, na.rm = TRUE) & all(educ != 4, na.rm = TRUE),
    use_educ = all(1:4 %in% educ, na.rm = TRUE),
    .by = table)

age_type <- acscodes_df |>
  summarize(
    use_age5 = all(1:5 %in% age_5, na.rm = TRUE) & all(age_10 != 5, na.rm = TRUE),
    use_age10 = all(1:5 %in% age_10, na.rm = TRUE),
    .by = table)

acscodes_df <- acscodes_df |>
  left_join(educ_type, by = "table") |>
  mutate(educ = replace(educ, use_educ3, NA),
         educ_3 = replace(educ_3, use_educ & !use_educ3, NA)) |>
  left_join(age_type, by = "table") |>
  mutate(age_10 = replace(age_10, use_age5, NA),
         age_5 = replace(age_5, use_age10 & !use_age5, NA)) |>
  select(-starts_with("use_"))


# Write ----
usethis::use_data(acscodes_age_sex_educ, overwrite = TRUE)
usethis::use_data(acscodes_age_sex_race, overwrite = TRUE)
usethis::use_data(acscodes_sex_educ_race, overwrite = TRUE)
usethis::use_data(acscodes_df, overwrite = TRUE)
