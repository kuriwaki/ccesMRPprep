# state FIPS
library(tigris)
library(tibble)
library(dplyr)

regions <- tibble(st = state.abb,
                  region = state.region,
                  division = state.division)

st_trad <- tribble(
  ~st_trad, ~st,
  "Ala.", "AL",
  "Alaska", "AK",
  "Ariz.", "AZ",
  "Ark.", "AR",
  "Calif.", "CA",
  "Colo.", "CO",
  "Conn.", "CT",
  "Del.", "DE",
  "Fla.", "FL",
  "Ga.", "GA",
  "Hawaii", "HI",
  "Idaho", "ID",
  "Ill.", "IL",
  "Ind.", "IN",
  "Iowa", "IA",
  "Kan.", "KS",
  "Ky.", "KY",
  "La.", "LA",
  "Maine", "ME",
  "Md.", "MD",
  "Mass.", "MA",
  "Mich", "MI",
  "Minn.", "MN",
  "Miss.", "MS",
  "Mo.", "MO",
  "Mont.", "MT",
  "Neb.", "NE",
  "Nev.", "NV",
  "N.H.", "NH",
  "N.J.", "NJ",
  "N.M.", "NM",
  "N.Y.", "NY",
  "N.C.", "NC",
  "N.D.", "ND",
  "Ohio", "OH",
  "Okla.", "OK",
  "Ore.", "OR",
  "Pa.", "PA",
  "R.I.", "RI",
  "S.C.", "SC",
  "S.D.", "SD",
  "Tenn.", "TN",
  "Texas", "TX",
  "Utah", "UT",
  "Vt.", "VT",
  "Va.", "VA",
  "Wash.", "WA",
  "W. Va.", "WV",
  "Wis.", "WI",
  "Wyo.", "WY"
)


states_key <-  tigris::fips_codes %>%
  as_tibble() %>%
  transmute(st = state, state = state_name, st_fips = as.integer(state_code)) %>%
  distinct() %>%
  filter(!st_fips %in% 60:78, st != "DC") %>%
  left_join(st_trad, by = "st") %>%
  left_join(regions, by = "st") %>%
  relocate(st, state, st_trad)

usethis::use_data(states_key, overwrite = TRUE)
