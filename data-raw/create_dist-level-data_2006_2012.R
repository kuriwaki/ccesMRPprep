library(tidyverse)
library(googlesheets4)

# Authenticate with Google Sheets
gs4_auth()

# URLs for your Google Sheets
url_2006 <- "https://docs.google.com/spreadsheets/d/1l7W130tPRF6dQ4JoqlQJSJexnEg4rZct-7kwDXqgoLE/edit?gid=429358610#gid=429358610"
url_2012 <- "https://docs.google.com/spreadsheets/d/1xn6nCNM97oFDZ4M-HQgoUT3X4paOiSDsRMSuxbaOBdg/edit?gid=0#gid=0"

# Read data from Google Sheets

# 2006
cd_names_2006 <- read_sheet(url_2006, range = "A2:E", col_names = TRUE, sheet = 1) |>
  mutate(year = 2006) |>
  select(year, cd = CD)

voting_info_2006 <- read_sheet(url_2006,range = "A2:I", col_names = TRUE, sheet = 2) |>
  select(cd = CD,
         pct_mccain = 'McCain%')

# 2012
cd_names_2012 <- read_sheet(url_2012, range = "A2:G", col_names = TRUE, sheet = 1) |>
  mutate(year = 2012) |>
  select(year, cd = CD)

voting_info_2012 <- read_sheet(url_2012, range = "A2:O", col_names = TRUE, sheet = 2) |>
  select(cd = CD,
         presvotes_total = 7,
         pct_romney = 'Romney%',
         pct_mccain = 'McCain%')

# Join data from page 1 and page 2 for each dataset
cd_info_2006 <- cd_names_2006 |>
  left_join(voting_info_2006, by = "cd") |>
  mutate(cd = str_replace(cd, "-AL$", "-01"))

cd_info_2012 <- cd_names_2012 |>
  left_join(voting_info_2012, by = "cd") |>
  mutate(cd = str_replace(cd, "-AL$", "-01"))

# Save the data
usethis::use_data(cd_info_2022, overwrite = TRUE)
usethis::use_data(cd_info_2024, overwrite = TRUE)
