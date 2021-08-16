library(tibble)

cces_dv_ids <- tribble(
  ~cces_name, ~year, ~doi, ~filename,  ~caseid_var, ~server,
  "cumulative", NA,   "10.7910/DVN/II2DB6", "cumulative_2006-2020.dta", "case_id", "dataverse.harvard.edu",
  "2006",       2006, "10.7910/DVN/Q8HC9N", "cces_2006_common.tab", "v1000",   "dataverse.harvard.edu",
  "2007",       2007, "10.7910/DVN/OOXTJ5", "CCES07_OUTPUT.sav", "caseid",  "dataverse.harvard.edu",
  "2008",       2008, "10.7910/DVN/YUYIVB", "cces_2008_common.tab", "V100",    "dataverse.harvard.edu",
  "2009",       2009, "10.7910/DVN/KKM9UK", "cces09_cmn_output_2.dta", "v100",    "dataverse.harvard.edu",
  "2010",       2010, "10.7910/DVN/VKKRWA", "cces_2010_common_validated.dta", "V100",    "dataverse.harvard.edu",
  "2011",       2011, "10.7910/DVN/GLRXZ0", "CCES11_Common_OUTPUT.tab", "V100",    "dataverse.harvard.edu",
  "2012",       2012, "10.7910/DVN/HQEVPK", "CCES12_Common_VV.tab", "V101",    "dataverse.harvard.edu",
  "2013",       2013, "10.7910/DVN/KPP85M", "Common Content Data.tab", "caseid",  "dataverse.harvard.edu",
  "2014",       2014, "10.7910/DVN/XFXJVY", "CCES14_Common_Content_Validated.tab", "V101",    "dataverse.harvard.edu",
  "2015",       2015, "10.7910/DVN/SWMWX8", "CCES15_Common_OUTPUT_Jan2016.tab", "V101",    "dataverse.harvard.edu",
  "2016",       2016, "10.7910/DVN/GDF6Z0", "CCES16_Common_OUTPUT_Feb2018_VV.tab", "V101",    "dataverse.harvard.edu",
  "2017",       2017, "10.7910/DVN/3STEZY", "Common Content Data.tab", "V101",    "dataverse.harvard.edu",
  "2018",       2018, "10.7910/DVN/ZSBZ7K", "cces18_common_vv.dta", "caseid",  "dataverse.harvard.edu",
  "2019",       2019, "10.7910/DVN/WOT7O8", "CCES19_Common_OUTPUT.tab", "caseid",  "dataverse.harvard.edu",
  "2020",       2020, "10.7910/DVN/E9N6PH", "CES20_Common_OUTPUT_vv.dta", "caseid",  "dataverse.harvard.edu",
)


usethis::use_data(cces_dv_ids, overwrite = TRUE)
