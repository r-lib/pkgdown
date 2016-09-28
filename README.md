# staticdocs

[![Travis-CI Build Status](https://travis-ci.org/hadley/staticdocs.svg?branch=master)](https://travis-ci.org/hadley/staticdocs)

staticdocs is designed to make it quick and easy to build a website for your package. You can see staticdocs in action at <http://hadley.github.io/staticdocs/>: this is the output of staticdocs applied to the latest version of staticdocs.

## Installation

staticdocs is not currently available from CRAN, but you can install the development version from github with:

```R
# install.packages("devtools")
devtools::install_github("hadley/staticdocs")
```

## Usage

Run staticdocs from the package directory each time you release your package:

```R
staticdocs::build_site()
```

This will generate a `docs/` directory. The home page will be generated from your package's `README.md`, and a function reference will be generated from the documentation in the `man/` directory. If you are using GitHub, the easiest way to make this your package website is to check into git, then go settings for your repo and make sure that the __GitHub pages__ source is set to "master branch /docs folder".

The package also includes an RStudio add-in which you can bind to a keyboard shortcut.
