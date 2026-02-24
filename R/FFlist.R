#' @title List available datasets on Kenneth French's website
#'
#' @description \code{FFlist} scrapes Kenneth French's data library and returns a
#' data frame (or tibble) of available datasets with their names and download URLs.
#' This replaces the \code{listsave} workaround in \code{\link{FFdownload}} and
#' makes the dataset inventory directly usable with \code{dplyr::filter()} or
#' \code{View()}.
#'
#' @param exclude_daily logical. If \code{TRUE} (default), daily datasets are
#' excluded from the returned list.
#'
#' @return A data frame (or tibble if the \pkg{tibble} package is available) with
#' columns:
#' \describe{
#'   \item{name}{Dataset name, as used in \code{inputlist} and as key in the
#'     \code{FFdata} list (without the leading \code{x_} prefix and without the
#'     \code{_CSV.zip} suffix).}
#'   \item{file_url}{Full HTTPS URL of the zip file.}
#'   \item{is_daily}{Logical flag indicating whether the dataset contains daily data.
#'     Only present when \code{exclude_daily = FALSE}.}
#' }
#'
#' @examples
#' \dontrun{
#' # Browse all available monthly/annual datasets
#' fl <- FFlist()
#' head(fl, 10)
#'
#' # Include daily datasets
#' FFlist(exclude_daily = FALSE)
#'
#' # Filter with dplyr
#' library(dplyr)
#' FFlist() |> filter(grepl("Momentum", name))
#' }
#'
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes
#'
#' @export
FFlist <- function(exclude_daily = TRUE) {
  URL <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"
  pg      <- xml2::read_html(URL)
  Flinks  <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
  Findex  <- grep("CSV.zip", Flinks)

  raw_links  <- Flinks[Findex]
  clean_links <- gsub("ftp/", "", raw_links)

  # Derive the dataset name: strip path prefix and _CSV.zip suffix
  names_clean <- gsub("^.*/", "", clean_links)                          # basename
  names_clean <- gsub("_CSV\\.zip$", "", names_clean, ignore.case = TRUE)

  is_daily <- grepl("daily", names_clean, ignore.case = TRUE)

  result <- data.frame(
    name      = names_clean,
    file_url  = paste0("https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/", raw_links),
    is_daily  = is_daily,
    stringsAsFactors = FALSE
  )

  if (exclude_daily) {
    result <- result[!result$is_daily, ]
    result$is_daily <- NULL
  }

  rownames(result) <- NULL

  if (requireNamespace("tibble", quietly = TRUE)) {
    result <- tibble::as_tibble(result)
  }

  result
}
