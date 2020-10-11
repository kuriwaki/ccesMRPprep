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
education <- c("Less than 9th grade",
               "9th to 12th grade,? no diploma",
               "High school graduate \\(includes equivalency\\)",
               "High school graduate, GED, or alternative",
               "Some college,? no degree",
               "Some college or associate's degree",
               "Associate's degree",
               "Bachelor's degree",
               "Graduate or professional degree")
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
  left_join(age5_key, by = "age_chr") %>%
  left_join(age10_key, by = "age_chr", suffix = c("_5", "_10")) %>%
  left_join(educ_key, by = "educ_chr") %>%
  left_join(filter(race_key, !is.na(race_acs)), by = "race_acs") %>%
  mutate(female = as.integer(gender == 2)) %>%
  select(variable, gender, female, matches("age_(5|10)"), educ, race)

# Write ----
usethis::use_data(acscodes_age_sex_educ, overwrite = TRUE)
usethis::use_data(acscodes_age_sex_race, overwrite = TRUE)
usethis::use_data(acscodes_sex_educ_race, overwrite = TRUE)
usethis::use_data(acscodes_df, overwrite = TRUE)
