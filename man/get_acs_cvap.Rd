% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_acs-poststrat.R
\name{get_acs_cvap}
\alias{get_acs_cvap}
\title{Obtain CVAP proportions by race}
\usage{
get_acs_cvap(
  race = "white",
  varlab_df = ccesMRPprep::acscodes_df,
  year = 2018,
  states = NULL,
  dataset = "acs1"
)
}
\arguments{
\item{race}{Race of interest. Either \code{"white"} (for non-Hispanic Whites),
\code{"hispanic"}, \code{"black"}, \code{"native"} (for Native Americans including American
Indians and Alaskan Natives), \code{"asian"}.}

\item{varlab_df}{a dataframe that appends the categories based on the varcode}

\item{year}{The year of the ACS to get. Because of data availability limitations, this is
capped to 2010-2018.}

\item{states}{A vector of states to subset to. Gets passed onto the new \code{state}
argument in \code{tidycensus::get_acs()}, which defaults to NULL.}

\item{dataset}{Which type of ACS to get. Defaults to \code{"acs1"} for ACS-5 year.
Use \code{"acs5"} for 5-year.}
}
\description{
Returns the Citizen Voting Age Population by Congressional District. A custom
call to \code{get_acs_cces}. In the output, \code{cvap_total} is the total CVAP of
all races, \code{cvap_race} is the count of CVAP for the given race, and \code{cvap_frac}
is the fraction.
}
\details{
Future versions will allow CVAP race fractions by geographies other than CD.
}
\examples{
 get_acs_cvap("white")

}
\seealso{
\link{get_acs_cces}
}
