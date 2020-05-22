CCES MRP preparation
================

### `ccesMRPprep`: **Functions to Clean and Prepare CCES data for MRP**

This provides data loading, processing, and formatting functions for a
particular task: using CCES data for Multilevel Regression
Post-stratification. Model fitting and visualization of MRP itself is
handled elsewhere. This package is focused on the preparation to get
there.

``` r
# remotes::install_github("kuriwaki/ccesMRPprep")
library(ccesMRPprep)
library(tidyverse)
```

## Workflow

*Step 1. Loading CCES data*

All CCES data can be downloaded directly from dataverse, using the
development version of the `dataverse` R package. Once you set your
dataverse API token, the function `get_cces_dv` will make this quick and
simple.

``` r
ccc <- get_cces_dv("cumualtive")
```

We will use a built-in sample of 1,000 observations for illustration
(see `?ccc_samp`).

``` r
ccc_samp
```

    ## # A tibble: 1,000 x 17
    ##     year case_id state st    cd    zipcode county_fips   age    race hispanic
    ##    <int>   <int> <chr> <chr> <chr> <chr>   <chr>       <int> <int+l> <int+lb>
    ##  1  2006  439254 Neva… NV    NV-2  89703   32510          20 1 [Whi…       NA
    ##  2  2006  440689 Cali… CA    CA-2  96067   06093          71 1 [Whi…       NA
    ##  3  2006  445845 Colo… CO    CO-5  80922   08041          39 1 [Whi…       NA
    ##  4  2006  452572 Minn… MN    MN-5  55428   27053          74 1 [Whi…       NA
    ##  5  2006  498451 Iowa  IA    IA-2  50060   19185          53 1 [Whi…       NA
    ##  6  2006  502543 Tenn… TN    TN-5  37206   47037          50 1 [Whi…       NA
    ##  7  2006  523050 West… WV    WV-2  25312   54039          55 1 [Whi…       NA
    ##  8  2006  523861 Illi… IL    IL-3  60629   17031          51 1 [Whi…       NA
    ##  9  2006  532881 Minn… MN    MN-7  55396   27143          44 1 [Whi…       NA
    ## 10  2006  553375 Ohio  OH    OH-11 44112   39035          53 1 [Whi…       NA
    ## # … with 990 more rows, and 7 more variables: educ <int+lbl>, faminc <fct>,
    ## #   marstat <int+lbl>, newsint <int+lbl>, vv_turnout_gvm <fct>,
    ## #   voted_pres_16 <fct>, economy_retro <int+lbl>

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

*Step 4. Preparing the brms function*

*Step 5. Cleaning and preparing the ACS data*

### Related Packages

  - <https://github.com/kuriwaki/rcces> has another set of CCES related
    functions, but these are either my own personal functions in
    development (not for production), or specific to non-MRP projects.
  - <https://github.com/kuriwaki/CCES_district-opinion> is a private
    package that uses (among others) this package to process large CCES
    data for MRP at scale.
