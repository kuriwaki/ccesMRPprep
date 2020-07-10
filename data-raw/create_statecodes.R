# state FIPS
library(tigris)

regions <- tibble(st = state.abb,
                  region = state.region,
                  division = state.division)

states_key <-  tigris::fips_codes %>%
  as_tibble() %>%
  transmute(st = state, state = state_name, st_fips = as.integer(state_code)) %>%
  distinct() %>%
  filter(!st_fips %in% 60:78, st != "DC") %>%
  left_join(regions, by = "st")

usethis::use_data(states_key, overwrite = TRUE)
