# Build site for GitHub pages

Designed to be run as part of automated workflows for deploying to
GitHub pages. It cleans out the old site, builds the site into
`dest_dir` adds a `.nojekyll` file to suppress rendering by Jekyll, and
adds a `CNAME` file if needed.

It is designed to be run in CI, so by default it:

- Cleans out the old site.

- Does not install the package.

- Runs
  [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md)
  in process.

## Usage

``` r
build_site_github_pages(
  pkg = ".",
  ...,
  dest_dir = "docs",
  clean = TRUE,
  install = FALSE,
  new_process = FALSE
)
```

## Arguments

- pkg:

  Path to package.

- ...:

  Additional arguments passed to
  [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md).

- dest_dir:

  Directory to build site in.

- clean:

  Clean all files from old site.

- install:

  If `TRUE`, will install the package in a temporary library so it is
  available for vignettes.

- new_process:

  If `TRUE`, will run
  [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md)
  in a separate process. This enhances reproducibility by ensuring
  nothing that you have loaded in the current process affects the build
  process.
