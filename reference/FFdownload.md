# Downloads Datasets from Kenneth French's Website

`FFdownload` returns an RData file with all (possibility to exclude the
large daily) datasets from Kenneth French's Website. Should help
researchers to work with the datasets and update the regularly. Allows
for reproducible research. Be aware that processing (especially when
including daily files) takes quite a long time!

## Usage

``` r
FFdownload(
  output_file = "data.Rdata",
  tempd = NULL,
  exclude_daily = FALSE,
  download = TRUE,
  download_only = FALSE,
  listsave = NULL,
  inputlist = NULL,
  format = "xts"
)
```

## Arguments

- output_file:

  name of the .RData file to be saved (include path if necessary)

- tempd:

  specify if you want to keep downloaded files somewhere save. Seems to
  be necessary for reproducible research as the files on the website do
  change from time to time

- exclude_daily:

  excludes the daily datasets (are not downloaded) ==\> speeds the
  process up considerably

- download:

  set to TRUE if you actually want to download again. set to false and
  specify tempd to keep processing the already downloaded files

- download_only:

  set to FALSE if you want to process all your downloaded files at once

- listsave:

  if not NULL, the list of unzipped files is saved here (good for
  processing only a limited number of files through inputlist). Is
  written before inputlist is processed.

- inputlist:

  if not NULL, FFdownload tries to match the names from the list with
  the list of zip-files

- format:

  (set to xts) specify "xts" or "tbl"/"tibble" for the output format of
  the nested lists

## Value

RData file

## Examples

``` r
if (FALSE) { # \dontrun{
tempf <- tempfile(fileext = ".RData"); outd <- paste0(tempdir(),"/",format(Sys.time(), "%F_%H-%M"))
temptxt <- tempfile(fileext = ".txt")

# Example 1: Use FFdownload to get a list of all monthly zip-files. Save that list as temptxt.

FFdownload(exclude_daily=TRUE,download=FALSE,download_only=TRUE,listsave=temptxt)
read.delim(temptxt,sep = ",")
# set vector with only files to download (we try a fuzzyjoin, so "Momentum" should be enough to get
# the Momentum Factor)
inputlist <- c("Research_Data_Factors","Momentum_Factor","ST_Reversal_Factor","LT_Reversal_Factor")
# Now process only these files if they can be matched (download only)
FFdownload(exclude_daily=FALSE,tempd=outd,download=TRUE,download_only=FALSE,
inputlist=inputlist,output_file = tempf)
list.files(outd)
# Then process all the downloaded files
FFdownload(output_file = tempf, exclude_daily=TRUE,tempd=outd,download=FALSE,
download_only=FALSE,inputlist=inputlist)
load(tempf); FFdata$`x_F-F_Momentum_Factor`$monthly$Temp2[1:10]

# Example 2: Download all non-daily files and process them

# Commented out to not being tested
# tempf2 <- tempfile(fileext = ".RData");
# outd2<- paste0(tempdir(),"/",format(Sys.time(), "%F_%H-%M"))
# FFdownload(output_file = tempf2,tempd = outd2, exclude_daily = TRUE, download = TRUE,
# download_only=FALSE, listsave=temptxt)
# load(tempf2)
# FFdownload$x_25_Portfolios_5x5$monthly$average_value_weighted_returns
} # }
```
