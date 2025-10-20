# Get current settings for figures

You will generally not need to use this function unless you are handling
custom plot output.

Packages needing custom parameters should ask users to place them within
the `other.parameters` entry under the package name, e.g.

    figures:
      other.parameters:
        rgl:
          fig.asp: 1

## Usage

``` r
fig_settings()
```

## Value

A list containing the entries from the `figures` field in `_pkgdown.yml`
(see
[`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md)),
with default values added. Computed `width` and `height` values (in
pixels) are also included.
