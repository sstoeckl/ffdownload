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
  format = "xts",
  na_values = NULL,
  return_data = FALSE,
  action = NULL,
  cache_days = Inf,
  match_threshold = 0.3
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

- na_values:

  numeric vector of sentinel values to replace with `NA` (e.g.
  `c(-99, -999, -99.99)`). French's files use -99.99 or -999 to denote
  missing observations. Default `NULL` preserves the original behaviour
  (no replacement).

- return_data:

  logical. If `TRUE`, the `FFdata` list is returned invisibly in
  addition to being saved to `output_file`. Default `FALSE` preserves
  the original behaviour.

- action:

  convenience alternative to the `download`/`download_only` flag pair.
  One of `"all"` (download + process), `"list_only"` (save file list
  only), `"download_only"` (download but do not process), or
  `"process_only"` (process already-downloaded files from `tempd`). When
  `action` is provided it overrides `download` and `download_only`.
  Default `NULL` retains the original flag-based behaviour.

- cache_days:

  numeric. When greater than 0 and less than `Inf`, zip files already
  present in `tempd` that are younger than `cache_days` days are reused
  instead of being re-downloaded. Default `Inf` preserves the original
  behaviour (never re-download an existing file).

- match_threshold:

  numeric in \[0,1\]. If the similarity between a requested `inputlist`
  entry and its fuzzy-matched filename is below this threshold a warning
  is emitted. Use
  [`FFmatch()`](https://sstoeckl.github.io/ffdownload/dev/reference/FFmatch.md)
  to inspect matches before downloading. Default `0.3`.

## Value

Invisibly returns the `FFdata` list when `return_data = TRUE`; otherwise
called for its side-effect of writing an RData file.

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

# Example 2: Use action parameter and return data directly

FFdata <- FFdownload(
  inputlist = c("F-F_Research_Data_5_Factors_2x3"),
  output_file = tempf,
  action = "all",
  na_values = c(-99, -999, -99.99),
  return_data = TRUE
)
FFdata$`x_F-F_Research_Data_5_Factors_2x3`$monthly$Temp2
} # }
```
