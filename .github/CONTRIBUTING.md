# Contributing to pkgdown

This outlines how to propose a change to pkgdown. For more detailed
info about contributing to this, and other tidyverse packages, please see the
[**development contributing guide**](https://rstd.io/tidy-contrib).

## Fixing typos

Small typos or grammatical errors in documentation may be edited directly using
the GitHub web interface, so long as the changes are made in the _source_ file.

*  YES: you edit a roxygen comment in a `.R` file below `R/`.
*  NO: you edit an `.Rd` file below `man/`.

## Prerequisites

Before you make a substantial pull request, you should always file an issue and
make sure someone from the team agrees that it’s a problem. If you’ve found a
bug, create an associated issue and illustrate the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex).

### Package reprexes

If you encounter unexpected errors after running `pkgdown::build_site()`, try
to build a minimal package that recreates the error. An ideal minimal package has
*no dependencies*, making it easy to install and quickly reproduce the error. An
example of a minimal package was [this issue](https://github.com/r-lib/pkgdown/issues/720#issuecomment-397606145),
where a minimal package containing a single `.R` file with two lines could reproduce
the error.

Once you have built a minimal package that recreates the error, create a GitHub
repository from the package, and file an issue with a link to the repository.

The quickest way to set up minimal example package is with `usethis::create_package()`:

```R
library(usethis)
library(pkgdown)

tmp <- file.path(tempdir(), "test")
usethis::create_package(tmp, open)
# ... edit files ...
pkgdown::build_site(tmp, new_process = FALSE, preview = FALSE)
```


## Pull request process

*  We recommend that you create a Git branch for each pull request (PR).  
*  Look at the Travis and AppVeyor build status before and after making changes.
The `README` should contain badges for any continuous integration services used
by the package.  
*  New code should follow the tidyverse [style guide](http://style.tidyverse.org).
You can use the [styler](https://CRAN.R-project.org/package=styler) package to
apply these styles, but please don't restyle code that has nothing to do with 
your PR.  
*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with
[Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/markdown.html), 
for documentation.  
*  We use [testthat](https://cran.r-project.org/package=testthat). Contributions
with test cases included are easier to accept.  
*  For user-facing changes, add a bullet to the top of `NEWS.md` below the
current development version header describing the changes made followed by your
GitHub username, and links to relevant issue(s)/PR(s).

* We might ask you for a Netlify preview of your changes i.e. how does the updated version of the pkgdown package make the pkgdown pkgdown website look like. Build and install the amended package, then re-build the website (`clean_site()` and then `build_site()`) which will update the docs/ folder. Log into Netlify at https://app.netlify.com/sites/, scroll down. You'll see a box with dashed outline that says "Want to deploy a new site without connecting to Git?". Open up a file browser, navigate to the "docs" directory of the site, and drag the folder to that dashed box, which will copy all the files into a temporary netlify site. Once complete, it will generate a temp URL at the top you can copy/paste in the PR discussion.

## Code of Conduct

Please note that the pkgdown project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.

## See tidyverse [development contributing guide](https://rstd.io/tidy-contrib)
for further details.


# Rd translation

If you encounter problems with Rd tags, please use `rd2html()` to create a reprexes:

```R
library(pkgdown)

rd2html("a\n%b\nc")
rd2html("a & b")
```

