library(tidyverse)
library(googlesheets4)

# Authenticate with Google Sheets
# gs4_auth()

# URLs for your Google Sheets
url_2022 <- "https://docs.google.com/spreadsheets/d/1CKngqOp8fzU22JOlypoxNsxL6KSAH920Whc-rd7ebuM/edit?usp=sharing"
url_2024 <- "https://docs.google.com/spreadsheets/d/1Sg4ZZz5FcX7lz-m2xqmYtndaO2uEMSaL7x99AbQOvv8/edit?usp=sharing"
url_geo_119 <- "https://docs.google.com/spreadsheets/d/12YaBonkqHAjkXhzyKlH2-1t-smZ6J5j76RCBSJEwQHo/edit?usp=sharing"
url_geo_118 <- "https://docs.google.com/spreadsheets/d/1weoLFu2U5lmxQNcB8pFItGHj1Lb_M2E9Oi48sI4w1vY/edit?usp=sharing"

# Read data from Google Sheets

# 2022
cd_names_2022 <- read_sheet(url_2022, sheet = 1) |>
  mutate(year = 2022) |>
  select(year, cd = District)

voting_info_2022 <- read_sheet(url_2022, sheet = 2) |>
  transmute(cd = District,
            pct_trump = Trump / (Biden + Trump),
            presvotes_DR = Biden + Trump,
            presvotes_total = Total
  )

region_2022 <- read_sheet(url_geo_118, sheet = 1) |>
  select(cd = CD,
         dailykos_name = `Geographic Description`)

largest_place_2022 <- read_sheet(url_geo_118, sheet = 2) |>
  select(cd = CD,
         largest_place = `Largest place`)

# 2024
cd_names_2024 <- read_sheet(url_2024, sheet = 1) |>
  mutate(year = 2024) |>
  select(year, cd = District)

voting_info_2024 <- read_sheet(url_2024, sheet = 2) |>
  transmute(cd = District,
            pct_trump20 = Trump / (Biden + Trump),
            presvotes_DR_20 = Biden + Trump,
            presvotes_total_20 = Total)

region_2024 <- read_sheet(url_geo_119, sheet = 1) |>
  select(cd = CD,
         dailykos_name = `Geographic Description`)

largest_place_2024 <- read_sheet(url_geo_119, sheet = 2) |>
  select(cd = CD,
         largest_place = `Largest place`)

# Join geographic descriptions to the main datasets
cd_info_2022 <- cd_names_2022 |>
  left_join(region_2022, by = "cd") |>
  left_join(largest_place_2022, by = "cd") |>
  left_join(voting_info_2022, by = "cd") |>
  mutate(cd = str_replace(cd, "-AL$", "-01"))

cd_info_2024 <- cd_names_2024 |>
  left_join(region_2024, by = "cd") |>
  left_join(largest_place_2024, by = "cd") |>
  left_join(voting_info_2024, by = "cd") |>
  mutate(cd = str_replace(cd, "-AL$", "-01"))

# Save the data
usethis::use_data(cd_info_2022, overwrite = TRUE)
usethis::use_data(cd_info_2024, overwrite = TRUE)
