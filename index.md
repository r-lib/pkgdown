# pkgdown

pkgdown is designed to make it quick and easy to build a website for
your package. You can see pkgdown in action at
<https://pkgdown.r-lib.org>: this is the output of pkgdown applied to
the latest version of pkgdown. Learn more in
[`vignette("pkgdown")`](https://pkgdown.r-lib.org/articles/pkgdown.md)
or [`?build_site`](https://pkgdown.r-lib.org/reference/build_site.md).

## Installation

``` r
# Install released version from CRAN
install.packages("pkgdown")
```

## Usage

Get started with [usethis](https://usethis.r-lib.org/):

``` r
# Run once to configure your package to use and deploy pkgdown
usethis::use_pkgdown_github_pages()
```

``` r
# Preview your site locally before publishing
pkgdown::build_site()
```

This adds the necessary components and sets up GitHub Actions[¹](#fn1)
for automatic site building when deploying. Your `README.md` becomes the
homepage, documentation in `man/` generates a function reference, and
vignettes will be rendered into `articles/`.

### pkgdown 2.0.0 and Bootstrap 5

pkgdown 2.0.0 includes an upgrade from Bootstrap 3 to Bootstrap 5, which
is accompanied by a whole bunch of minor UI improvements. If you’ve
heavily customised your site, there’s a small chance that this will
break your site, so everyone needs to explicitly opt-in to the upgrade
by adding the following to `_pkgdown.yml`:

``` yaml
template:
  bootstrap: 5
```

Then learn about the many new ways to customise your site in
[`vignette("customise")`](https://pkgdown.r-lib.org/articles/customise.md).

## In the wild

At last count, pkgdown is used [by over 12,000
packages](https://github.com/search?q=path%3A_pkgdown.yml+language%3AYAML&type=code&l=YAML).
Here are a few examples:

- [bayesplot](http://mc-stan.org/bayesplot/index.md)
  ([source](https://github.com/stan-dev/bayesplot/tree/gh-pages)):
  plotting functions for posterior analysis, model checking, and MCMC
  diagnostics.

- [valr](https://rnabioco.github.io/valr/)
  ([source](https://github.com/rnabioco/valr)): read and manipulate
  genome intervals and signals.

- [mkin](https://pkgdown.jrwb.de/mkin/)
  ([source](https://github.com/jranke/mkin)): calculation routines based
  on the FOCUS Kinetics Report

- [NMF](http://renozao.github.io/NMF/master/index.md)
  ([source](https://github.com/renozao/NMF)): a framework to perform
  non-negative matrix factorization (NMF).

- [tidyverse and r-lib packages
  source](https://github.com/search?q=path%3A%22_pkgdown.yml%22+AND+%28org%3Atidyverse+OR+org%3Ar-lib%29&type=code)

Comparing the source and output of these sites is a great way to learn
new pkgdown techniques.

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://pkgdown.r-lib.org/CODE_OF_CONDUCT.html). By
participating in this project you agree to abide by its terms.

------------------------------------------------------------------------

1.  If you don’t use GitHub, you can use
    [`usethis::use_pkgdown()`](https://usethis.r-lib.org/reference/use_pkgdown.html) +
    [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.md)
    to create a website.
