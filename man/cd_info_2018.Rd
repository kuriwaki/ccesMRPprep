% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datadoc_cd-info.R
\docType{data}
\name{cd_info_2018}
\alias{cd_info_2018}
\alias{elec_NY}
\title{Congressional District level information}
\format{
\code{cd_info_2018} is a dataframe with the 435 Congressional
Districts, one row per cd.
\describe{
\item{year}{The year for the district line. A congressional district's
actual geography can change year to year, and significantly so in different
redistricting cycles. 2019 indicates the data about voteshare and place names
corresponds to district lines as of 2019.}
\item{cd}{District code. The formatting corresponds to the CCES cumulative
coding of \code{cd}: a two-letter abbreviation for the state followed by
a dash, and the district number padded with zeros to the left to be of length
2. At-large districts like Delaware are given a "-01" for the district number.}
\item{pct_trump, pct_romney, pct_mccain}{The voteshare of presidential candidates
in that district for the given year. E.g. the \code{pct_mccain} data when \code{cd_year == 2018}
represents the percent of the vote by McCain in 2008 for that district \emph{under 2018 lines.}}
\item{dailykos_name}{The unique descriptive name for the district given by Daily Kos.
See Source for full citation.}
\item{largest_place}{The largest place in the district given by Daily Kos. Multiple districts may
have the largest place.}
}

An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 27 rows and 6 columns.
}
\source{
The Daily Kos Elections naming guide to the nation's congressional districts.
\url{https://bit.ly/2XsFI5W}

Daily Kos, "2008, 2012, & 2016 results for districts used in 2018."
\url{https://bit.ly/3bXtAPB}
}
\usage{
cd_info_2018

elec_NY
}
\description{
Some of the most consequential variables to include in MRP are at the
district-level. We include one such data for congressional districts. All data
is collected by Daily Kos.
}
\examples{
head(cd_info_2018)
head(elec_NY)
}
\keyword{datasets}
