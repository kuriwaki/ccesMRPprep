
# This loads from an external repo. Contact Shiro Kuriwaki for more

library(tidyverse)
library(googlesheets4)
library(fs)


projdir <- "~/Dropbox/CCES_representation/data/output/"
url_2018 <- "https://docs.google.com/spreadsheets/d/1zLNAuRqPauss00HDz4XbTH2HqsCzMe0pR8QmD1K8jk8"

cd_info_2020 <- read_rds(path(projdir, "averages/by-cd-2020_info.Rds")) %>%
  mutate(year = 2020) %>%
  select(year, cd,
         dailykos_name = descrip_18,
         largest_place = place_18,
         presvotes_total = pres_all_total,
         pct_trump, pct_trump16, pct_romney)

# 2018 ----
cd_2018_shares <- read_rds(path(projdir, "averages/by-cd-2018_info.Rds")) %>%
  mutate(year = 2018) %>%
  select(year, cd,
         dailykos_name = descrip,
         largest_place = place,
         pct_trump, pct_romney, pct_mccain)

# denominator
votes_2018 <-
  read_sheet(url_2018, sheet = 2, skip = 1) |>
  janitor::clean_names() |>
  transmute(cd = district, presvotes_total = clinton + trump_12) |>
  mutate(cd = str_replace(cd, "-AL", "-01"))

cd_info_2018 <- cd_2018_shares |>
  left_join(votes_2018, by = "cd") |>
  relocate(presvotes_total, .after = pct_trump)

# 2016 ---
cd_info_2016 <- read_rds(path(projdir, "averages/by-cd-2016_info.Rds")) %>%
  mutate(year = 2016) %>%
  select(year, cd,
         dailykos_name = descrip_16,
         presvotes_total = pres_all_total,
         pct_trump, pct_romney, pct_mccain)


usethis::use_data(cd_info_2016, overwrite = TRUE)
usethis::use_data(cd_info_2018, overwrite = TRUE)
usethis::use_data(cd_info_2020, overwrite = TRUE)
