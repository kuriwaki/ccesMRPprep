Portable Routines for Preparing CCES and ACS data for MRP
================

Cite as:

  - Shiro Kuriwaki (2020). ccesMRPprep: Functions to Prepare CCES data
    for MRP. R package. <https://www.github.com/kuriwaki/ccesMRPprep>

### Purpose and Contribution

Multi-level Regression and Post-stratification is an increasingly
popular method for analyzing surveys, and can be implemented on public
datasets such as the [CCES](https://cces.gov.harvard.edu/) and ACS.
However, there are considerable upfront costs in preparing the data,
recoding values and generating post-stratification frames so data can be
matched.

This package provides data loading, processing, and formatting functions
for a particular task: using *CCES data* for MRP. Its key contributions
are functions that are calibrated to a consistent syntax, lookup tables
and value-key pairs of data that are based upon a careful reading of
data sources, and data loading functions that use APIs to reduce the
dependency on downloading large files. Model fitting and visualization
of MRP itself is handled elsewhere. This package is focused on the
preparation to get there.

``` r
# remotes::install_github("kuriwaki/ccesMRPprep")
library(ccesMRPprep)
library(tidyverse)
```

See the vignettes for more long-form documentation and explanation of
the nature of the data. Otherwise, each function and built-in data
provides documentation as well. An overview of the workflow is below.

## Workflow

*Step 1. Loading CCES data*

All CCES data can be downloaded directly from dataverse, using the
development version of the `dataverse` R package. Once you set your
dataverse API token, the function `get_cces_dv` will make this quick and
simple.

``` r
ccc <- get_cces_dv("cumulative")
```

We will use a built-in sample of 1,000 observations for illustration
(see `?ccc_samp`).

``` r
ccc_samp
```

    ## # A tibble: 1,000 x 18
    ##     year case_id state st    cd    zipcode county_fips  gender   age    race
    ##    <int>   <int> <chr> <chr> <chr> <chr>   <chr>       <int+l> <int> <int+l>
    ##  1  2006  439254 Neva… NV    NV-2  89703   32510       2 [Fem…    20 1 [Whi…
    ##  2  2006  440689 Cali… CA    CA-2  96067   06093       2 [Fem…    71 1 [Whi…
    ##  3  2006  445845 Colo… CO    CO-5  80922   08041       2 [Fem…    39 1 [Whi…
    ##  4  2006  452572 Minn… MN    MN-5  55428   27053       1 [Mal…    74 1 [Whi…
    ##  5  2006  498451 Iowa  IA    IA-2  50060   19185       2 [Fem…    53 1 [Whi…
    ##  6  2006  502543 Tenn… TN    TN-5  37206   47037       2 [Fem…    50 1 [Whi…
    ##  7  2006  523050 West… WV    WV-2  25312   54039       1 [Mal…    55 1 [Whi…
    ##  8  2006  523861 Illi… IL    IL-3  60629   17031       2 [Fem…    51 1 [Whi…
    ##  9  2006  532881 Minn… MN    MN-7  55396   27143       1 [Mal…    44 1 [Whi…
    ## 10  2006  553375 Ohio  OH    OH-11 44112   39035       2 [Fem…    53 1 [Whi…
    ## # … with 990 more rows, and 8 more variables: hispanic <int+lbl>,
    ## #   educ <int+lbl>, faminc <fct>, marstat <int+lbl>, newsint <int+lbl>,
    ## #   vv_turnout_gvm <fct>, voted_pres_16 <fct>, economy_retro <int+lbl>

*Step 2. Cleaning CCES data*

The CCES cumulative dataset is already harmonized and cleaned, but
values must be recoded so that they later match with the values of th
ACS. I have created key-value pairings for the main demographic
variables. The wrapper function expects a CCES cumulative dataset and
recodes.

``` r
ccc_std <- ccc_std_demographics(ccc_samp)
```

*Step 3. Collapsing the CCES data*

``` r
# fake outcome data
# must be called "response"

ccc_samp_std <- ccc_samp %>% 
   mutate(response = sample(c("For", "Against"), size = n(), replace = TRUE)) %>% 
   ccc_std_demographics()

ccc_samp_out <- build_counts(ccc_samp_std,
                             "yes | trials(n_response) ~ age + gender + educ")

ccc_samp_out
```

    ## # A tibble: 400 x 5
    ##      age gender educ         n_response   yes
    ##    <int> <fct>  <fct>             <int> <int>
    ##  1    18 Male   HS or Less            3     2
    ##  2    18 Female HS or Less            7     4
    ##  3    18 Female Some College          1     0
    ##  4    19 Male   HS or Less            1     1
    ##  5    19 Female HS or Less            2     1
    ##  6    19 Female Some College          2     2
    ##  7    20 Male   HS or Less            1     1
    ##  8    20 Male   Some College          5     3
    ##  9    20 Female HS or Less            3     1
    ## 10    20 Female Some College          5     2
    ## # … with 390 more rows

*Step 4. Preparing the brms function*

We presume the formula will be used in brms. Currently we support binary
outcomes. This can be modeled as a binomial, which in brms is of the
form

``` r
fm_brm <- yes | trials(n_responses) ~  age + gender + educ + pct_trump + (1|cd)
```

*Step 5. Cleaning and preparing the ACS data*

We provide wrappers around the great
[tidycensus](https://walker-data.com/tidycensus/) package that produces
ACS data and post-stratification tables from the ACS. A considerable
amount of lookup tables internally will pull out the apporpriate
CD-level counts and label them so that they match up with CCES keys.

``` r
 acs_tab <- get_acs_cces(
              varlist = acscodes_age_sex_educ,
              varlab_df = acscodes_df,
             .year = 2018)

 poststrat <-  get_poststrat(acs_tab, cd_info_2018, fm_brm)
```

### Related Packages

  - <https://github.com/kuriwaki/rcces> has another set of CCES related
    functions, but these are either my own personal functions in
    development (not for production), or specific to non-MRP projects.
  - <https://github.com/kuriwaki/CCES_district-opinion> is a private
    package that uses (among others) this package to process large CCES
    data for MRP at scale.

### Support

This package is a part of the CCES MRP project, supported by NSF Grant
1926424: [Bayesian analytical tools to improve survey estimates for
subpopulations and small
areas](https://nsf.gov/awardsearch/showAward?AWD_ID=1926424). The
contents are based on collaborations and helpful discussions with Ben
Bales, Lauren Kennedy, Mitzi Morris, and Soichiro Yamauchi.
