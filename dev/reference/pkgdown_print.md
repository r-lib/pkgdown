# Print object in pkgdown output

This lets package authors control how objects are printed just for
pkgdown examples. The default is to call
[`print()`](https://rdrr.io/r/base/print.html) apart from htmlwidgets
where the object is returned as is (with sizes tweaked).

## Usage

``` r
pkgdown_print(x, visible = TRUE)
```

## Arguments

- x:

  Object to display

- visible:

  Whether it is visible or not

## Value

Either a character vector representing printed output (which will be
escaped for HTML as necessary) or literal HTML produced by the htmltools
or htmlwidgets packages.
