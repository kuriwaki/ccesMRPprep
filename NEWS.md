
# cccesMRPprep 0.1.12

* Add 2021, 2022, and 2023 to cces_dv_ids
* Add 2022 validated vote and 2023 cumulative name update to cces_dv_ids
* Add 2022 and 2024 daily kos cd data

# ccesMRPprep 0.1.11

* Add CD-level analyses

# ccesMRPprep 0.1.10

* Separate out the synth_functions to synthjoint package (#9)

# ccesMRPprep 0.1.9

* Overwrite cd_info so it uses two party vote (it makes a big difference in Utah in 2016). Add 2016 and 2020 lines too.
* Allow ACS up to 2019 or error out on unavailable years
* Update get_cces_dataverse to 2020 CES with validated vote
* Add option to make White Hispanics as "Hispanics" and make it a default; same for Black Hispanics (806beb2)

# ccesMRPprep 0.1.8.1

* Fix to wrong values in get_acs_cvap (#7)

# ccesMRPprep 0.1.8

* Introduce `synth_prod()`, `synth_mlogit()`, `synth_smoothfix()`
* Add New York data as a third sample (`acs_NY`, `cc18_NY`, `elec_NY`)
* Add option for states in `get_acs()`

# ccesMRPprep 0.1.7

* Rename `get_cces_dv` to  `get_cces_dataverse()`
* Use CRAN version of dataverse (#3)
* Change formula notation in `build_counts` and `cces_join_slim` to (y ~ x) instead of `yes | trials(n_response)`

# ccesMRPprep 0.1.6

* Update `cces_dv_ids` link to new Dataverse versions (1ac26f993aa88e343ad686175d885c88f393e3ca)
* Make Native American a proper category (1f6d8d0b08d5b2e5afb196150b8f79cc54209957)
* Add a CPS vignette (c64528ee96f136b592c128e7424eab2bea0e9fc8)

# ccesMRPprep 0.1.5

* Change default to ACS-1yr instead of ACS-5yr, since the Census ACS-5 yr should not be used if we want to prioritize recent values (ad30b4c6e181833801ab0604da69849e493e7c57). I guess ACS-5yrs do not up weight more recent years. 
* Use Crunch terminology of names and values for the labels (ce08f874d211bcc89c9ad9a379b039144d50dbba)

# ccesMRPprep 0.1.4

* allow for different names and additional variables in count, get_cces_question, cces_join_slim (a59ad9b105255927365cd59162fc1a4ba4ec1188, a59ad9b105255927365cd59162fc1a4ba4ec1188)

# ccesMRPprep 0.1.3

* Change default so that age gets replaced to bins in `ccc_std_demographics` 
* treat Don't knows as NA in `yesno_to_binary`

# ccesMRPprep 0.1.2

* Sample CCES 2018
* Derived Variables Vignette
* More sample questions


# ccesMRPprep 0.1.1

* Added a `NEWS.md` file to track changes to the package.

