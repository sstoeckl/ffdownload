# List available datasets on Kenneth French's website

`FFlist` scrapes Kenneth French's data library and returns a data frame
(or tibble) of available datasets with their names and download URLs.
This replaces the `listsave` workaround in
[`FFdownload`](https://sstoeckl.github.io/ffdownload/dev/reference/FFdownload.md)
and makes the dataset inventory directly usable with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
or [`View()`](https://rdrr.io/r/utils/View.html).

## Usage

``` r
FFlist(exclude_daily = TRUE)
```

## Arguments

- exclude_daily:

  logical. If `TRUE` (default), daily datasets are excluded from the
  returned list.

## Value

A data frame (or tibble if the tibble package is available) with
columns:

- name:

  Dataset name, as used in `inputlist` and as key in the `FFdata` list
  (without the leading `x_` prefix and without the `_CSV.zip` suffix).

- file_url:

  Full HTTPS URL of the zip file.

- is_daily:

  Logical flag indicating whether the dataset contains daily data. Only
  present when `exclude_daily = FALSE`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Browse all available monthly/annual datasets
fl <- FFlist()
head(fl, 10)

# Include daily datasets
FFlist(exclude_daily = FALSE)

# Filter with dplyr
library(dplyr)
FFlist() |> filter(grepl("Momentum", name))
} # }
```
