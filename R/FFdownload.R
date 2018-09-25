#' @title Downloads Datasets from kenneth french's Website
#'
#' @description \code{FFdownload} returns an RData file with all datasets from Kenneth French's Website. Should help researchers
#' to work with the datasets and update the regularly. Allows for reprducible research.
#'
#' @param output_file name of the .RData file to be saved (include path if necessary)
#' @param tempdir specify if you want to keep downloaded files somewhere save. Seems to be necessary for
#' reproducible research as the files on the website seems to change from time to time
#' @param exclude_daily excludes the daily datasets (are not downloaded) ==> speeds the rpocess up considerably
#' @param download set to TRUE if you actually want to download again. set to false and specify tempdir to keep processing the already downloaded files
#'
#' @return RData file
#'
#' @examples
#' # FFdownload(output_file = "FF20180909.RData",tempdir = "C:/temp",exclude_daily = TRUE)
#' # load("FF20180909.RData")
#' # FFdownload$x_25_Portfolios_5x5$monthly$average_value_weighted_returns
#'
#' @importFrom utils download.file unzip
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes
#'
#'@export
FFdownload <- function(output_file = "data.Rdata", tempdir=NULL, exclude_daily=FALSE, download=TRUE) {

  URL <- "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"
  pg <- read_html(URL)
  Flinks <- html_attr(html_nodes(pg, "a"), "href")
  Findex <- grep("CSV.zip",Flinks)
  Fdaily <- grep("daily",Flinks,ignore.case = TRUE)
  if (exclude_daily){Findex <- setdiff(Findex,Fdaily)}

  if (is.null(tempdir)) {temp <- tempdir()} else {temp <- tempdir}
  if (download){
    for (i in 1:length(Findex)){
      Fdest <- gsub("ftp/","",Flinks[Findex[i]])
      download.file(paste0("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/",Flinks[Findex[i]]), paste0(temp,"/", Fdest))
    }
  }

  zip_files <- list.files(temp, full.names = TRUE, pattern = "\\.zip$", ignore.case = TRUE)

  lapply(zip_files, function (x) unzip(zipfile = x, exdir = temp))

  csv_files <- list.files(temp, full.names = TRUE, pattern = "\\.csv$", ignore.case = TRUE)
  csv_files2 <- list.files(temp, full.names = FALSE, pattern = "\\.csv$", ignore.case = TRUE)

  vars <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2)  )

  returns <- new.env()

  mapply(function(x, y) assign(x, converter(y), envir = returns), vars,  csv_files)

  FFdownload <- as.list(returns)
  save(FFdownload, file = output_file)
}
