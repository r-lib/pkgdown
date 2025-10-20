# Contributing to pkgdown

This document outlines how to propose a change to pkgdown. For more
detailed info about contributing to this and other tidyverse packages,
please see the [**tidyverse contribution
guide**](https://rstd.io/tidy-contrib).

## pkgdown and Pandoc versions

The versions of pkgdown and Pandoc used to build a website are stored in
the public facing `pkgdown.yml` file,
e.g. <https://dplyr.tidyverse.org/pkgdown.yml>.

## Package reprexes

If you encounter unexpected errors after running
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md),
try to build a minimal package that recreates the error. An ideal
minimal package has *no dependencies*, making it easy to install and
quickly reproduce the error. An example of a minimal package was [this
issue](https://github.com/r-lib/pkgdown/issues/720#issuecomment-397606145),
where a minimal package containing a single `.R` file with two lines
could reproduce the error.

The quickest way to set up minimal example package is with
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html):

``` r
usethis::create_package("~/desktop/testpackage")
# ... edit files ...
pkgdown::build_site(tmp, new_process = FALSE, preview = FALSE)
```

Once you have built a minimal package that recreates the error, create a
GitHub repository from the package (e.g. with
[`usethis::use_git()`](https://usethis.r-lib.org/reference/use_git.html) +
[`usethis::use_github()`](https://usethis.r-lib.org/reference/use_github.html)),
and file an issue with a link to the repository.

## Rd translation

If you encounter problems with Rd tags, please use
[`rd2html()`](https://pkgdown.r-lib.org/dev/reference/rd2html.md) to
create a reprexes:

``` r
library(pkgdown)

rd2html("a\n%b\nc")
rd2html("a & b")
```

## Pull request process

- We recommend that you create a Git branch for each pull request
  (PR).  
- Look at the Travis and AppVeyor build status before and after making
  changes. The `README` should contain badges for any continuous
  integration services used by the package.  
- New code should follow the tidyverse [style
  guide](http://style.tidyverse.org). You can use the
  [styler](https://CRAN.R-project.org/package=styler) package to apply
  these styles, but please don’t restyle code that has nothing to do
  with your PR.  
- We use [roxygen2](https://cran.r-project.org/package=roxygen2), with
  [Markdown
  syntax](https://roxygen2.r-lib.org/articles/rd-formatting.html), for
  documentation.  
- We use [testthat](https://cran.r-project.org/package=testthat).
  Contributions with test cases included are easier to accept.  
- For user-facing changes, add a bullet to the top of `NEWS.md` below
  the current development version header describing the changes made
  followed by your GitHub username, and links to relevant
  issue(s)/PR(s).

### Netlify

We might ask you for a Netlify preview of your changes i.e. how do your
local changes affect the pkgdown website?

1.  Build and install the amended package, then re-build the website
    ([`clean_site()`](https://pkgdown.r-lib.org/dev/reference/clean.md)
    and then
    [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md))
    which will update the docs/ folder.
2.  Log into Netlify at <https://app.netlify.com/sites/>, and scroll to
    the bottom. You’ll see a box with dashed outline that says “Want to
    deploy a new site without connecting to Git?”.
3.  Open up a file browser, navigate to `docs/`, and drag the `docs/`
    folder to the dashed box, which will copy all the files into a
    temporary netlify site.
4.  After the file transfer completes, netlify will generate a temporary
    URL on a new page that you can copy/paste in the PR discussion.

## Fixing typos

Small typos or grammatical errors in documentation may be edited
directly using the GitHub web interface, so long as the changes are made
in the *source* file.

- YES: you edit a roxygen comment in a `.R` file below `R/`.
- NO: you edit an `.Rd` file below `man/`.

## Prerequisites

Before you make a substantial pull request, you should always file an
issue and make sure someone from the team agrees that it’s a problem. If
you’ve found a bug, create an associated issue and illustrate the bug
with a minimal [reprex](https://www.tidyverse.org/help/#reprex).

## Code of Conduct

Please note that the pkgdown project is released with a [Contributor
Code of Conduct](https://pkgdown.r-lib.org/dev/CODE_OF_CONDUCT.md). By
contributing to this project you agree to abide by its terms.
