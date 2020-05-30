library(tidyverse)
library(ccesMRPprep)

# example question metadata
questions_samp[20, ]

## do this once:
# ccc <- get_cces_dv("cumulative")
# write_rds(ccc, "data/input/cces/cces_cumulative.rds")

# predictors
ccc <- ccc_std_demographics(read_rds("data/input/cces/cces_cumulative.rds"))

# outcome (after downloading the full datasets to local, looping get_cces_dv()).
cc_outcome <- get_cces_question(qcode = "CC18_322c",
                                qID = "CC18_332C",
                                year = "2018")

# final dataframe (before deriving outcome data)
cces_df <- inner_join(ccc, cc_outcome, by = c("year", "case_id"))


# ACS (after getting ACS key, see help page)
acs_df <- get_acs_cces(year = 2018,
                       varlist = acscodes_age_sex_educ,
                       varlab_df = acscodes_df)
ps_df <- get_poststrat(acs_df,
                       model_ff = "yes|trials(n_response) ~ age + gender + educ + (1|cd)")
