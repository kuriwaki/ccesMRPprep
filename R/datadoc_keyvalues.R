#' CCES-ACS variable key value pairs for recoding
#'
#' These value-value tables are useful for recoding the values of
#' from one dataset (CCES) so that they can be merged immediately with another
#' (ACS).  These get used internally in \link{ccc_std_demographics}, but they are
#' available as built in datasets.
#'
#' @details These tibbles themselves are not key-values pair in a strict sense because
#' the dataframe tries to have two recodes CCES to common and ACS to common and so for
#' a given recode, rows are not distinct. To avoid duplicating rows inadvertently,
#' use the `dplyr::distinct` to reduce the key to two columns with unique rows.
#'
#' @name keyvalue
#'
#' @format All keys are tibbles with one row per recoding value.
#'
#' @importFrom tibble tibble
#'
#' @examples
#'  library(ccesMRPprep)
#'  race_key
#'  educ_key
#'  gender_key
#'  age5_key
#'  age10_key
#'  states_key
NULL

#' @rdname keyvalue
#'
#' @format ### \code{race_key}
#'  \describe{
#'  \item{race}{An labelled integer of class haven::labelled.
#'     Most compact form of both sources and the values both will get recoded
#'     to in MRP.}
#'  \item{race_cces}{Labelled versions of the CCES race codings. These are of the
#'    same class as the CCES cumulative file.}
#'  \item{race_cces_chr}{Labels for the first column, in characters}
#'  \item{race_acs}{Corresponding character in the ACS data via the tidycensus package}
#'  \item{race_5}{A numeric value underlying the \code{race} label.}
#'  }
"race_key"

#' @rdname  keyvalue
#' @format ### \code{gender_key}:
#'  \describe{
#'  \item{gender}{An labelled integer of class haven::labelled. Target variable}
#'  \item{gender_chr}{Character to recode from. CCES and ACS use the same values.}
#'  }
"gender_key"

#' @rdname  keyvalue
#' @format ### \code{educ_key}
#'  For mapping ACS data values for education e.g. in \link{get_acs_cces}:
#'  \describe{
#'  \item{educ_cces_chr}{Character to recode from, in CCES}
#'  \item{educ_chr}{Character to recode from, in ACS.}
#'  \item{educ}{An labelled integer of class haven::labelled. Target variable}
#'  }
"educ_key"


#' @rdname  keyvalue
#' @format ### \code{age5_key}
#'  Age bins, 5-ways, used in \link{acscodes_age_sex_educ}. Use \link{ccc_bin_age}
#'  to recode CCES variable
#'  \describe{
#'  \item{age}{An labelled integer of class haven::labelled. Target variable.}
#'  \item{age_chr}{Character to recode from, in ACS}
#'  }
"age5_key"

#' @rdname  keyvalue
#' @format ###  \code{age10_key}: Age bins, 10-ways, used in \link{acscodes_age_sex_race}:
#' \describe{
#'  \item{age}{An labelled integer of class `haven::haven_labelled`. Target variable.}
#'  \item{age_chr}{Character to recode from, in ACS}
#'  }
"age10_key"

#' @rdname keyvalue
#' @format ###  \code{states_key}: State codes and regions:
#' \describe{
#' \item{st}{State two-letter abbreviation `state.abb`}
#' \item{state}{State full name via `state.name`}
#' \item{st_fips}{Integer, state FIPS code}
#' \item{region}{Census region (Northeast, Midwest, South, West)}
#' \item{division}{Census division (New England, Middle Atlantic,
#'   South Atlantic, East South Central, West South Central,
#'   East North Central, "West North Central, Mountain, Pacific)}
#' }
"states_key"
