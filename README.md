Portable Routines for Preparing CCES and ACS data for MRP
================

Cite as:

  - Shiro Kuriwaki (2020). ccesMRPprep: Functions and Data to Prepare
    CCES data for MRP. R package.
    <https://www.github.com/kuriwaki/ccesMRPprep>

### Purpose and Contribution

Multilevel Regression and Poststratification (MRP) is an increasingly
popular method for analyzing surveys, and can be implemented on public
datasets such as the [CCES](https://cces.gov.harvard.edu/) and ACS.
Several helpful tutorials give introductions with sample R code
(Kastellec, Lax, and Phillips,
[2019](https://scholar.princeton.edu/sites/default/files/jkastellec/files/mrp_primer.pdf);
Hanretty, [2019](https://doi.org/10.1177%2F1478929919864773)),

But despite its increasingly popularity, *doing* your own MRP entails
considerable upfront costs specific to the data: downloading the
appropriate survey and contextual, recoding values and generating
post-stratification frames so the survey and census datasets can be
joined. While there already exist some attempts to make a “MRP package”
(e.g. [`gelman/mrp`](https://github.com/gelman/mrp),
[`stan-dev/rstanarm`](https://mc-stan.org/rstanarm/articles/mrp.html),
[`kuriwaki/sparseregMRP`](https://github.com/kuriwaki/sparseregMRP)),
often these packages define general functions with specific input
requirements and not enough on data cleaning and data loading in order
to use those functions.

This package instead provides data loading, processing, and formatting
functions for a particular task: using *CCES data* for MRP. Limiting its
usage to a fixed (but fairly widespread) set of survey data has several
benefits. Its key contributions are functions that are calibrated to a
consistent syntax, pre-built lookup tables and value-key pairs of data
that are based upon a careful reading of data sources, and data loading
functions that use APIs
([`IQSS/dataverse-client-r`](https://github.com/IQSS/dataverse-client-r)
and [`walkerke/tidycensus`](https://github.com/walkerke/tidycensus)) to
reduce the dependency on downloading large files. *Model fitting and
visualization of MRP itself is handled elsewhere.* This package is
focused on the preparation to get there.

## Installation

``` r
# remotes::install_github("kuriwaki/ccesMRPprep")
library(ccesMRPprep)
```

## Vignettes

See the vignettes for more long-form workflow overviews
(`vignette("overview")`) and documentation and explanation of the nature
of the data (`vignette("acs")`). Otherwise, each function and built-in
data provides documentation as well.

## Workflow

See the overview vignette (`vignette("overview")`) from a illustrative
workflow.

## Related Packages

  - [kuriwaki/rcces](https://github.com/kuriwaki/rcces) has another set
    of CCES related functions, but these are either my own personal
    functions in development (not for production), or specific to
    non-MRP projects.
  - [kuriwaki/CCES\_district-opinion](https://github.com/kuriwaki/CCES_district-opinion)
    is a private package that uses (among others) this package to
    process large CCES data for MRP at scale.

## Support

This package is a part of the CCES MRP project, supported by NSF Grant
1926424: [Bayesian analytical tools to improve survey estimates for
subpopulations and small
areas](https://nsf.gov/awardsearch/showAward?AWD_ID=1926424). The
contents are based on collaborations with Ben Bales, Lauren Kennedy,
Mitzi Morris, and Soichiro Yamauchi.