library(ccesMRPprep)

elec_NY <- cd_info_2018 %>%
  filter(str_detect(cd, "NY")) %>%
  select(-year)

acs_NY <- get_acs_cces(acscodes_age_sex_race) %>%
  filter(str_detect(cd, "NY")) %>%
  transmute(year, cd, female, race, age, count)


cc18_NY_full <- get_cces_dataverse("cumulative", year_subset = 2018) %>%
  ccc_std_demographics() %>%
  filter(st == "NY")

cc18_NY <- cc18_NY_full %>%
  select(year, case_id, state:cd, county_fips,
         gender, age, race, hispanic, educ, faminc, marstat, newsint,
         matches("^pid"),
         vv_turnout_gvm, voted_pres_16,
         matches("(intent|voted)_[.+]_party")) %>%
  mutate(across(where(is.labelled), as_factor))


usethis::use_data(cc18_NY, overwrite = TRUE)
usethis::use_data(acs_NY, overwrite = TRUE)
usethis::use_data(elec_NY, overwrite = TRUE)

library(Formula)
library(emlogit)

imputed_acs <- impute_cell(pid3 ~ race + age, cc18_NY, acs_NY, area_var = "cd")

imputed_acs %>%
  count(cd, pid3, wt = count) %>%
  group_by(cd) %>%
  summarize(twoparty_gop = sum(n*(pid3 == "Republican")) / sum(n*(pid3 %in% c("Republican", "Democrat")))) %>%
  left_join(elec_NY) %>%
  ggplot(aes(x = pct_trump, twoparty_gop)) +
  geom_point() +
  coord_equal() +
  geom_abline(linetype = "dashed") +
  geom_label(aes(label = largest_place))

library(ggplot2)
