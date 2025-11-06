# Deploy a pkgdown site on Travis-CI to Github Pages

**\[superseded\]**

`deploy_site_github()` was designed to deploy your site from Travis CI,
which we no longer recommend, so this function is deprecated. There are
two replacements:

- [`usethis::use_pkgdown_github_pages()`](https://usethis.r-lib.org/reference/use_pkgdown.html)
  will setup a GitHub action to automatically build and deploy your
  package website to GitHub pages.

- [`deploy_to_branch()`](https://pkgdown.r-lib.org/reference/deploy_to_branch.md)
  can be called locally to build and deploy your website to any desired
  branch.

## Usage

``` r
deploy_site_github(
  pkg = ".",
  install = TRUE,
  tarball = Sys.getenv("PKG_TARBALL", ""),
  ssh_id = Sys.getenv("id_rsa", ""),
  commit_message = construct_commit_message(pkg),
  clean = FALSE,
  verbose = FALSE,
  host = "github.com",
  ...,
  repo_slug = Sys.getenv("TRAVIS_REPO_SLUG", "")
)
```

## Arguments

- pkg:

  Path to package.

- install:

  Optionally, opt-out of automatic installation. This is necessary if
  the package you're documenting is a dependency of pkgdown

- tarball:

  The location of the built package tarball. The default Travis
  configuration for R packages sets `PKG_TARBALL` to this path.

- ssh_id:

  The private id to use, a base64 encoded content of the private pem
  file. This should *not* be your personal private key. Instead create a
  new keypair specifically for deploying the site. The easiest way is to
  use `travis::use_travis_deploy()`.

- commit_message:

  The commit message to be used for the commit.

- clean:

  Clean all files from old site.

- verbose:

  Print verbose output

- host:

  The GitHub host url.

- ...:

  Additional arguments passed to
  [`build_site()`](https://pkgdown.r-lib.org/reference/build_site.md).

- repo_slug:

  The `user/repo` slug for the repository.
