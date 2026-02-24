# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

**FFdownload** is an R package that downloads datasets from [Kenneth French's data library](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html), processes the zipped CSV files, and returns them as nested lists of `xts` time-series objects (or tibbles). Published on CRAN. Current dev version: **1.2.0.9000** on branch `dev`; stable CRAN release: **1.1.1** on `master`.

## Common Commands

All development commands are run in R or via the terminal from the package root.

**Check the package (R CMD CHECK equivalent):**
```r
devtools::check()
```

**Build and install locally:**
```r
devtools::install()
```

**Regenerate documentation from roxygen2 comments** (required after editing `@` tags or adding new exported functions):
```r
devtools::document()
```

**Build the pkgdown website:**
```r
pkgdown::build_site()
```

**Rebuild README.md from README.Rmd:**
```r
devtools::build_readme()
```

**Run the test suite:**
```r
devtools::test()
# or a single file:
testthat::test_file("tests/testthat/test-backward-compat.R")
```

**Load package for interactive development:**
```r
devtools::load_all()
```

## Architecture

### Exported functions

| Function | File | Purpose |
|---|---|---|
| `FFdownload()` | `R/FFdownload.R` | Main workhorse: scrape → download → process → save `.RData` |
| `FFlist()` | `R/FFlist.R` | Returns dataset inventory as a data frame/tibble |
| `FFmatch()` | `R/FFmatch.R` | Previews fuzzy-match results before downloading |
| `FFget()` | `R/FFget.R` | Downloads one dataset and returns it directly (no file I/O) |

### `FFdownload()` (`R/FFdownload.R`)
The main user-facing function. Three-step pipeline:
1. **Scrape** Kenneth French's website HTML for all CSV zip-file links.
2. **Download** selected zip files (filtered via `inputlist` using fuzzy string matching with `adist()`).
3. **Process** each CSV via `converter()` or `converter_tbl()`, merge daily/non-daily variants, save as `.RData` containing `FFdata`.

**Parameters added in v1.2.0** (all default to original behaviour):
- `na_values`: replace French's sentinel values (`-99`, `-999`, `-99.99`) with `NA`
- `return_data`: return `FFdata` invisibly in addition to saving
- `action`: cleaner alternative to `download`/`download_only` flag pair (`"all"`, `"list_only"`, `"download_only"`, `"process_only"`)
- `cache_days`: reuse zip files in `tempd` younger than N days
- `match_threshold`: warn when fuzzy-match similarity is below threshold

### `converter()` / `converter_tbl()` (`R/converter.R`)
Internal (not exported). Parse a single French CSV file. French's CSVs embed multiple sub-tables in one file separated by header lines. The converter:
- Detects section boundaries by lines with/without commas.
- Names sections from header text (lowercased, spaces → `_`); unnamed sections become `Temp1`, `Temp2`, etc.
- Distinguishes annual (4-digit), monthly (6-digit `YYYYMM`), and daily (8-digit `YYYYMMDD`) sub-tables by first-column length.
- Returns `list(annual=..., monthly=..., daily=...)` of named `xts` objects (or tibbles in `converter_tbl`).
- **v1.2.0**: accepts `na_values` parameter; applies sentinel replacement after numeric conversion.

### `FFlist()` (`R/FFlist.R`)
Scrapes the French website and returns a data frame with columns `name` (dataset name without `_CSV.zip` suffix, usable directly in `inputlist`) and `file_url`. Uses `requireNamespace("tibble")` to upgrade to tibble if available.

### `FFmatch()` (`R/FFmatch.R`)
Calls `FFlist()` internally, then runs `adist()` to find the closest match for each entry in `inputlist`. Returns a data frame with `requested`, `matched`, `edit_distance`, `similarity` columns. Use before `FFdownload()` to verify fuzzy matches.

### `FFget()` (`R/FFget.R`)
Thin wrapper: calls `FFdownload()` with `return_data=TRUE` to a `tempfile()`, then extracts the requested `frequency` and `subtable` slice. Applies `na_values=c(-99, -999, -99.99)` by default (unlike `FFdownload()` which defaults to `NULL`).

### Output data structure
```
FFdata
└── x_F-F_Research_Data_Factors          # "x_" prefix avoids R name issues with hyphens/digits
    ├── monthly
    │   ├── Temp2                         # main factor returns (unnamed sections → TempN)
    │   └── ...
    ├── annual
    │   └── annual_factors:_january-december
    └── daily                             # empty unless exclude_daily=FALSE
```

## Tests

Tests live in `tests/testthat/test-backward-compat.R`. All tests use `skip_on_cran()` and `skip_if_offline()` because they require network access. The test suite covers:
- Structural equivalence: `FFdownload()` with old API parameters produces the same list structure as documented in v1.1.x vignettes.
- `return_data=TRUE` gives the same object as `load(output_file)`.
- `action` parameter equivalences with `download`/`download_only` flags.
- `na_values` sentinel replacement.
- `FFlist()`, `FFmatch()`, `FFget()` return correct structures and values.
- `cache_days` prevents re-downloading fresh files.
- `match_threshold` warning behaviour.

## Documentation & CI

- Roxygen2 (`RoxygenNote: 7.3.1`) generates all `man/` files and `NAMESPACE` — do not edit these directly; run `devtools::document()` instead.
- `README.md` is generated from `README.Rmd` — edit the `.Rmd` file, then run `devtools::build_readme()`.
- Vignettes in `vignettes/` are built with knitr: `FFD-xts-how-to.Rmd` (xts workflow), `FFD-tibble-how-to.Rmd` (tidyverse workflow), `assetpricing.Rmd` (cross-sectional pricing example).
- GitHub Actions runs `R-CMD-check` across macOS, Windows, and Ubuntu (R devel, release, oldrel-1) on push/PR to master. `pkgdown` site is auto-deployed via `.github/workflows/pkgdown.yaml`.
