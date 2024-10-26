Portable Routines for Preparing CCES and ACS data for MRP
================

<!-- badges: start -->

[![check-standard](https://github.com/kuriwaki/ccesMRPprep/actions/workflows/check-standard.yml/badge.svg)](https://github.com/kuriwaki/ccesMRPprep/actions/workflows/check-standard.yml)
<!-- badges: end -->

Cite as:

- Shiro Kuriwaki (2020). ccesMRPprep: Functions and Data to Prepare CCES
  data for MRP. R package. <https://www.github.com/kuriwaki/ccesMRPprep>
- Or see the related article, Kuriwaki et al., “The Geography of
  Racially Polarized Voting: Calibrating Surveys at the District Level.”
  *American Political Science Review* (2023)

### Purpose and Contribution

Multilevel Regression and Poststratification (MRP) is an increasingly
popular method for analyzing surveys, and can be implemented on public
datasets such as the [CES/CCES](https://cces.gov.harvard.edu/) and ACS.
Several helpful tutorials give introductions with sample R code
(Kastellec, Lax, and Phillips,
[2019](https://scholar.princeton.edu/sites/default/files/jkastellec/files/mrp_primer.pdf);
Hanretty, [2019](https://doi.org/10.1177%2F1478929919864773)),

But despite its increasingly popularity, *doing* one’s own MRP entails
considerable upfront costs: downloading the appropriate survey and
contextual data, recoding survey values to match with their Census
counterparts, and generating population frames to post-stratify on,
potentially by merging different datasets. While there already exist
some packages for MRP
(e.g. [`gelman/mrp`](https://github.com/gelman/mrp),
[`stan-dev/rstanarm`](https://mc-stan.org/rstanarm/articles/mrp.html),
[`kuriwaki/sparseregMRP`](https://github.com/kuriwaki/sparseregMRP)),
these often define generic functions and leave users to prepare the
cleaned data to use those functions with specific requirements.

The **ccesMRPprep** package instead provides data loading, processing,
and formatting functions for a particular task: using *CES/CCES data*
(Cooperative Election Study, formerly the Cooperative Congressional
Election Study) for MRP. Limiting its usage to a fixed set of survey
data has several benefits. Its key contributions are functions that are
calibrated to a consistent syntax, pre-built lookup tables and value-key
pairs of data that are based upon a careful reading of data sources, and
data loading functions that use APIs
([`IQSS/dataverse-client-r`](https://github.com/IQSS/dataverse-client-r)
and [`walkerke/tidycensus`](https://github.com/walkerke/tidycensus)) to
reduce the dependency on downloading large files.

*Model fitting and visualization of MRP itself* is handled in the
companion package,
[**`kuriwaki/ccesMRPrun`**](https://www.github.com/kuriwaki/ccesMRPrun).
This package is focused on the preparation to get there.

## Installation

``` r
# remotes::install_github("kuriwaki/ccesMRPprep")
library(ccesMRPprep)
```

## Getting Started

See `vignette("overview")` for a overview of the steps involved.

For documentation of the data sources, see `vignette("acs")` for the
Census and `vignette("derived")` for CCES variables.

A related package also covers more advanced techniques to expand
population tables. See
[`kuriwaki/synthjoint`](https://www.github.com/kuriwaki/synthjoint) for
an overview and demonstration.

Each function and built-in data provides documentation as well.

## Workflow

See the overview vignette (`vignette("overview")`) from a illustrative
workflow.

## Data Sources

Function-specific pages will detail the documentation used in each
function. Here is a manual compilation:

| Information                        | Source            | Citation and URL (if public)                                                                                                                                                                      |
|:-----------------------------------|:------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CCES Covariates                    | Cumulative CCES   | Shiro Kuriwaki, “Cumulative CCES Common Content”. <https://doi.org/10.7910/DVN/II2DB6>                                                                                                            |
| CCES Outcomes                      | Each Year’s CCES  | Stephen Ansolabehere, Sam Luks, and Brian Schaffner. “CCES Common Content” (varies by year). <https://cces.gov.harvard.edu/>                                                                      |
| Poststratification                 | Census Bureau ACS | American Community Survey. Extracted via [tidycensus package](https://github.com/walkerke/tidycensus). See [ACS vignette](https://www.shirokuriwaki.com/ccesMRPprep/articles/acs.html)            |
| CD-level Presidential Voteshare    | Daily Kos         | Daily Kos, [The ultimate Daily Kos Elections guide to all of our data sets](https://www.dailykos.com/stories/2018/2/21/1742660/-The-ultimate-Daily-Kos-Elections-guide-to-all-of-our-data-sets#1) |
| State-level Presidential Voteshare | MEDSL             | MIT Election Data and Science Lab, 2017, “U.S. President 1976–2016”. <https://doi.org/10.7910/DVN/42MVDX>                                                                                         |

## Related Packages

- [kuriwaki/rcces](https://github.com/kuriwaki/rcces) has another set of
  CCES related functions, but these are either my own personal functions
  in development (not for production), or specific to non-MRP projects.

## Support

This package is a part of the CCES MRP project, supported by NSF Grant
1926424: [Bayesian analytical tools to improve survey estimates for
subpopulations and small
areas](https://nsf.gov/awardsearch/showAward?AWD_ID=1926424). The
contents are based on collaborations and discussions with Ben Bales,
[Lauren Kennedy](https://jazzystats.com/about/), and Mitzi Morris.
