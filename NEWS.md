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

