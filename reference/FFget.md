# Download and return a single French dataset directly

`FFget` is a convenience wrapper around
[`FFdownload`](https://www.sebastianstoeckl.com/ffdownload/reference/FFdownload.md)
that downloads one named dataset and returns it directly into the R
session — no intermediate `.RData` file, no
[`load()`](https://rdrr.io/r/base/load.html) call required.

The function uses all of `FFdownload`'s parsing engine, so every
sub-table present in the original CSV (value-weighted returns,
equal-weighted returns, number of firms, etc.) is available in the
returned list.

## Usage

``` r
FFget(
  name,
  frequency = "monthly",
  subtable = NULL,
  exclude_daily = TRUE,
  na_values = c(-99, -999, -99.99),
  format = "tbl"
)
```

## Arguments

- name:

  character. The dataset name as it appears in `FFlist()$name`, e.g.
  `"F-F_Research_Data_Factors"` or `"F-F_Momentum_Factor"`. Fuzzy
  matching is applied, so partial names work (check with
  [`FFmatch`](https://www.sebastianstoeckl.com/ffdownload/reference/FFmatch.md)
  first).

- frequency:

  character. Which frequency sub-list to extract. One of `"monthly"`
  (default), `"annual"`, or `"daily"`. Set to `NULL` to return all three
  frequencies as a named list.

- subtable:

  character. Name of the sub-table within the chosen frequency, e.g.
  `"Temp2"` or `"annual_factors:_january-december"`. Set to `NULL`
  (default) to return all sub-tables as a named list.

- exclude_daily:

  logical. Passed to
  [`FFdownload`](https://www.sebastianstoeckl.com/ffdownload/reference/FFdownload.md).
  Default `TRUE`.

- na_values:

  numeric vector of sentinel values to replace with `NA`. Defaults to
  `c(-99, -999, -99.99)` — the values French uses for missing
  observations. Set to `NULL` to disable replacement.

- format:

  character. `"tbl"` (default) or `"xts"`.

## Value

A tibble, `xts` object, or named list, depending on `frequency`,
`subtable`, and `format`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get the main monthly Fama-French 3-factor table directly as a tibble
ff3 <- FFget("F-F_Research_Data_Factors", subtable = "Temp2")
head(ff3)

# Get all sub-tables for the 5-factor model
ff5_all <- FFget("F-F_Research_Data_5_Factors_2x3", subtable = NULL)
names(ff5_all)

# Get annual data as xts
ff3_ann <- FFget("F-F_Research_Data_Factors", frequency = "annual", format = "xts")
} # }
```
