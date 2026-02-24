# Converter to read downloaded datasets and automatically put them into one large dataframe as tibbles

`converter_tbl` read/clean/write

## Usage

``` r
converter_tbl(file, na_values = NULL)
```

## Arguments

- file:

  downloaded dataset

- na_values:

  numeric vector of sentinel values to replace with `NA` after parsing.
  Default `NULL` performs no replacement (original behaviour).

## Value

list of annual/monthly/daily files
