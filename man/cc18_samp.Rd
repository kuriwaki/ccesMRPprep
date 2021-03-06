% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datadoc_cces-common-samp.R
\docType{data}
\name{cc18_samp}
\alias{cc18_samp}
\title{Sample 2018 Common Content}
\format{
An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 1000 rows and 526 columns.
}
\source{
"Brian Schaffner; Stephen Ansolabehere; Sam Luks, 2019,
"CCES Common Content, 2018", \url{doi:https://doi.org/10.7910}, Harvard Dataverse V6.
}
\usage{
cc18_samp
}
\description{
1000 rows from th 2018 CCES Common Content. Contains all columns, retaining the
\code{haven_labelled} class. This is \url{doi:10.7910/DVN/ZSBZ7K/H5IDTA} originally read
in using \code{read_dta} via \code{get_cces_dataverse()}. To search for variable by its content,
\code{questionr::lookfor} (or \code{rcces::vartab}) is a useful option (see example).
}
\details{
See the 2018 Codebook in the DOI below for question wording of
each column. To use the harmonized and easier-to-use versions of common variables
like geography, partisan ID, demographics and vote choice, use the cumulative
common content, of which 2018 is a subset. A sample of the cumulative is contained
in this package as \code{?ccc_samp}.
}
\examples{

# use questionr::lookfor to search the label and labels
questionr::lookfor(cc18_samp, "Trump")

# all data
cc18_samp

}
\keyword{datasets}
