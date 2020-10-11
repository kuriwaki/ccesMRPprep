#' Sample cumulative CCES data
#'
#' The cumulative CCES stacks CCES common content for all years and harmonizes
#' the variables, which makes it ideal for using it for MRP.  This is a sample for
#' illustration; see \link{get_cces_dataverse} to get the full data.
#'
#' @details This is encoded as a RDS file with some variables stored in the Stata-based
#' integer + labelled class instead of as factors. See the CCES cumulative guide
#' for the difference between the two and how to go from one to another.
#'
#' @format A data frame with 1000 observations. See the CCES cumulative codebook
#' for more explanation of the variables
#' \describe{
#'   \item{year}{Year of the common content}
#'   \item{case_id}{Respondent identifier (unique within each year)}
#'   \item{state}{State (in the form of \code{state.name})}
#'   \item{st}{State Abbreviation (in the form of \code{state.abb})}
#'   \item{cd}{Congressional district at the time of the survey. See \link{ccc_std_demographics}
#'             for how it is and should be standardized.}
#'   \item{zipcode}{Zipcode (See codebook)}
#'   \item{county_fips}{County FIPS code (See codebook)}
#'   \item{gender}{Gender (equivalent to sex in ACS for the purposes of this package)}
#'   \item{age}{Age, in integers}
#'   \item{race}{Race and ethnicity}
#'   \item{hispanic}{Hispanic identifier}
#'   \item{educ}{Education level}
#'   \item{faminc}{Family Income}
#'   \item{marstat}{Martial status}
#'   \item{newsint}{Frequency of following the news}
#'   \item{vv_turnout_gvm}{Validated turnout in general election}
#'   \item{voted_pres_16}{Self-reported vote choice for 2016}
#'   \item{economy_retro}{Opinion on retrospective economy}
#' }
#' @source Kuriwaki, Shiro, 2018, "Cumulative CCES Common Content (2006-2018)",
#' <https://doi.org/10.7910/DVN/II2DB6>, Harvard Dataverse
#'
#' @examples
#' library(ccesMRPprep)
#' ccc_samp
#'
"ccc_samp"


#' Sample 2018 Common Content
#'
#' 1000 rows from th 2018 CCES Common Content. Contains all columns, retaining the
#' `haven_labelled` class. This is <doi:10.7910/DVN/ZSBZ7K/H5IDTA> originally read
#' in using `read_dta` via `get_cces_dataverse()`. To search for variable by its content,
#' `questionr::lookfor` (or `rcces::vartab`) is a useful option (see example).
#'
#' @details See the 2018 Codebook in the DOI below for question wording of
#' each column. To use the harmonized and easier-to-use versions of common variables
#' like geography, partisan ID, demographics and vote choice, use the cumulative
#' common content, of which 2018 is a subset. A sample of the cumulative is contained
#' in this package as `?ccc_samp`.
#'
#' @source "Brian Schaffner; Stephen Ansolabehere; Sam Luks, 2019,
#' "CCES Common Content, 2018", <doi:https://doi.org/10.7910>, Harvard Dataverse V6.
#'
#' @examples
#'
#' # use questionr::lookfor to search the label and labels
#' questionr::lookfor(cc18_samp, "Trump")
#'
#' # all data
#' cc18_samp
#'
"cc18_samp"
