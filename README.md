
<!-- README.md is generated from README.Rmd. Please edit that file -->

# FFdownload <a href='https://github.com/sstoeckl/FFdownload'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![Project
Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Travis build
status](https://travis-ci.org/sstoeckl/ffdownload.svg?branch=master)](https://travis-ci.org/sstoeckl/ffdownload)
[![CRAN
status](https://www.r-pkg.org/badges/version/FFdownload)](https://CRAN.R-project.org/package=FFdownload)
<!-- badges: end -->

`R` Code to download Datasets from [Kenneth French’s famous
website](http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html).

## Motivation

One often needs those datasets for further empirical work and it is a
tedious effort to download the (zipped) csv, open and then manually
separate the contained datasets. This package downloads them
automatically, and converts them to a list of xts-objects that contain
all the information from the csv-files.

## Contributors

Original code from MasimovR <https://github.com/MasimovR/>. Was then
heavily redacted by me.

## Installation

You can install FFdownload from CRAN with

``` r
install.packages("FFdownload")
```

or directly from github with:

``` r
# install.packages("devtools")
devtools::install_github("sstoeckl/FFdownload")
```

## Examples

### Example 1: Monthly files

In this example, we use `FFDwonload` to

1.  get a list of all available monthly zip-files and save that files as
    *temp.txt*.

``` r
library(FFdownload)
temptxt <- tempfile(fileext = ".txt")
# Example 1: Use FFdownload to get a list of all monthly zip-files. Save that list as temptxt.
FFdownload(exclude_daily=TRUE,download=FALSE,download_only=TRUE,listsave=temptxt)
```

``` r
FFlist <- readr::read_csv(temptxt) %>% dplyr::select(-X1) %>% dplyr::rename(Files=x)
FFlist %>% dplyr::slice(1:3,(dplyr::n()-2):dplyr::n())
#> # A tibble: 6 x 1
#>   Files                                          
#>   <chr>                                          
#> 1 F-F_Research_Data_Factors_CSV.zip              
#> 2 F-F_Research_Data_Factors_weekly_CSV.zip       
#> 3 F-F_Research_Data_Factors_daily_CSV.zip        
#> 4 Emerging_Markets_4_Portfolios_BE-ME_OP_CSV.zip 
#> 5 Emerging_Markets_4_Portfolios_OP_INV_CSV.zip   
#> 6 Emerging_Markets_4_Portfolios_BE-ME_INV_CSV.zip
```

2.  Next, after inspecting the list we specify a vector `inputlist` to
    only download the datasets we actually need.

``` r
tempd <- tempdir()
inputlist <- c("F-F_Research_Data_Factors","F-F_Momentum_Factor","F-F_ST_Reversal_Factor","F-F_LT_Reversal_Factor")
FFdownload(exclude_daily=TRUE,tempd=tempd,download=TRUE,download_only=TRUE,inputlist=inputlist)
```

3.  In the final step we process the downloaded files.

``` r
tempf <- paste0(tempd,"\\FFdata.RData")
getwd()
#> [1] "D:/University of Liechtenstein/ROOT/Packages/ffdownload"
FFdownload(output_file = tempf, exclude_daily=TRUE,tempd=tempd,download=FALSE,
           download_only=FALSE,inputlist = inputlist)
#>   |                                                                              |                                                                      |   0%  |                                                                              |==================                                                    |  25%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================================| 100%
```

4.  Then we check that everything worked and output a combined file of
    monthly factors (only show first 5 rows).

``` r
library(dplyr)
library(timetk)
load(file = tempf)
FFdata$`x_F-F_Research_Data_Factors`$monthly$Temp2 %>% timetk::tk_tbl(rename_index = "ym") %>%
  left_join(FFdata$`x_F-F_Momentum_Factor`$monthly$Temp2 %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>%
  left_join(FFdata$`x_F-F_LT_Reversal_Factor`$monthly$Temp2 %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>%
  left_join(FFdata$`x_F-F_ST_Reversal_Factor`$monthly$Temp2 %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>% head()
#> # A tibble: 6 x 8
#>   ym        Mkt.RF   SMB   HML    RF   Mom LT_Rev ST_Rev
#>   <yearmon>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
#> 1 Jul 1926    2.96 -2.3  -2.87  0.22    NA     NA  -1.84
#> 2 Aug 1926    2.64 -1.4   4.19  0.25    NA     NA   1.39
#> 3 Sep 1926    0.36 -1.32  0.01  0.23    NA     NA  -0.18
#> 4 Okt 1926   -3.24  0.04  0.51  0.32    NA     NA  -2.03
#> 5 Nov 1926    2.53 -0.2  -0.35  0.31    NA     NA   0.96
#> 6 Dez 1926    2.62 -0.04 -0.02  0.28    NA     NA   1.95
```

5.  No we do the same with annual data:

``` r
FFdata$`x_F-F_Research_Data_Factors`$annual$`annual_factors:_january-december` %>% timetk::tk_tbl(rename_index = "ym") %>%
  left_join(FFdata$`x_F-F_Momentum_Factor`$annual$`january-december` %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>%
  left_join(FFdata$`x_F-F_LT_Reversal_Factor`$annual$`january-december` %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>%
  left_join(FFdata$`x_F-F_ST_Reversal_Factor`$annual$`january-december` %>% timetk::tk_tbl(rename_index = "ym"),by="ym") %>%
  mutate(ym=) %>% head()
#> # A tibble: 6 x 8
#>   ym        Mkt.RF    SMB    HML    RF   Mom LT_Rev ST_Rev
#>   <yearmon>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
#> 1 Dez 1927   29.5   -2.46  -3.75  3.12  23.9  NA    -17.5 
#> 2 Dez 1928   35.4    4.41  -5.83  3.56  28.6  NA    -10.8 
#> 3 Dez 1929  -19.5  -30.8   12.0   4.75  21.4  NA    -15.0 
#> 4 Dez 1930  -31.2   -5.19 -12.3   2.41  25.9  NA     -1.39
#> 5 Dez 1931  -45.1    3.51 -14.3   1.07  24.2  -2.35  23.6 
#> 6 Dez 1932   -9.39   4.91  10.5   0.96 -21.0  11.6   34.4
```

# Acknowledgment

I am grateful to **Kenneth French** for providing all this great
research data on his website! Our lives would be so much harder without
this *boost* for productivity. I am also grateful for the kind
conversation with Kenneth with regard to this package: He appreciates my
work on this package giving others easier access to his data sets!
