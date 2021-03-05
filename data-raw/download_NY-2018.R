library(ccesMRPprep)

elec_NY <- cd_info_2018 %>%
  filter(str_detect(cd, "NY")) %>%
  select(-year)

acs_race_NY <- get_acs_cces(acscodes_age_sex_race) %>%
  filter(str_detect(cd, "NY")) %>%
  transmute(year, cd, female, race, age, count)

acs_educ_NY <- get_acs_cces(acscodes_age_sex_educ) %>%
  filter(str_detect(cd, "NY")) %>%
  transmute(year, cd, female, educ, age, count)


cc18_NY_full <- get_cces_dataverse("cumulative", year_subset = 2018) %>%
  ccc_std_demographics() %>%
  filter(st == "NY")

cc18_NY <- cc18_NY_full %>%
  mutate(female = as.numeric(gender == 2)) %>%
  select(year, case_id, state:cd, county_fips,
         gender, female, age, race, hispanic, educ, faminc, marstat, newsint,
         matches("^pid"),
         vv_turnout_gvm, voted_pres_16,
         matches("(intent|voted)_[.+]_party")) %>%
  mutate(across(where(is.labelled), as_factor))


usethis::use_data(cc18_NY, overwrite = TRUE)
usethis::use_data(acs_educ_NY, overwrite = TRUE)
usethis::use_data(acs_race_NY, overwrite = TRUE)
usethis::use_data(elec_NY, overwrite = TRUE)

