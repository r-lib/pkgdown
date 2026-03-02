# Open site in browser

`preview_site()` opens your pkgdown site in your browser, served via a
local HTTP server. This enables dynamic features such as search to work
correctly in preview.

## Usage

``` r
preview_site(pkg = ".", path = ".", preview = TRUE)
```

## Arguments

- pkg:

  Path to package.

- path:

  Path relative to destination

- preview:

  If `TRUE`, or `is.na(preview) && interactive()`, will preview freshly
  generated section in browser.

## See also

[`stop_preview()`](https://pkgdown.r-lib.org/dev/reference/stop_preview.md)
to stop the server.
