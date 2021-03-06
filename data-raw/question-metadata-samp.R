questions_samp <- tibble::tribble(
  ~q_ID,                       ~q_label,  ~cces_data,      ~q_code, ~response_type,
  "CC06_3075",     "Cut Capital Gains Tax",  "2006",      "v3075", "yesno",
  "CC06_3069",        "Immigration Reform",  "2006",      "v3069", "yesno",
  "CC07_34",                  "SCHIP 2007",  "2007",       "CC34", "yesno",
  "CC08_316E",                "SCHIP 2007",  "2008",     "CC316e", "yesno",
  "CC09_59F",                      "PPACA",  "2009",   "cc09_59f", "yesno",
  "CC10_332D",                     "PPACA",  "2010",     "CC332D", "yesno",
  "CC11_341D",                     "PPACA",  "2011",     "CC341D", "yesno",
  "CC12_332G",           "Repeal ACA 2012",  "2012",     "CC332G", "yesno",
  "CC12_332I",                     "PPACA",  "2012",     "CC332I", "yesno",
  "CC12_332D",           "Tax Relief 2012",  "2012",     "CC332D", "yesno",
  "CC12_332C",      "Middle Class Tax Cut",  "2012",     "CC332C", "yesno",
  "CC13_332C",           "Repeal ACA 2013",  "2013",     "CC332C", "yesno",
  "CC14_325_5",  "Raise Debt Ceiling 2014",  "2014", "CC14_325_5", "yesno",
  "CC14_325_3",           "Extend Tax Cut",  "2014", "CC14_325_3", "yesno",
  "CC15_327A",           "Repeal ACA 2015",  "2015",  "CC15_327A", "yesno",
  "CC16_351I",           "Repeal ACA 2015",  "2016",  "CC16_351I", "yesno",
  "CC17_340A",           "Repeal ACA 2017",  "2017",  "CC17_340A", "yesno",
  "CC17_340G", "Withold Sanctuary Funding",  "2017",  "CC17_340G", "yesno",
  "CC18_326",           "Tax Cut Jobs Act",  "2018",   "CC18_326", "yesno",
  "CC18_322C", "Withold Sanctuary Funding",  "2018",  "CC18_322c", "yesno",
  "CC16_422F", "Racism is isolated", "2016", "CC16_422f", "ordinal",
  "CC18_308d", "Governor Approval",     "2018",  "CC18_308d", "ordinal",
  "CC18_pid3", "Partisan Identification (3-point)",     "2018",  "pid3", "categorical",
  "CC18_pid7", "Partisan Identification (7-point)",     "2018",  "pid7", "categorical",
  "CC18_religpew", "2018 Religion",     "2018",  "religpew", "categorical",
  "CCC_pid3", "Partisan Identification (3-point)", "cumulative", "pid3", "categorical",
  "CCC_newsint", "Follow the News", "cumulative", "newsint", "categorical",
  "CCC_turnout_g", "Turnout in the General Election", "cumulative", "vv_turnout_gvm", "categorical",
  "CCC_econ_retro",  "Retrospective Economy", "cumulative", "economy_retro", "ordinal",
  "CCC_voted_sen", "Party vote for US Senate", "cumulative", "voted_sen_party", "categorical",
  "CCC_voted_rep", "Party vote for US Representative", "cumulative", "voted_rep_party", "categorical",
  "CCC_voted_gov", "Party vote for Governor", "cumulative", "voted_gov_party", "categorical",
)



usethis::use_data(questions_samp, overwrite = TRUE)
