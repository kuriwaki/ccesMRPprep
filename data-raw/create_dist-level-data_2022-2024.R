library(tidyverse)
library(googlesheets4)
library(janitor)

# Authenticate with Google Sheets
# gs4_auth()

# URLs for your Google Sheets
url_2022 <- "https://docs.google.com/spreadsheets/d/1CKngqOp8fzU22JOlypoxNsxL6KSAH920Whc-rd7ebuM/edit?usp=sharing"
url_2024 <- "https://docs.google.com/spreadsheets/d/1ng1i_Dm_RMDnEvauH44pgE6JCUsapcuu8F2pCfeLWFo/edit?gid=1491069057#gid=1491069057"
url_geo_118 <- "https://docs.google.com/spreadsheets/d/1weoLFu2U5lmxQNcB8pFItGHj1Lb_M2E9Oi48sI4w1vY/edit?usp=sharing"
url_geo_119 <- "https://docs.google.com/spreadsheets/d/12YaBonkqHAjkXhzyKlH2-1t-smZ6J5j76RCBSJEwQHo/edit?usp=sharing"

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

region_2022 <- read_sheet(url_geo_118, sheet = "Descriptive name") |>
  select(cd = CD,
         dailykos_name = `Geographic Description`)

largest_place_2022 <- read_sheet(url_geo_118, sheet = "By places") |>
  select(cd = CD,
         largest_place = `Largest place`)

# 2024
# clean sheet
sheet_2024 <- read_sheet(url_2024, sheet = "Vote totals") |>
  select(1:9) |>
  row_to_names(row_number = 2, remove_row = TRUE) |>
  select(cd = 1, Harris, Trump, Total)

cd_names_2024 <- sheet_2024 |>
  transmute(year = 2024, cd)

voting_info_2024 <- sheet_2024 |>
  mutate(across(where(is.list) & !matches("^cd$"),
                ~ map_dbl(.x, ~ as.numeric(.x[1])))) |>
  transmute(cd,
            pct_trump = Trump / (Harris + Trump),
            presvotes_DR = Harris + Trump,
            presvotes_total = Total)

region_2024 <- read_sheet(url_geo_119, sheet = "Descriptive name") |>
  select(cd = CD,
         dailykos_name = `Geographic Description`)

largest_place_2024 <- read_sheet(url_geo_119, sheet = "By places") |>
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
