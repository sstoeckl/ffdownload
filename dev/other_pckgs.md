# Comparison with Related Packages & Improvement Suggestions

## 1. Related Packages Overview

### `frenchdata` (Nelson Areal, CRAN v0.2.0)

- **API style**: Multiple focused functions — `get_french_data_list()`,
  `download_french_data()`, `browse_details_page()`,
  `browse_french_site()`.
- **Output**: Returns data directly into the R session as a named list
  of tibbles (one per frequency: `monthly`, `annual`, `daily`). No
  intermediate `.RData` file required.
- **Dataset discovery**: `get_french_data_list()` returns a `297 × 3`
  tibble with columns `name`, `file_url`, and `details_url` — fully
  browsable via [`View()`](https://rdrr.io/r/utils/View.html).
- **Tidyverse-native**: All outputs are tibbles, column names preserved
  from French’s headers. Integrates directly into dplyr/ggplot2
  pipelines without any conversion step.
- **One-dataset-at-a-time**: Each call to `download_french_data()`
  downloads and processes a single named dataset, returning it
  immediately.
- **Breadth exposed**: All 297 datasets (including international
  portfolios, industry portfolios, factor variants for emerging markets)
  are listed explicitly with metadata.

### `NMOF::French()` (Enrico Schumann, part of NMOF)

- **API style**: Single function
  `French(dest.dir, dataset, weighting, frequency, price.series, na.rm, adjust.frequency, return.class)`.
- **Output**: Returns a `data.frame` or `zoo` object directly (no file
  save required).
- **Caching**: Automatically caches downloaded zip files using a
  `YYYYMMDD` date prefix in `dest.dir`. Re-uses the cached file if
  today’s file already exists — zero-friction reproducibility.
- **Missing value handling**: Explicitly replaces French’s sentinel
  values (e.g., `-99.99`, `-999`) with `NA`.
- **Frequency selection**: The `frequency` parameter selects
  monthly/daily/annual at call time, returning a single flat data frame
  — no nested list navigation.
- **Price series**: `price.series = TRUE` converts returns to cumulative
  wealth indices in-function.

------------------------------------------------------------------------

## 2. Where FFdownload Stands Out

- **Bulk download**: The only package that downloads and processes an
  arbitrary number of datasets in a single call, with a single `.RData`
  output. Ideal for reproducible research workflows that need a snapshot
  of many datasets at one point in time.
- **Separate download and processing stages**: The
  `download=TRUE/download_only=TRUE` →
  `download=FALSE/download_only=FALSE` workflow allows downloading once
  and re-processing multiple times without network access. Unique among
  the three packages.
- **Multi-table CSV handling**: French’s CSV files embed multiple
  sub-tables (e.g., value-weighted returns, equal-weighted returns,
  number of firms, average market cap all in one file). Both
  [`converter()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/converter.md)
  and
  [`converter_tbl()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/converter_tbl.md)
  correctly split and name all sub-tables. `frenchdata` and
  `NMOF::French()` typically return only one sub-table (the
  first/default one), silently discarding the rest.
- **xts support**: The only package that natively outputs `xts`
  time-series objects, which are essential for time-series operations,
  subsetting by date ranges (`["1963/"]`), and merging with `merge.xts`.
- **Dual output format**: Supports both `xts` and tibble via the
  `format` parameter, covering both legacy and modern workflows.

------------------------------------------------------------------------

## 3. Gaps and Weaknesses vs. Competitors

### 3.1 Dataset breadth communication

FFdownload scrapes the full French data library page and can in
principle access all 297+ datasets — but this is never communicated to
the user. There is no function to return a clean, browsable list of
available datasets with metadata (name, description URL). Users must
download a raw `.txt` file via `listsave=` and then parse it themselves.
`frenchdata` exposes this as a proper tibble with three columns
including a `details_url` per dataset.

### 3.2 Missing value sentinel handling

French’s CSV files encode missing observations as `-99`, `-999`, or
`-99.99` depending on the dataset. `NMOF::French()` explicitly converts
these to `NA`. FFdownload passes them through as numeric values,
silently distorting any downstream calculations (means, cumulative
products, regressions) that include these sentinel rows.

### 3.3 No direct return value

Every invocation that processes data requires writing an `.RData` file
to disk and [`load()`](https://rdrr.io/r/base/load.html)ing it back. For
interactive use and piped workflows this is awkward. `frenchdata`
returns the data directly; `NMOF::French()` returns it directly.
FFdownload forces a round-trip through the filesystem even when the user
only needs one dataset.

### 3.4 Confusing boolean-flag API

The combination of `download` and `download_only` produces four logical
states, two of which are redundant or meaningless
(`download=FALSE, download_only=TRUE` does nothing useful). This is the
single largest usability barrier for new users and generates repeated
confusion in issues/vignettes.

### 3.5 No caching / freshness check

Without `tempd`, files are re-downloaded every call. With `tempd`, files
are never updated unless the user manually deletes them. There is no
built-in mechanism to check whether a cached file is stale (e.g., older
than N days) or to compare it against the current file on French’s
server. `NMOF::French()` handles this with a date-prefix scheme.

### 3.6 Fuzzy matching can silently select the wrong dataset

[`adist()`](https://rdrr.io/r/utils/adist.html) always picks the closest
match with no threshold and no warning. If a user passes `"Momentum"`
and French renames a file, or the closest match is not what the user
intended, the wrong dataset is silently downloaded and processed with no
indication. `frenchdata` requires an exact name match, which is stricter
but safe.

### 3.7 Unnamed sub-tables (`Temp1`, `Temp2`, …)

When a sub-table in a CSV has no header text, it is named `Temp1`,
`Temp2`, etc. in the output. The most important sub-table in factor
files (the one with actual factor returns) is nearly always `Temp2`.
Users must discover this through trial and error. The naming convention
is mentioned nowhere in the documentation except implicitly in examples.

### 3.8 Deep nesting makes interactive use painful

Accessing monthly factor returns requires:
`FFdata[["x_F-F_Research_Data_Factors"]]$monthly$Temp2`. The `x_` prefix
(needed because R list names cannot start with a digit or hyphen) and
the `Temp2` sub-table name are non-obvious. Competitor packages return a
flat or shallowly nested structure.

### 3.9 `plyr` dependency

`plyr` is effectively superseded by `purrr` and base R’s `lapply` family
and is no longer actively developed. Its presence triggers CRAN notes in
some configurations and may cause future compatibility issues. The only
`plyr` usage in the package is
[`plyr::mlply()`](https://rdrr.io/pkg/plyr/man/mlply.html) for iterating
over CSV files.

### 3.10 HTTP (not HTTPS)

The base URL used is `http://mba.tuck.dartmouth.edu/...`. The French
website is available over HTTPS. Using HTTP may trigger
certificate-related warnings on some systems and will fail if the server
enforces HTTPS-only in future.

------------------------------------------------------------------------

## 4. Improvement Suggestions (Backward-Compatible)

All suggestions below are additive. They introduce new functions or new
optional parameters with default values that preserve existing behaviour
exactly.

------------------------------------------------------------------------

### 4.1 Add `FFlist()`: a proper dataset discovery function

**Problem addressed**: §3.1 **Change**: Export a new function that
returns the dataset inventory as a tibble.

``` r
FFlist <- function(exclude_daily = TRUE) {
  # scrapes French's page (same logic as step 1 of FFdownload)
  # returns a tibble with columns: name, file_url, details_url
}
```

This replaces the `listsave` workaround. The result is immediately
usable with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
and [`View()`](https://rdrr.io/r/utils/View.html). No existing code is
affected.

------------------------------------------------------------------------

### 4.2 Add `na_values` parameter to `FFdownload()` for sentinel replacement

**Problem addressed**: §3.2 **Change**: Add an optional `na_values`
parameter defaulting to `NULL` (preserves current behaviour). When set
to a numeric vector (e.g., `c(-99, -999, -99.99)`),
[`converter()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/converter.md)
/
[`converter_tbl()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/converter_tbl.md)
replaces these values with `NA` after parsing each sub-table.

``` r
FFdownload(..., na_values = NULL)
# Suggested safe default for new users:
FFdownload(..., na_values = c(-99, -999, -99.99, -999.0))
```

Because the default is `NULL`, all existing scripts continue to work
unchanged.

------------------------------------------------------------------------

### 4.3 Add `return_data` parameter to return the list directly

**Problem addressed**: §3.3 **Change**: Add `return_data = FALSE`
parameter. When `TRUE`,
[`FFdownload()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFdownload.md)
returns the `FFdata` list invisibly in addition to (or instead of)
saving it.

``` r
FFdownload(..., return_data = FALSE)
# New usage:
FFdata <- FFdownload(inputlist = "F-F_Research_Data_Factors", return_data = TRUE)
```

Default is `FALSE`, so the save-and-load pattern is unchanged. When
`TRUE` and `output_file` is `NULL` or
[`tempfile()`](https://rdrr.io/r/base/tempfile.html), no file needs to
be written.

------------------------------------------------------------------------

### 4.4 Replace `download` + `download_only` flags with a `action` parameter

**Problem addressed**: §3.4 **Change**: Add a new `action` parameter as
a cleaner alternative. Keep `download` and `download_only` fully
functional for backward compatibility.

``` r
# New parameter (if provided, overrides download/download_only):
action = c("all", "list_only", "download_only", "process_only")
```

| `action`          | Equivalent old flags                  |
|-------------------|---------------------------------------|
| `"all"`           | `download=TRUE, download_only=FALSE`  |
| `"list_only"`     | `download=FALSE, download_only=TRUE`  |
| `"download_only"` | `download=TRUE, download_only=TRUE`   |
| `"process_only"`  | `download=FALSE, download_only=FALSE` |

If `action` is missing, the old `download`/`download_only` logic runs as
before.

------------------------------------------------------------------------

### 4.5 Add date-based caching to `tempd`

**Problem addressed**: §3.5 **Change**: Add a `cache_days` parameter
(default `Inf`, meaning never re-download if file exists — current
behaviour). When set to a positive integer, files older than
`cache_days` in `tempd` are re-downloaded.

``` r
FFdownload(..., cache_days = Inf)
# Example: re-download if cached file is older than 7 days
FFdownload(..., tempd = "data/ff", cache_days = 7)
```

This requires only a `file.info()$mtime` check per zip file before
downloading. Default preserves current behaviour.

------------------------------------------------------------------------

### 4.6 Add fuzzy-match warning and a `match_threshold` parameter

**Problem addressed**: §3.6 **Change**: After
[`adist()`](https://rdrr.io/r/utils/adist.html) matching, compute the
relative edit distance. If it exceeds a threshold, emit a
[`warning()`](https://rdrr.io/r/base/warning.html) listing the matched
name alongside the requested name.

``` r
FFdownload(..., match_threshold = 0.3)
# If edit_distance / nchar(matched_name) > match_threshold → warning
```

Additionally, expose a helper:

``` r
FFmatch(inputlist, exclude_daily = TRUE)
# Returns a tibble showing: requested_name → matched_file, edit_distance, similarity
# Lets users verify matches before downloading
```

------------------------------------------------------------------------

### 4.7 Name `Temp` sub-tables more informatively

**Problem addressed**: §3.7 **Change**: When a sub-table section has no
explicit header, inspect the column names of the parsed data and use
them to generate a descriptive fallback name rather than `Temp1`,
`Temp2`, etc. For example, if columns are `Mkt.RF, SMB, HML, RF`, name
the sub-table `"factors"`. If this heuristic is not possible, keep the
`TempN` fallback.

Alternatively (simpler and fully backward-compatible): add a
`verbose_names = FALSE` parameter. When `TRUE`,
[`converter()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/converter.md)
logs a message mapping each `TempN` to the line range and first few
column names, helping users understand the structure without changing
the output names.

------------------------------------------------------------------------

### 4.8 Add `FFget()`: single-dataset convenience wrapper

**Problem addressed**: §3.3, §3.8 **Change**: Export a thin wrapper that
downloads and returns one dataset directly, mimicking
`frenchdata::download_french_data()` in spirit while using FFdownload’s
full parsing engine (including all sub-tables).

``` r
FFget <- function(name, frequency = "monthly", subtable = NULL,
                  exclude_daily = TRUE, na_values = c(-99, -999, -99.99),
                  format = "tbl") {
  # calls FFdownload() internally with return_data = TRUE
  # extracts FFdata[[paste0("x_", name)]][[frequency]]
  # if subtable is NULL, returns all sub-tables as a named list
  # if subtable is a string, returns that one tibble/xts directly
}
```

Example usage:

``` r
factors <- FFget("F-F_Research_Data_Factors", subtable = "Temp2")
```

This is the single biggest usability improvement for new and interactive
users. It does not modify
[`FFdownload()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFdownload.md)
at all.

------------------------------------------------------------------------

### 4.9 Replace `plyr::mlply()` with base `lapply()`

**Problem addressed**: §3.9 **Change**: Replace the one `plyr` call in
`FFdownload.R`:

``` r
# Current:
FFdata <- plyr::mlply(function(y) converter(y), .data = csv_files, .progress = "text")

# Replacement (with optional progress via cli or progressr):
FFdata <- lapply(csv_files, converter)
```

The `plyr` package can then be dropped from `Depends`. If progress
reporting is wanted, use
[`cli::cli_progress_along()`](https://cli.r-lib.org/reference/cli_progress_along.html)
or the `progressr` package (both are lightweight and CRAN-stable). This
reduces the dependency footprint and removes a deprecated package from
the `Depends` field (where it currently sits, meaning it is attached to
the user’s search path).

------------------------------------------------------------------------

### 4.10 Switch to HTTPS

**Problem addressed**: §3.10 **Change**: Replace the hard-coded base
URL:

``` r
# Current:
URL <- "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"

# Fixed:
URL <- "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html"
```

And similarly for download URLs. One-line change, zero API impact.

------------------------------------------------------------------------

### 4.11 Document the sub-table naming convention explicitly

**Problem addressed**: §3.7, §3.8 **Change** (documentation only, no
code): Add a dedicated section to the main
[`FFdownload()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFdownload.md)
man page and the xts vignette explaining: - Why list element names have
an `x_` prefix. - What `Temp1`, `Temp2`, etc. mean and how to discover
which sub-table is which (`names(FFdata[["x_..."]]$monthly)`). - A
reference table showing the most common datasets and their primary
sub-table name (e.g., factor files → `Temp2`, portfolio files →
`average_value_weighted_returns`).

------------------------------------------------------------------------

## 5. Priority Summary

| \#   | Suggestion                                                                                                | Effort  | Impact    | BC risk |
|------|-----------------------------------------------------------------------------------------------------------|---------|-----------|---------|
| 4.10 | HTTPS URLs                                                                                                | Trivial | Medium    | None    |
| 4.9  | Remove `plyr`                                                                                             | Low     | Medium    | None    |
| 4.2  | `na_values` sentinel → NA                                                                                 | Low     | High      | None    |
| 4.3  | `return_data` parameter                                                                                   | Low     | High      | None    |
| 4.1  | [`FFlist()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFlist.md) function                | Low     | High      | None    |
| 4.11 | Document `TempN` naming                                                                                   | Low     | High      | None    |
| 4.8  | [`FFget()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFget.md) convenience wrapper       | Medium  | Very high | None    |
| 4.6  | Fuzzy match warning + [`FFmatch()`](https://www.sebastianstoeckl.com/ffdownload/dev/reference/FFmatch.md) | Medium  | Medium    | None    |
| 4.5  | `cache_days` parameter                                                                                    | Medium  | Medium    | None    |
| 4.4  | `action` parameter                                                                                        | Medium  | Medium    | None    |
| 4.7  | Smarter sub-table naming                                                                                  | Medium  | Medium    | None    |
