% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datadoc_cps-onewaytabs.R
\docType{data}
\name{cps_onewaytabs}
\alias{cps_onewaytabs}
\title{CPS variable labels and counts}
\format{
An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 3258 rows and 5 columns.
}
\usage{
cps_onewaytabs
}
\description{
One summary of the CPS, by reporting all year-by-year raw counts of the microdata
for main demographic variables. In other words, it tabulates all the unique
values of each main variable, and shows its sample size.
}
\examples{
head(cps_onewaytabs)
}
\seealso{
The \href{https://www.shirokuriwaki.com/ccesMRPprep/articles/cps.html}{Vignette on CPS}.

\describe{
\item{variable}{Name of the variable, as it appears in the CPS extract}
\item{year}{Year of the November supplement}
\item{name}{Name (or label) of the value in the November supplement}
\item{value}{The integer value of the value in the value. The name and value
together form the labelled class. See the \code{vignette("derived")} vignette.}
\item{n}{Number of raw observations (sample size) in the November supplement
of the CPS.}
}
}
\keyword{datasets}
