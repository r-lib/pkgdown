# Build and deploy a site locally

Assumes that you're in a git clone of the project, and the package is
already installed. Use
[`usethis::use_pkgdown_github_pages()`](https://usethis.r-lib.org/reference/use_pkgdown.html)
to automate this process using GitHub actions.

## Usage

``` r
deploy_to_branch(
  pkg = ".",
  commit_message = construct_commit_message(pkg),
  clean = TRUE,
  branch = "gh-pages",
  remote = "origin",
  github_pages = (branch == "gh-pages"),
  ...,
  subdir = NULL
)
```

## Arguments

- pkg:

  Path to package.

- commit_message:

  The commit message to be used for the commit.

- clean:

  Clean all files from old site.

- branch:

  The git branch to deploy to

- remote:

  The git remote to deploy to

- github_pages:

  Is this a GitHub pages deploy. If `TRUE`, adds a `CNAME` file for
  custom domain name support, and a `.nojekyll` file to suppress jekyll
  rendering.

- ...:

  Additional arguments passed to
  [`build_site()`](https://pkgdown.r-lib.org/reference/build_site.md).

- subdir:

  The sub-directory where the site should be built on the branch. This
  argument can be used to support a number of site configurations. For
  example, you could build version-specific documentation by setting
  `subdir = "v1.2.3"`; `deploy_to_branch()` will build and deploy the
  package documentation in the `v.1.2.3/` directory of your site.
