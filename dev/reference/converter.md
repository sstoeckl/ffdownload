# Converter to read downloaded datasets and automatically put them into one large dataframe with xts

`converter` read/clean/write

## Usage

``` r
converter(file, na_values = NULL)
```

## Arguments

- file:

  downloaded dataset

- na_values:

  numeric vector of sentinel values to replace with `NA` after parsing.
  Default `NULL` performs no replacement (original behaviour).

## Value

list of annual/monthly/daily files
