#' @title Preview fuzzy-matching results before downloading
#'
#' @description \code{FFmatch} shows how each entry in \code{inputlist} would be
#' matched to an available dataset by the fuzzy-matching logic inside
#' \code{\link{FFdownload}}.  Use this to verify matches before triggering a
#' download, especially when dataset names are abbreviated or partially specified.
#'
#' @param inputlist character vector of (partial) dataset names to match, as you
#' would pass to the \code{inputlist} argument of \code{\link{FFdownload}}.
#' @param exclude_daily logical. If \code{TRUE} (default), daily datasets are
#' excluded from the candidate pool.
#'
#' @return A data frame (or tibble) with one row per entry in \code{inputlist} and
#' columns:
#' \describe{
#'   \item{requested}{The input string as supplied.}
#'   \item{matched}{The dataset name that would be selected by \code{FFdownload}.}
#'   \item{edit_distance}{Raw Levenshtein edit distance between \code{requested}
#'     and \code{matched}.}
#'   \item{similarity}{1 - edit_distance / nchar(matched), clamped to [0, 1].
#'     Values below 0.3 suggest a potentially wrong match.}
#' }
#'
#' @examples
#' \dontrun{
#' FFmatch(c("Research_Data_Factors", "Momentum", "ST_Reversal"))
#' }
#'
#' @importFrom utils adist
#'
#' @export
FFmatch <- function(inputlist, exclude_daily = TRUE) {
  fl        <- FFlist(exclude_daily = exclude_daily)
  available <- fl$name

  dist_mat   <- adist(x = inputlist, y = available, ignore.case = TRUE)
  best_idx   <- apply(dist_mat, 1, which.min)
  best_dists <- dist_mat[cbind(seq_along(inputlist), best_idx)]

  matched_names <- available[best_idx]
  similarity    <- pmax(0, 1 - best_dists / pmax(nchar(matched_names), 1L))

  result <- data.frame(
    requested     = inputlist,
    matched       = matched_names,
    edit_distance = best_dists,
    similarity    = round(similarity, 3),
    stringsAsFactors = FALSE
  )

  rownames(result) <- NULL

  if (requireNamespace("tibble", quietly = TRUE)) {
    result <- tibble::as_tibble(result)
  }

  result
}
