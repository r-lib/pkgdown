
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgdown <img src="man/figures/logo.png" align="right" alt="" width="120" />

[![Travis-CI build
status](https://travis-ci.org/r-lib/pkgdown.svg?branch=master)](https://travis-ci.org/r-lib/pkgdown)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/r-lib/pkgdown?branch=master&svg=true)](https://ci.appveyor.com/project/r-lib/pkgdown)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
Status](https://www.r-pkg.org/badges/version/pkgdown)](https://cran.r-project.org/package=pkgdown)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/pkgdown/branch/master/graphs/badge.svg)](https://codecov.io/gh/r-lib/pkgdown?branch=master)

pkgdown is designed to make it quick and easy to build a website for
your package. You can see pkgdown in action at
<https://pkgdown.r-lib.org>: this is the output of pkgdown applied to
the latest version of pkgdown. Learn more in `vignette("pkgdown")` or
`?build_site`.

## Installation

``` r
# Install release version from CRAN
install.packages("pkgdown")

# Install development version from GitHub
devtools::install_github("r-lib/pkgdown")
```

## Usage

Run pkgdown from the package directory each time you release your
package:

``` r
pkgdown::build_site()
```

This will generate a `docs/` directory. The home page will be generated
from your package’s `README.md`, and a function reference will be
generated from the documentation in the `man/` directory. If you are
using GitHub, the easiest way to make this your package website is to
check into git, then go to settings for your repo and make sure that the
**GitHub pages** source is set to “master branch /docs folder”. Be sure
to update the URL on your github repository homepage so others can
easily navigate to your new site.

To customise your site, create `_pkgdown.yml` and modify it [as
described in the
documentation](http://pkgdown.r-lib.org/articles/pkgdown.html). You can
also use `pkgdown/_pkgdown.yml` if you need other files to customise
your site.

The package includes an RStudio add-in that you can bind to a keyboard
shortcut. I recommend `Cmd` + `Shift` + `W`: it uses `Cmd` + `Shift`,
like all other package development shortcuts, it replaces a rarely used
command (close all tabs), and the `W` is a mnemonic for website.

## In the wild

At last count, pkgdown is used [by over 4,500
packages](https://github.com/search?q=pkgdown.css+in%3Apath&type=Code).

Here are a few examples created by contributors to pkgdown:

  - [bayesplot](http://mc-stan.org/bayesplot/index.html)
    \[[source](https://github.com/stan-dev/bayesplot/tree/gh-pages)\]:
    plotting functions for posterior analysis, model checking, and MCMC
    diagnostics.

  - [valr](https://valr.hesselberthlab.org/)
    \[[source](https://github.com/rnabioco/valr)\]: read and manipulate
    genome intervals and signals.

  - [mkin](http://jranke.github.io/mkin/)
    \[[source](https://github.com/jranke/mkin)\]: calculation routines
    based on the FOCUS Kinetics Report

  - [NMF](http://renozao.github.io/NMF/master/index.html)
    \[[source](https://github.com/renozao/NMF)\]: a framework to perform
    non-negative matrix factorization (NMF).

Comparing the source and output of these sites is a great way to learn
new pkgdown techniques.

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://pkgdown.r-lib.org/CODE_OF_CONDUCT.html). By
participating in this project you agree to abide by its terms.
