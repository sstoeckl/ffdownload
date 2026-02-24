#' @title Downloads Datasets from Kenneth French's Website
#'
#' @description \code{FFdownload} returns an RData file with all (possibility to exclude the large daily) datasets from Kenneth French's Website.
#' Should help researchers to work with the datasets and update the regularly. Allows for reproducible research. Be aware that processing
#' (especially when including daily files) takes quite a long time!
#'
#' @param output_file name of the .RData file to be saved (include path if necessary)
#' @param tempd specify if you want to keep downloaded files somewhere save. Seems to be necessary for
#' reproducible research as the files on the website do change from time to time
#' @param exclude_daily excludes the daily datasets (are not downloaded) ==> speeds the process up considerably
#' @param download set to TRUE if you actually want to download again. set to false and specify tempd to keep processing the already downloaded files
#' @param download_only set to FALSE if you want to process all your downloaded files at once
#' @param listsave if not NULL, the list of unzipped files is saved here (good for processing only a limited number of files through inputlist).
#' Is written before inputlist is processed.
#' @param inputlist if not NULL, FFdownload tries to match the names from the list with the list of zip-files
#' @param format (set to xts) specify "xts" or "tbl"/"tibble" for the output format of the nested lists
#' @param na_values numeric vector of sentinel values to replace with \code{NA} (e.g. \code{c(-99, -999, -99.99)}).
#' French's files use -99.99 or -999 to denote missing observations. Default \code{NULL} preserves the original
#' behaviour (no replacement).
#' @param return_data logical. If \code{TRUE}, the \code{FFdata} list is returned invisibly in addition to being
#' saved to \code{output_file}. Default \code{FALSE} preserves the original behaviour.
#' @param action convenience alternative to the \code{download}/\code{download_only} flag pair.
#' One of \code{"all"} (download + process), \code{"list_only"} (save file list only),
#' \code{"download_only"} (download but do not process), or \code{"process_only"} (process already-downloaded
#' files from \code{tempd}). When \code{action} is provided it overrides \code{download} and
#' \code{download_only}. Default \code{NULL} retains the original flag-based behaviour.
#' @param cache_days numeric. When greater than 0 and less than \code{Inf}, zip files already present in
#' \code{tempd} that are younger than \code{cache_days} days are reused instead of being re-downloaded.
#' Default \code{Inf} preserves the original behaviour (never re-download an existing file).
#' @param match_threshold numeric in [0,1]. If the similarity between a requested \code{inputlist} entry and
#' its fuzzy-matched filename is below this threshold a warning is emitted. Use \code{FFmatch()} to inspect
#' matches before downloading. Default \code{0.3}.
#'
#' @return Invisibly returns the \code{FFdata} list when \code{return_data = TRUE}; otherwise called for its
#' side-effect of writing an RData file.
#'
#' @examples
#' \dontrun{
#' tempf <- tempfile(fileext = ".RData"); outd <- paste0(tempdir(),"/",format(Sys.time(), "%F_%H-%M"))
#' temptxt <- tempfile(fileext = ".txt")
#'
#' # Example 1: Use FFdownload to get a list of all monthly zip-files. Save that list as temptxt.
#'
#' FFdownload(exclude_daily=TRUE,download=FALSE,download_only=TRUE,listsave=temptxt)
#' read.delim(temptxt,sep = ",")
#' # set vector with only files to download (we try a fuzzyjoin, so "Momentum" should be enough to get
#' # the Momentum Factor)
#' inputlist <- c("Research_Data_Factors","Momentum_Factor","ST_Reversal_Factor","LT_Reversal_Factor")
#' # Now process only these files if they can be matched (download only)
#' FFdownload(exclude_daily=FALSE,tempd=outd,download=TRUE,download_only=FALSE,
#' inputlist=inputlist,output_file = tempf)
#' list.files(outd)
#' # Then process all the downloaded files
#' FFdownload(output_file = tempf, exclude_daily=TRUE,tempd=outd,download=FALSE,
#' download_only=FALSE,inputlist=inputlist)
#' load(tempf); FFdata$`x_F-F_Momentum_Factor`$monthly$Temp2[1:10]
#'
#' # Example 2: Use action parameter and return data directly
#'
#' FFdata <- FFdownload(
#'   inputlist = c("F-F_Research_Data_5_Factors_2x3"),
#'   output_file = tempf,
#'   action = "all",
#'   na_values = c(-99, -999, -99.99),
#'   return_data = TRUE
#' )
#' FFdata$`x_F-F_Research_Data_5_Factors_2x3`$monthly$Temp2
#' }
#'
#' @importFrom utils download.file unzip
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes
#' @importFrom utils adist write.csv txtProgressBar setTxtProgressBar
#'
#' @export
FFdownload <- function(output_file = "data.Rdata", tempd = NULL, exclude_daily = FALSE,
                       download = TRUE, download_only = FALSE, listsave = NULL,
                       inputlist = NULL, format = "xts",
                       # New parameters (all backward-compatible: defaults reproduce original behaviour)
                       na_values = NULL,
                       return_data = FALSE,
                       action = NULL,
                       cache_days = Inf,
                       match_threshold = 0.3) {

  # ------------------------------------------------------------------
  # Handle action parameter (overrides download/download_only if given)
  # ------------------------------------------------------------------
  if (!is.null(action)) {
    action <- match.arg(action, c("all", "list_only", "download_only", "process_only"))
    download      <- action %in% c("all", "download_only")
    download_only <- action %in% c("list_only", "download_only")
  }

  # ------------------------------------------------------------------
  # Step 1: Get list of all CSV zip-files from Kenneth French's website
  # ------------------------------------------------------------------
  message("Step 1: getting list of all the csv-zip-files!\n")
  URL <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"
  pg <- xml2::read_html(URL)
  Flinks <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
  Findex <- grep("CSV.zip", Flinks)
  Fdaily <- grep("daily", Flinks[Findex], ignore.case = TRUE)

  Flinks_csv         <- Flinks[Findex]
  Flinks_csv_daily   <- Flinks[Findex][Fdaily]
  Flinks_csv_nodaily <- Flinks[Findex][-Fdaily]

  # Save list of links if requested
  if (!is.null(listsave)) { write.csv(gsub("ftp/", "", Flinks_csv), file = listsave) }

  # Build final download list, with optional fuzzy-match quality warnings
  if (!is.null(inputlist)) {
    if (exclude_daily) {
      dist_mat    <- adist(x = inputlist, y = Flinks_csv_nodaily, ignore.case = TRUE)
      best_idx    <- apply(dist_mat, 1, which.min)
      best_dists  <- dist_mat[cbind(seq_along(inputlist), best_idx)]
      Flinks_final <- Flinks_csv_nodaily[best_idx]
    } else {
      dist_mat_nd  <- adist(x = inputlist, y = Flinks_csv_nodaily, ignore.case = TRUE)
      best_idx_nd  <- apply(dist_mat_nd, 1, which.min)
      best_dists   <- dist_mat_nd[cbind(seq_along(inputlist), best_idx_nd)]
      Flinks_final <- Flinks_csv_nodaily[best_idx_nd]
      dist_mat_d   <- adist(x = inputlist, y = Flinks_csv_daily, ignore.case = TRUE)
      best_idx_d   <- apply(dist_mat_d, 1, which.min)
      Flinks_final <- c(Flinks_final, Flinks_csv_daily[best_idx_d])
    }
    # Warn when the fuzzy match looks unreliable
    for (i in seq_along(inputlist)) {
      matched_name <- gsub("ftp/", "", Flinks_final[i])
      sim <- 1 - best_dists[i] / max(nchar(matched_name), 1L)
      if (sim < match_threshold) {
        warning("Low-confidence fuzzy match: '", inputlist[i], "' matched to '", matched_name,
                "' (similarity = ", round(sim, 2), "). Use FFmatch() to verify before downloading.",
                call. = FALSE)
      }
    }
  } else {
    Flinks_final <- if (exclude_daily) Flinks_csv_nodaily else Flinks_csv
  }

  # ------------------------------------------------------------------
  # Step 2: Download zip-files (with cache_days check)
  # ------------------------------------------------------------------
  if (download) {
    message("Step 2: Downloading ", length(Flinks_final), " zip-files\n")
    temp_download <- tempfile(pattern = "")
    dir.create(temp_download, showWarnings = FALSE)

    for (i in seq_along(Flinks_final)) {
      Fdest     <- gsub("ftp/", "", Flinks_final[i])
      dest_path <- file.path(temp_download, Fdest)

      # Check cache: if tempd has a recent-enough copy, reuse it
      skip_download <- FALSE
      if (!is.null(tempd) && is.finite(cache_days)) {
        cached_path <- file.path(tempd, Fdest)
        if (file.exists(cached_path)) {
          age_days <- as.numeric(difftime(Sys.time(), file.info(cached_path)$mtime, units = "days"))
          if (age_days <= cache_days) {
            file.copy(cached_path, dest_path)
            skip_download <- TRUE
          }
        }
      }

      if (!skip_download) {
        utils::download.file(
          paste0("https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/", Flinks_final[i]),
          dest_path, quiet = TRUE
        )
      }
    }

    # Optionally copy to persistent tempd
    if (!is.null(tempd)) {
      dir.create(tempd, showWarnings = FALSE)
      file.copy(
        from      = file.path(temp_download, gsub("ftp/", "", Flinks_final)),
        to        = tempd,
        recursive = TRUE
      )
    }
  }

  # ------------------------------------------------------------------
  # Step 3: Process CSV files
  # ------------------------------------------------------------------
  if (!download_only) {
    if (!download && is.null(tempd)) {
      stop("No directory given for reading files!")
    } else if (download && is.null(tempd)) {
      tempd <- temp_download
    }

    zip_files <- list.files(tempd, full.names = TRUE,  pattern = "\\.zip$", ignore.case = TRUE)
    lapply(zip_files, function(x) unzip(zipfile = x, exdir = tempd))

    csv_files  <- list.files(tempd, full.names = TRUE,  pattern = "\\.csv$", ignore.case = TRUE)
    csv_files2 <- list.files(tempd, full.names = FALSE, pattern = "\\.csv$", ignore.case = TRUE)

    if (length(grep("daily", csv_files2, ignore.case = TRUE))) {
      csv_files2_daily   <- csv_files2[ grep("daily", csv_files2, ignore.case = TRUE)]
      csv_files2_nodaily <- csv_files2[-grep("daily", csv_files2, ignore.case = TRUE)]
    } else {
      csv_files2_daily   <- NULL
      csv_files2_nodaily <- csv_files2
    }

    vars_nodaily <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2_nodaily))
    vars_daily   <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2_daily))
    vars         <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2))

    message("Step 3: Start processing ", length(csv_files), " csv-files\n")

    # Select converter based on format (plyr removed; use lapply + progress bar)
    conv_fn <- if (format == "xts") {
      function(f) converter(f, na_values = na_values)
    } else {
      function(f) converter_tbl(f, na_values = na_values)
    }

    pb     <- utils::txtProgressBar(min = 0, max = length(csv_files), style = 3)
    FFdata <- vector("list", length(csv_files))
    for (i in seq_along(csv_files)) {
      FFdata[[i]] <- conv_fn(csv_files[i])
      utils::setTxtProgressBar(pb, i)
    }
    close(pb)

    names(FFdata) <- vars

    # Recombine daily sub-lists into the corresponding non-daily entries
    if (!exclude_daily) {
      for (i in seq_along(vars_nodaily)) {
        if (any(grepl(vars_nodaily[i], vars_daily))) {
          daily_key <- vars_daily[grep(vars_nodaily[i], vars_daily)]
          FFdata[[vars_nodaily[i]]]$daily <- FFdata[[daily_key]]$daily
          FFdata[[daily_key]] <- NULL
        }
      }
    }

    save(FFdata, file = output_file)
    message("Be aware that as of version 1.0.6 the saved object is named FFdata rather than FFdownload to not be confused with the corresponding command!")

    if (return_data) return(invisible(FFdata))
  }
}
