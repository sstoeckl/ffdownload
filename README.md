
<!-- README.md is generated from README.Rmd. Please edit that file -->
FFdownload
==========

`R` Code to download Datasets from Kenneth French's Website.

Motivation
----------

Well, one often needs those datasets for further empirical work and it is a huge PITA to download the (zipped) csv open and then manually seperate them

Contributors
------------

Original code from MasimovR <https://github.com/MasimovR/>

Installation
------------

You can install FFdownload from github with:

``` r
# install.packages("devtools")
devtools::install_github("sstoeckl/ffdownload")
```

Example
-------

``` r
tempf <- tempfile(fileext = ".RData"); tempd <- tempdir(); temptxt <- tempfile(fileext = ".txt")
# Example 1: Use FFdownload to get a list of all monthly zip-files. Save that list as temptxt.
FFdownload(exclude_daily=TRUE,download=FALSE,download_only=TRUE,listsave=temptxt)
# set vector with only files to download (we tray a fuzzyjoin, so "Momentum" should be enough to get the Momentum Factor)
inputlist <- c("F-F_Research_Data_Factors","F-F_Momentum_Factor","F-F_ST_Reversal_Factor","F-F_LT_Reversal_Factor")
# Now process only these files if they can be matched (download only)
FFdownload(exclude_daily=TRUE,tempdir=tempd,download=TRUE,download_only=TRUE,inputlist=inputlist)
# Then process all the downloaded files
FFdownload(output_file = tempf, exclude_daily=TRUE,tempdir=tempd,download=FALSE,download_only=FALSE,inputlist=inputlist)
load(tempf); FFdownload$`x_F-F_Momentum_Factor`$monthly$Temp2[1:10]
# Example 2: Download all non-daily files and process them
tempf2 <- tempfile(fileext = ".RData"); tempd2 <- tempdir()
FFdownload(output_file = tempf2,tempdir = tempd2,exclude_daily = TRUE, download = TRUE, download_only=FALSE, listsave=temptxt)
load(tempf2)
FFdownload$x_25_Portfolios_5x5$monthly$average_value_weighted_returns
```
