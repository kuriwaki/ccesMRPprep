
# This loads from an external repo. Contact Shiro Kuriwaki for more

library(tidyverse)
library(googlesheets4)
library(fs)


projdir <- "~/Dropbox/CCES_representation/data/output/"


cd_info_2020 <- read_rds(path(projdir, "averages/by-cd-2020_info.Rds")) %>%
  mutate(year = 2020) %>%
  select(year, cd,
         dailykos_name = descrip_18,
         largest_place = place_18,
         presvotes_total = pres_all_total,
         pct_trump, pct_trump16, pct_romney)

cd_info_2018 <- read_rds(path(projdir, "averages/by-cd-2018_info.Rds")) %>%
  mutate(year = 2018) %>%
  select(year, cd,
         dailykos_name = descrip,
         largest_place = place,
         pct_trump, pct_romney, pct_mccain)



cd_info_2016 <- read_rds(path(projdir, "averages/by-cd-2016_info.Rds")) %>%
  mutate(year = 2016) %>%
  select(year, cd,
         dailykos_name = descrip_16,
         presvotes_total = pres_all_total,
         pct_trump, pct_romney, pct_mccain)


# incumbency of the candidate
d_inc <-  read_rds(path(projdir, "intermediate/by-cd_contestation.Rds")) %>%
  select(year, cd, dem_incumbent = D_incumbent, gop_incumbent = R_incumbent, contested_DR, inc_party, win_party) %>%
  filter(year >= 2006)

cd_presvote <- read_rds(path(projdir, "averages/by-cd-year_pres-vshare.Rds")) %>%
  filter(year >= 2006) %>%
  rename(dempres_vshare = dem_vshare) |>
  mutate(st = str_sub(cd, 1, 2), .before = cd) # %>%
  # left_join(d_inc, by = c("year", "cd"))


# write_rds(by_cd, "~/Dropbox/MRP-targets/data/output/by-cd_contextual.rds")
# fs::file_copy(rep("data/output/by-cd_contextual.rds", 3),
#               c("~/Dropbox/survey-weighting/data/districts",
#                 "~/Dropbox/clusterBallot/data/output",
#                 "~/Dropbox/CCES_district-opinion/data/input/dists_political"),
#               overwrite = TRUE)


usethis::use_data(cd_info_2016, overwrite = TRUE)
usethis::use_data(cd_info_2018, overwrite = TRUE)
usethis::use_data(cd_info_2020, overwrite = TRUE)
usethis::use_data(cd_presvote, overwrite = TRUE)
