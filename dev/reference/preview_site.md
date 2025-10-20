# Open site in browser

`preview_site()` opens your pkgdown site in your browser. pkgdown has
been carefully designed to work even when served from the file system
like this; the only part that doesn't work is search. You can use
`servr::httw("docs/")` to create a server to make search work locally.

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
