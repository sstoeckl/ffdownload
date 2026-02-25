## New minor version (1.1.1 → 1.2.0)

This is a new minor release of an existing CRAN package. Changes since 1.1.1:

* Three new exported functions: `FFlist()` (dataset inventory), `FFmatch()`
  (preview fuzzy matches before downloading), and `FFget()` (retrieve a single
  dataset directly into the R session without file I/O).
* New `FFdownload()` parameters: `na_values` (replace French's sentinel codes
  −99/−999/−99.99 with `NA`), `return_data`, `action`, `cache_days`, and
  `match_threshold`. All new parameters default to the previous behaviour,
  so the update is fully backwards-compatible.
* New vignette `assetpricing.Rmd`: a complete empirical asset pricing workflow
  (time-series tests, GRS test, momentum anomaly, Fama-MacBeth regressions).

## Test environments

* Local Windows 11 installation, R 4.5.x
* GitHub Actions (`.github/workflows/R-CMD-check.yaml`):
  - ubuntu-latest, R release
  - ubuntu-latest, R devel
  - ubuntu-latest, R oldrel-1
  - windows-latest, R release
  - macOS-latest, R release
* win-builder (devel and release): https://win-builder.r-project.org/

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes on tests

All tests in `tests/testthat/` use `skip_on_cran()` and `skip_if_offline()`
because they require a live network connection to Kenneth French's website.
CRAN machines will therefore skip the entire test suite, which is intentional.
The tests run fully in the GitHub Actions CI on every push.
