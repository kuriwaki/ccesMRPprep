library(tidyverse)

pres_party <- tibble::tribble(
  ~name, ~party,
  "harris",    "D",
  "trump",    "R",
  "biden",    "D",
  "clinton",    "D",
  "obama",    "D",
  "romney",    "R",
  "mccain",    "R"
)

pres_names_long <- tribble(
  ~name, ~elec,
  "harris", 2024,
  "trump", 2024,
  "biden", 2020,
  "trump", 2020,
  "trump", 2016,
  "clinton", 2016,
  "obama", 2012,
  "romney", 2012,
  "obama", 2008,
  "mccain", 2008)

pres_names_wide <- pres_names_long |>
  left_join(pres_party) |>
  pivot_wider(
    id_cols = elec,
    names_from = party,
    names_prefix = "party_",
    values_from = name
  )

cd_info_all <- bind_rows(
  cd_info_2008,
  mutate(cd_info_2008, year = 2010),
  cd_info_2012,
  mutate(cd_info_2012, year = 2014),
  cd_info_2016,
  cd_info_2018,
  cd_info_2020,
  cd_info_2022,
  cd_info_2024,
)

# Republican vote percentages
R_pct <-
  cd_info_all |>
  select(lines = year, cd, starts_with("pct_")) |>
  pivot_longer(
    matches("pct_"),
    names_prefix = "pct_",
    values_to = "pct", values_drop_na = TRUE) |>
  mutate(elec = case_when(
    name == "mccain" ~ 2008,
    name == "romney" ~ 2012,
    name == "trump16" ~ 2016,
    name == "trump20" ~ 2020,
    name == "trump" & lines <= 2018 ~ 2016,
    name == "trump" & lines >= 2020 & lines <= 2022 ~ 2020
  ),
  .after = cd
  ) |>
  mutate(name = str_remove(name, "(16|20)"),
         party = "R")


D_pct <- R_pct |>
  left_join(pres_names_wide, by = "elec") |>
  transmute(lines,
            cd,
            elec,
            party = "D",
            name = party_D,
            pct = 1 - pct)

# same for Ns
Ns <-
  cd_info_all |>
  select(lines = year, cd, matches("total")) |>
  pivot_longer(
    matches("presvotes_total"),
    names_prefix = "presvotes_",
    values_to = "presvotes_total", values_drop_na = TRUE) |>
  mutate(elec = case_when(
    name == "total20" ~ 2020,
    lines %in% c(2008, 2012, 2016, 2020) ~ lines,
    lines == 2010 ~ 2008,
    lines == 2014 ~ 2012,
    lines == 2018 ~ 2016,
    lines == 2022 ~ 2020,
  ),
  .after = cd
  ) |>
  select(-name)

cd_info_long <- bind_rows(D_pct, R_pct) |>
  tidylog::left_join(Ns, by = c("lines", "cd", "elec")) |>
  arrange(lines, elec, cd, party) |>
  rename(candidate = name)

usethis::use_data(cd_info_long, overwrite = TRUE)
