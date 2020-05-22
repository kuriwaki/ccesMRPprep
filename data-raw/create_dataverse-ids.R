library(tibble)

cces_dv_ids <- tribble(
  ~cces_name, ~year, ~caseid_var, ~doi, ~filename,
  "cumulative", NA, "case_id", "10.7910/DVN/II2DB6", "cumulative_2006_2018.Rds",
  "2006", 2006, "v1000",  "10.7910/DVN/Q8HC9N", "cces_2006_common.tab",
  "2007", 2007, "caseid", "10.7910/DVN/OOXTJ5", "CCES07_OUTPUT.sav",
  "2008", 2008, "V100",   "10.7910/DVN/YUYIVB", "cces_2008_common.tab",
  "2009", 2009, "v100",   "10.7910/DVN/KKM9UK", "cces09_cmn_output_2.dta",
  "2010", 2010, "V100",   "10.7910/DVN/VKKRWA", "cces_2010_common_validated.dta",
  "2011", 2011, "V100",   "10.7910/DVN/GLRXZ0", "CCES11_Common_OUTPUT.tab",
  "2012", 2012, "V101",   "10.7910/DVN/HQEVPK", "CCES12_Common_VV.tab",
  "2013", 2013, "caseid", "10.7910/DVN/KPP85M", "Common Content Data.tab",
  "2014", 2014, "V101",   "10.7910/DVN/XFXJVY", "CCES14_Common_Content_Validated.tab",
  "2015", 2015, "V101",   "10.7910/DVN/SWMWX8", "CCES15_Common_OUTPUT_Jan2016.tab",
  "2016", 2016, "V101",   "10.7910/DVN/GDF6Z0", "CCES16_Common_OUTPUT_Feb2018_VV.tab",
  "2017", 2017, "V101",   "10.7910/DVN/3STEZY", "Common Content Data.tab",
  "2018", 2018, "caseid", "10.7910/DVN/ZSBZ7K", "cces18_common_vv.dta",
)


usethis::use_data(cces_dv_ids, overwrite = TRUE)
