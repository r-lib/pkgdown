
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgdown

[![Travis-CI Build
Status](https://travis-ci.org/r-lib/pkgdown.svg?branch=master)](https://travis-ci.org/r-lib/pkgdown)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/pkgdown)](https://cran.r-project.org/package=pkgdown)
[![Coverage
Status](https://img.shields.io/codecov/c/github/r-lib/pkgdown/master.svg)](https://codecov.io/github/r-lib/pkgdown?branch=master)

pkgdown is designed to make it quick and easy to build a website for
your package. You can see pkgdown in action at
<http://pkgdown.r-lib.org>: this is the output of pkgdown applied to the
latest version of pkgdown. Learn more in `vignette("pkgdown")` or
`?build_site`.

## Installation

pkgdown is not currently available from CRAN, but you can install the
development version from github with:

``` r
# install.packages("devtools")
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
check into git, then go settings for your repo and make sure that the
**GitHub pages** source is set to “master branch /docs folder”.

The package also includes an RStudio add-in which you can bind to a
keyboard shortcut. I recommend `Cmd + Shift + W`: it uses Cmd + Shift,
like all other package development worksheets, it replaces a rarely used
command (close all tabs), and the W is mnemonic for website.

To customise your site, create `_pkgdown.yml` and modify it as described
in the documentation. Alternatively, you can also use
`pkgdown/_pkgdown.yml` if you need other files to customise your site.

## In the wild

As at last count, pkgdown is used [by over 1300
packages](https://github.com/search?utf8=✓&q=pkgdown.css+in%3Apath+path%3Adocs&type=Code).

Here are a few examples created by people contributors to pkgdown:

  - [bayesplot](http://mc-stan.org/bayesplot/index.html)
    \[[source](https://github.com/stan-dev/bayesplot/tree/gh-pages)\]:
    plotting functions for posterior analysis, model checking, and MCMC
    diagnostics.

  - [valr](https://rnabioco.github.io/valr/)
    \[[source](https://github.com/rnabioco/valr)\]: read and manipulate
    genome intervals and signals.

  - [mkin](http://jranke.github.io/mkin/)
    \[[source](https://github.com/jranke/mkin)\]: calculation routines
    based on the FOCUS Kinetics Report

  - [NMF](http://renozao.github.io/NMF/master/index.html)
    \[[source](https://github.com/renozao/NMF)\]: a framework to perform
    non-negative matrix factorization (NMF).

Comparing the output with the source is a great way to learn new pkgdown
techniques (particularly because ironically, the pkgdown documentation
isn’t very good yet)

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.
