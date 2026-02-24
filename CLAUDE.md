# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

**FFdownload** is an R package that downloads datasets from [Kenneth
French’s data
library](http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.md),
processes the zipped CSV files, and returns them as nested lists of
`xts` time-series objects (or tibbles). It is published on CRAN.

## Common Commands

All development commands are run in R or via the terminal from the
package root.

**Check the package (R CMD CHECK equivalent):**

``` r
devtools::check()
```

**Build and install locally:**

``` r
devtools::install()
```

**Regenerate documentation from roxygen2 comments:**

``` r
devtools::document()
```

**Build the pkgdown website:**

``` r
pkgdown::build_site()
```

**Rebuild README.md from README.Rmd:**

``` r
devtools::build_readme()
```

**Run package tests:**

``` r
devtools::test()
```

**Load package for interactive development:**

``` r
devtools::load_all()
```

## Architecture

The package has two exported/internal functions:

### `FFdownload()` (`R/FFdownload.R`)

The single exported user-facing function. It orchestrates a three-step
pipeline: 1. **Scrapes** Kenneth French’s website HTML to collect all
CSV zip-file links. 2. **Downloads** selected zip files (optionally
filtered via `inputlist` using fuzzy string matching with
[`adist()`](https://rdrr.io/r/utils/adist.html)). 3. **Processes**
downloaded CSVs by calling
[`converter()`](https://www.sebastianstoeckl.com/ffdownload/reference/converter.md)
or
[`converter_tbl()`](https://www.sebastianstoeckl.com/ffdownload/reference/converter_tbl.md)
for each file, then merges daily/non-daily variants and saves the result
as an `.RData` file containing an object named `FFdata`.

Key parameters: `output_file`, `tempd` (persistent download directory),
`exclude_daily`, `download`, `download_only`, `listsave`, `inputlist`,
`format` (`"xts"` or `"tbl"`/`"tibble"`).

### `converter()` / `converter_tbl()` (`R/converter.R`)

Internal functions (not exported) that parse a single raw CSV file from
French’s website. The CSV format is unusual—multiple sub-tables are
stacked in one file separated by header lines. The converter: - Detects
section boundaries by finding lines with/without commas. - Assigns
section names from header text (lowercased, spaces replaced with `_`;
unnamed sections become `Temp1`, `Temp2`, etc.). - Distinguishes annual
(4-digit date), monthly (6-digit `YYYYMM`), and daily (8-digit
`YYYYMMDD`) sub-tables by the length and numeric content of the first
column. - Returns a list with `$annual`, `$monthly`, and `$daily`
sub-lists, each containing named `xts` objects (or tibbles in
`converter_tbl`).

### Output data structure

`FFdata` is a named list where each element corresponds to one dataset
(e.g., `FFdata$"x_F-F_Research_Data_Factors"`), which itself is a list
with `$annual`, `$monthly`, and `$daily` slots, each holding named `xts`
(or tibble) objects keyed by sub-table name.

## Documentation & CI

- Roxygen2 is used for all documentation (`RoxygenNote: 7.3.1`). Edit
  docs in source files, then run `devtools::document()`.
- `man/` files are auto-generated — do not edit them directly.
- GitHub Actions runs `R-CMD-check` across macOS, Windows, and Ubuntu (R
  devel, release, oldrel-1) on push/PR to master.
- `pkgdown` site is auto-deployed via `.github/workflows/pkgdown.yaml`.
- Vignettes live in `vignettes/` and are built with `knitr`.
