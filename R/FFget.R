#' @title Download and return a single French dataset directly
#'
#' @description \code{FFget} is a convenience wrapper around \code{\link{FFdownload}}
#' that downloads one named dataset and returns it directly into the R session —
#' no intermediate \code{.RData} file, no \code{load()} call required.
#'
#' The function uses all of \code{FFdownload}'s parsing engine, so every
#' sub-table present in the original CSV (value-weighted returns, equal-weighted
#' returns, number of firms, etc.) is available in the returned list.
#'
#' @param name character. The dataset name as it appears in \code{FFlist()$name},
#' e.g. \code{"F-F_Research_Data_Factors"} or \code{"F-F_Momentum_Factor"}.
#' Fuzzy matching is applied, so partial names work (check with
#' \code{\link{FFmatch}} first).
#' @param frequency character. Which frequency sub-list to extract.  One of
#' \code{"monthly"} (default), \code{"annual"}, or \code{"daily"}.  Set to
#' \code{NULL} to return all three frequencies as a named list.
#' @param subtable character. Name of the sub-table within the chosen frequency,
#' e.g. \code{"Temp2"} or \code{"annual_factors:_january-december"}.  Set to
#' \code{NULL} (default) to return all sub-tables as a named list.
#' @param exclude_daily logical. Passed to \code{\link{FFdownload}}. Default
#' \code{TRUE}.
#' @param na_values numeric vector of sentinel values to replace with \code{NA}.
#' Defaults to \code{c(-99, -999, -99.99)} — the values French uses for missing
#' observations.  Set to \code{NULL} to disable replacement.
#' @param format character. \code{"tbl"} (default) or \code{"xts"}.
#'
#' @return A tibble, \code{xts} object, or named list, depending on
#' \code{frequency}, \code{subtable}, and \code{format}.
#'
#' @examples
#' \dontrun{
#' # Get the main monthly Fama-French 3-factor table directly as a tibble
#' ff3 <- FFget("F-F_Research_Data_Factors", subtable = "Temp2")
#' head(ff3)
#'
#' # Get all sub-tables for the 5-factor model
#' ff5_all <- FFget("F-F_Research_Data_5_Factors_2x3", subtable = NULL)
#' names(ff5_all)
#'
#' # Get annual data as xts
#' ff3_ann <- FFget("F-F_Research_Data_Factors", frequency = "annual", format = "xts")
#' }
#'
#' @export
FFget <- function(name,
                  frequency  = "monthly",
                  subtable   = NULL,
                  exclude_daily = TRUE,
                  na_values  = c(-99, -999, -99.99),
                  format     = "tbl") {

  output_file <- tempfile(fileext = ".RData")
  tempd       <- tempfile()
  dir.create(tempd, showWarnings = FALSE)

  FFdata <- FFdownload(
    output_file   = output_file,
    tempd         = tempd,
    exclude_daily = exclude_daily,
    download      = TRUE,
    download_only = FALSE,
    inputlist     = name,
    format        = format,
    na_values     = na_values,
    return_data   = TRUE
  )

  if (is.null(FFdata) || length(FFdata) == 0) {
    stop("No data returned for '", name, "'. Check FFmatch() for available datasets.", call. = FALSE)
  }

  # Find the matching key (FFdownload adds "x_" prefix and strips path/extension)
  key <- names(FFdata)[1]   # only one dataset was requested

  dataset <- FFdata[[key]]

  if (is.null(frequency)) return(dataset)

  if (!frequency %in% names(dataset)) {
    stop("Frequency '", frequency, "' not found in '", key,
         "'. Available: ", paste(names(dataset), collapse = ", "), call. = FALSE)
  }

  freq_data <- dataset[[frequency]]

  if (length(freq_data) == 0) {
    warning("No data for frequency '", frequency, "' in '", key, "'.", call. = FALSE)
    return(NULL)
  }

  if (is.null(subtable)) return(freq_data)

  if (!subtable %in% names(freq_data)) {
    stop("Sub-table '", subtable, "' not found. Available: ",
         paste(names(freq_data), collapse = ", "), call. = FALSE)
  }

  freq_data[[subtable]]
}
