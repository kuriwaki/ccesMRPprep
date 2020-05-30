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
  select(year, case_id, state:cd, zipcode, county_fips,
         gender, age, race, hispanic, educ, faminc, marstat, newsint,
         vv_turnout_gvm, voted_pres_16, economy_retro)


usethis::use_data(ccc_samp, overwrite = TRUE)

