# Preview fuzzy-matching results before downloading

`FFmatch` shows how each entry in `inputlist` would be matched to an
available dataset by the fuzzy-matching logic inside
[`FFdownload`](https://www.sebastianstoeckl.com/ffdownload/reference/FFdownload.md).
Use this to verify matches before triggering a download, especially when
dataset names are abbreviated or partially specified.

## Usage

``` r
FFmatch(inputlist, exclude_daily = TRUE)
```

## Arguments

- inputlist:

  character vector of (partial) dataset names to match, as you would
  pass to the `inputlist` argument of
  [`FFdownload`](https://www.sebastianstoeckl.com/ffdownload/reference/FFdownload.md).

- exclude_daily:

  logical. If `TRUE` (default), daily datasets are excluded from the
  candidate pool.

## Value

A data frame (or tibble) with one row per entry in `inputlist` and
columns:

- requested:

  The input string as supplied.

- matched:

  The dataset name that would be selected by `FFdownload`.

- edit_distance:

  Raw Levenshtein edit distance between `requested` and `matched`.

- similarity:

  1 - edit_distance / nchar(matched), clamped to \[0, 1\]. Values below
  0.3 suggest a potentially wrong match.

## Examples

``` r
if (FALSE) { # \dontrun{
FFmatch(c("Research_Data_Factors", "Momentum", "ST_Reversal"))
} # }
```
