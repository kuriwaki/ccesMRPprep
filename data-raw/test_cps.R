library(tidyverse)
library(haven)



cps_all <- read_dta("data/input/cps/cps_00009.dta.gz")


count(cps_all, year)

count(cps_all, educ)

count_long <- function(var, tbl = cps_all) {
  tbl %>%
    count({{ var }}, year) %>%
    rename(value = {{var}}) %>%
    mutate(name  = as.character(as_factor(value)),
           value = zap_labels(value),
           variable = quo_name(enquo(var))) %>%
    select(variable, year, name, value, n)
}

cps_onewaytabs <- bind_rows(
  count_long(sex),
  cps_all %>%
    mutate(age = as.integer(as.character(as_factor(age))),
           age = ccc_bin_age(age)) %>%
    count_long(age, .),
  count_long(race),
  count_long(hispan),
  count_long(educ),
  count_long(voted),
  count_long(statefip),
  count_long(county),
)
usethis::use_data(cps_onewaytabs)


# sex





# CPS NY - Bronx
cps_all %>%
  filter(statefip == 36, year == 2016) %>%
  select(wtfinl, age, sex, race, hispan, educ, voted) %>%
  mutate(age = as.integer(as.character(as_factor(age))),
         age = as_factor(ccc_bin_age(age))) %>%
  filter(age == "25 to 34 years", educ %in% c(81, 91, 92, 111), race %in% c(100:200)) %>%
  mutate(educ = case_when(educ %in% 81:92 ~ "Some College", educ %in% 111 ~ "4-year"),
         voted = case_when(voted %in% 2 ~ "Voted", voted %in% 1 ~ "Did Not Vote", TRUE ~ "Other"),
         hispan = case_when(hispan %in% 0 ~ "Non-Hispanic", hispan > 0 ~ "Hispanic"),
         sex = as_factor(sex)) %>%
  filter(hispan == "Non-Hispanic") %>%
  count(age, sex, race, hispan, educ, voted) %>%
  pivot_wider(id_cols = c(sex, race, hispan, educ),
              names_from = voted,
              values_from = n)

# ACS - NY-16
acs1 <- get_acs_cces(acscodes_age_sex_educ, year = 2016)
acs2 <- get_acs_cces(acscodes_age_sex_race, year = 2016)


acs1 %>% filter(cd == "NY-16", age == "25 to 34 years")
acs2 %>% filter(cd == "NY-16", age == "25 to 34 years") %>% filter(race %in% c("White", "Black"))
