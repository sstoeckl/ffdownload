#' @title Downloads Datasets from Kenneth French's Website
#'
#' @description \code{FFdownload} returns an RData file with all (possibility to exclude the large daily) datasets from Kenneth French's Website.
#' Should help researchers to work with the datasets and update the regularly. Allows for reprducible research. Be aware that processing
#' (especially when including daily files) takes quite a long time!
#'
#' @param output_file name of the .RData file to be saved (include path if necessary)
#' @param tempdir specify if you want to keep downloaded files somewhere save. Seems to be necessary for
#' reproducible research as the files on the website do change from time to time
#' @param exclude_daily excludes the daily datasets (are not downloaded) ==> speeds the pocess up considerably
#' @param download set to TRUE if you actually want to download again. set to false and specify tempdir to keep processing the already downloaded files
#' @param download_only set to FALSE if you want to process all your downloaded files at once
#' @param listsave if not NULL, the list of unzipped files is saved here (good for processing only a limited number of files through inputlist).
#' Is written before inputlist is processed.
#' @param inputlist if not NULL, FFdownload tries to match the names from the list with the list of zip-files
#'
#' @return RData file
#'
#' @examples
#' tempf <- tempfile(fileext = ".RData"); outd <- paste0(tempdir(),"/",format(Sys.time(), "%F_%H-%M")); temptxt <- tempfile(fileext = ".txt")
#' # Example 1: Use FFdownload to get a list of all monthly zip-files. Save that list as temptxt.
#' FFdownload(exclude_daily=TRUE,download=FALSE,download_only=TRUE,listsave=temptxt)
#' read.delim(temptxt,sep = ",")
#' # set vector with only files to download (we try a fuzzyjoin, so "Momentum" should be enough to get the Momentum Factor)
#' inputlist <- c("Research_Data_Factors","Momentum_Factor","ST_Reversal_Factor","LT_Reversal_Factor")
#' # Now process only these files if they can be matched (download only)
#' FFdownload(exclude_daily=FALSE,tempdir=outd,download=TRUE,download_only=FALSE,inputlist=inputlist,output_file = tempf)
#' list.files(outd)
#' # Then process all the downloaded files
#' FFdownload(output_file = tempf, exclude_daily=TRUE,tempdir=outd,download=FALSE,download_only=FALSE,inputlist=inputlist)
#' load(tempf); FFdownload$`x_F-F_Momentum_Factor`$monthly$Temp2[1:10]
#' # Example 2: Download all non-daily files and process them
#' tempf2 <- tempfile(fileext = ".RData"); outd2<- paste0(tempdir(),"/",format(Sys.time(), "%F_%H-%M"))
#' FFdownload(output_file = tempf2,tempdir = tempd2,exclude_daily = TRUE, download = TRUE, download_only=FALSE, listsave=temptxt)
#' load(tempf2)
#' FFdownload$x_25_Portfolios_5x5$monthly$average_value_weighted_returns
#'
#' @importFrom utils download.file unzip
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes
#' @importFrom utils adist write.csv
#' @importFrom plyr mlply
#'
#' @export
FFdownload <- function(output_file = "data.Rdata", tempdir=NULL, exclude_daily=FALSE, download=TRUE, download_only=FALSE, listsave=NULL, inputlist=NULL) {
  message("Step 1: getting list of all the csv-zip-files!\n")
  URL <- "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"
  pg <- xml2::read_html(URL)
  Flinks <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
  Findex <- grep("CSV.zip",Flinks)
  Fdaily <- grep("daily",Flinks[Findex],ignore.case = TRUE)

  Flinks_csv <- Flinks[Findex]
  Flinks_csv_daily <- Flinks[Findex][Fdaily]
  Flinks_csv_nodaily <- Flinks[Findex][-Fdaily]

  # save list of links if listsave!=NULL
  if(!is.null(listsave)){write.csv(gsub("ftp/","",Flinks_csv),file=listsave)}

  # if there is an input-list
  if(!is.null(inputlist)){
    if(exclude_daily){
      Flinks_final <- Flinks_csv_nodaily[apply(adist(x=inputlist,y=Flinks_csv_nodaily,ignore.case = TRUE), 1, which.min)]
      } else {
      Flinks_final <- Flinks_csv_nodaily[apply(adist(x=inputlist,y=Flinks_csv_nodaily,ignore.case = TRUE), 1, which.min)]
      Flinks_final <- c(Flinks_final,
                        Flinks_csv_daily[apply(adist(x=inputlist,y=Flinks_csv_daily,ignore.case = TRUE), 1, which.min)])
    }
  } else {
    if (exclude_daily){Flinks_final <- Flinks_csv_nodaily} else {Flinks_final <- Flinks_csv}
  }

  if (download){
    message("Step 2: Downloading ",length(Flinks_final)," zip-files\n")
    temp_download <- tempfile(pattern=""); dir.create(temp_download,showWarnings = FALSE)
    if(capabilities("libcurl")){
      utils::download.file(url = paste0("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/",Flinks_final),
                    destfile = paste0(temp_download,"/",gsub(pattern = "ftp/","",Flinks_final)), method="libcurl",quite=TRUE)
    } else {
      for (i in 1:length(Flinks_final)){
        Fdest <- gsub("ftp/","",Flinks_final[i])
        utils::download.file(paste0("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/",Flinks_final[i]), paste0(temp_download,"/", Fdest),quite=TRUE)
      }
    }
    # copy to final tempdir if wished
    if (!is.null(tempdir)) {dir.create(tempdir,showWarnings = FALSE); file.copy(from = paste0(temp_download,"/",gsub(pattern = "ftp/","",Flinks_final)),
                                                                                to = tempdir, recursive=TRUE)}
  }
  zip_files <- list.files(temp_download, full.names = TRUE, pattern = "\\.zip$", ignore.case = TRUE) # full path

  lapply(zip_files, function (x) unzip(zipfile = x, exdir = temp_download))

  csv_files <- list.files(temp_download, full.names = TRUE, pattern = "\\.csv$", ignore.case = TRUE) # full path
  csv_files2 <- list.files(temp_download, full.names = FALSE, pattern = "\\.csv$", ignore.case = TRUE) # only filenames
  if (length(grep("daily",csv_files2,ignore.case = TRUE))){
    csv_files2_daily <- csv_files2[grep("daily",csv_files2,ignore.case = TRUE)]
    csv_files2_nodaily <- csv_files2[-grep("daily",csv_files2,ignore.case = TRUE)]
  } else {csv_files2_daily <- NULL; csv_files2_nodaily <- csv_files2}

  vars_nodaily <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2_nodaily)  )
  vars_daily <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2_daily)  )
  vars <- paste0("x_", gsub("(.*)\\..*", "\\1", csv_files2)  )

  # if download_only==TRUE exit
  if(!download_only){
    message("Step 3: Start processing ",length(Flinks_final)," csv-files\n")
    FFdownload <- plyr::mlply(function(y) converter(y), .data=csv_files, .progress = "text")
    names(FFdownload) <- vars


    # recombine lists
    if(!exclude_daily){
      for (i in 1:length(vars_nodaily)){
        FFdownload[[eval(vars_nodaily[i])]]$daily <- FFdownload[[eval(vars_daily[grep(vars_nodaily[i],vars_daily)])]]$daily
        FFdownload[[eval(vars_daily[grep(vars_nodaily[i],vars_daily)])]] <- NULL
      }
    }
    save(FFdownload, file = output_file)
  }
}
