
# This loads from an external repo. Contact Shiro Kuriwaki for more

library(tidyverse)

full_cd <- read_rds("~/Dropbox/CCES_representation/data/output/averages/by-cd_info.Rds")


cd_info_2018 <- full_cd %>%
  mutate(year = 2018) %>%
  select(year, cd,
         dailykos_name = descrip, largest_place = place,
         pct_trump, pct_romney, pct_mccain)


usethis::use_data(cd_info_2018, overwrite = TRUE)
