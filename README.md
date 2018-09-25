
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
devtools::install_github("diffform/FFdownload")
```

Example
-------

``` r
# FFdownload(output_file = "FF20180909.RData",tempdir = "C:/temp",exclude_daily = TRUE)
# load("FF20180909.RData")
# FFdownload$x_25_Portfolios_5x5$monthly$average_value_weighted_returns
```
