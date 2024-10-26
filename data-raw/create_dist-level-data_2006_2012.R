library(tidyverse)
library(googlesheets4)

# Authenticate with Google Sheets
# gs4_auth()

# URLs for your Google Sheets
url_2008 <- "https://docs.google.com/spreadsheets/d/1l7W130tPRF6dQ4JoqlQJSJexnEg4rZct-7kwDXqgoLE/edit?gid=429358610#gid=429358610"
url_2012 <- "https://docs.google.com/spreadsheets/d/1xn6nCNM97oFDZ4M-HQgoUT3X4paOiSDsRMSuxbaOBdg/edit?gid=0#gid=0"

# Read data from Google Sheets

# 2008
cd_names_2008 <- read_sheet(url_2008, range = "A2:A", col_names = TRUE, sheet = 1) |>
  mutate(year = 2008) |>
  select(year,
         cd = CD)

# https://yalemaps.maps.arcgis.com/home/item.html?id=35e8e9aa89b34a3a8a036b1be7ad6607
voting_info_2008 <- read_csv("data-raw/KPEcd2008.csv") |>
  filter(STATENAME != "District Of Columbia") |>
  transmute(cd = to_cd(STATENAME, DISTRICT),
            pct_mccain = GOP_VOT / (GOP_VOT + DEM_VOT),
            presvotes_total = TOT_VOT)


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
cd_info_2008 <- cd_names_2008 |>
  mutate(cd = str_replace(cd, "-AL$", "-01")) |>
  left_join(voting_info_2008, by = "cd") |>
  relocate(year, cd, pct_mccain, presvotes_total)

cd_info_2012 <- cd_names_2012 |>
  left_join(voting_info_2012, by = "cd") |>
  mutate(cd = str_replace(cd, "-AL$", "-01"))

# Save the data
usethis::use_data(cd_info_2012, overwrite = TRUE)
usethis::use_data(cd_info_2008, overwrite = TRUE)
