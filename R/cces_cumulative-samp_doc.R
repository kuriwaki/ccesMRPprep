#' Sample cumulative CCES data
#'
#' The cumulative CCES stacks CCES common content for all years and harmonizes
#' the variables, which makes it ideal for using it for MRP.  This is a sample for
#' illustration;see \link{get_cces_dv} to get the full data.
#'
#' @format A data frame with 1000 observations. See the CCES cumulative codebook
#' for more explanation of the varaibles
#' \describe{
#'   \item{year}{Year of the common content}
#'   \item{case_id}{Respondent identifier (unique within each year)}
#'   \item{cd}{Congressional district}
#'   \item{vv_turnout_gvm}{Validated turnout in general election}
#'   \item{voted_pres_16}{Self-reported vote choice for 2016}
#'   \item{economy_retro}{Opinion on retrospective economy}
#'   ...
#' }
#' @source Kuriwaki, Shiro, 2018, "Cumulative CCES Common Content (2006-2018)",
#' <https://doi.org/10.7910/DVN/II2DB6>, Harvard Dataverse
#'
#' @examples
#' library(ccesMRPprep)
#' ccc_samp
#'
"ccc_samp"
