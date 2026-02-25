# FFdownload 1.2.0

## New functions

* `FFlist()`: scrapes Kenneth French's data library and returns a tidy data
  frame (or tibble) of all available datasets, with columns `name` and
  `file_url`. The `name` column can be passed directly to `inputlist`.

* `FFmatch()`: previews fuzzy-match results for a given `inputlist` before
  downloading. Returns `requested`, `matched`, `edit_distance`, and
  `similarity` columns so users can verify matches without committing to a
  download.

* `FFget()`: downloads a single dataset directly into the R session (no file
  I/O). Accepts `frequency` and `subtable` arguments to slice the desired
  sub-table. Applies `na_values = c(-99, -999, -99.99)` by default.

## Enhancements to `FFdownload()`

* New `na_values` parameter: replace French's sentinel missing-value codes
  (e.g. −99, −999, −99.99) with `NA` after numeric conversion.

* New `return_data` parameter: when `TRUE`, returns the `FFdata` list
  invisibly in addition to saving the `.RData` file.

* New `action` parameter: cleaner alternative to the `download` /
  `download_only` flag pair. Accepts `"all"`, `"list_only"`,
  `"download_only"`, or `"process_only"`.

* New `cache_days` parameter: skips re-downloading zip files in `tempd` that
  are younger than the specified number of days.

* New `match_threshold` parameter: emits a warning when the fuzzy-match
  similarity for any requested dataset falls below the threshold.

## Enhancements to internal converters

* `converter()` and `converter_tbl()` now accept a `na_values` argument and
  apply sentinel replacement after numeric conversion.

## New vignette

* Added `assetpricing.Rmd`: a complete empirical asset pricing workflow
  covering time-series tests (CAPM, FF3) on 25 Size×BM portfolios, the GRS
  joint test, the momentum anomaly, and Fama-MacBeth cross-sectional
  regressions under CAPM, FF3, FF4 (Carhart), and FF5 across 100 Size×BM
  portfolios.

# FFdownload 1.1.1

* Release to CRAN after previous package version has been archived due to a broken travis link.

# FFdownload 1.1

* Resubmit to CRAN
* Added possibility to create list of tibbles rather than list of xts. Also added appropriate vignettes.

# FFdownload 1.0.6

* Resubmit to CRAN
* Corrected variable names to not be similar to a corresponding command (FFdownload -> FFdata, tempdir -> tempd). This is potentially a breaking change, so I additionally included a warning message when the package is loaded.
* Also corrected date in converter for annual data to Dec of each year.
* Additionally fixed the download/download_only problem which now should be working

# FFdownload 1.0.5

* Resubmit to CRAN
* Fixed too long line in commented example

# FFdownload 1.0.4

* Resubmit to CRAN
* wraped examples that download in `donttest{}` but because cran tests this anyway (see https://stackoverflow.com/questions/63693563/issues-in-r-package-after-cran-asked-to-replace-dontrun-by-donttest) I also commented the second example which takes some time out (as `dontrun()` seems to also not being liked on cran)

# FFdownload 1.0.3

* Resubmit to CRAN

# FFdownload 1.0.2

* Added a `NEWS.md` file to track changes to the package.
* Added slight changes suggested by CRAN
