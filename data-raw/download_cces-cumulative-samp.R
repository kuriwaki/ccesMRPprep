source("R/my_API_tokens.R")

library(tidyverse)
library(dataverse)
library(haven)
library(ccesMRPprep)



ccc <- get_cces_dv("cumulative")

set.seed(02138)
ccc_samp <- ccc %>%
  sample_n(1000) %>%
  arrange(year, case_id) %>%
  mutate(st = as.character(as_factor(st)),
         state = as.character(as_factor(state)),
         cd = str_c(st, "-", str_pad(dist, width = 2, pad = "0"))) %>%
  select(year, case_id, state:cd, zipcode, county_fips,
         gender, age, race, hispanic, educ, faminc, marstat, newsint,
         vv_turnout_gvm, voted_pres_16, economy_retro)


usethis::use_data(ccc_samp, overwrite = TRUE)

