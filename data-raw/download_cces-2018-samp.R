


cc18 <- get_cces_dataverse("2018")

set.seed(02138)
cc18_samp <- cc18 %>%
  sample_n(1000)



usethis::use_data(cc18_samp, overwrite = TRUE)
