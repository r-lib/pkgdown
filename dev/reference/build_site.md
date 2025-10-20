# Build a complete pkgdown website

`build_site()` is a convenient wrapper around six functions:

- [`init_site()`](https://pkgdown.r-lib.org/dev/reference/init_site.md)

- [`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md)

- [`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md)

- [`build_articles()`](https://pkgdown.r-lib.org/dev/reference/build_articles.md)

- [`build_tutorials()`](https://pkgdown.r-lib.org/dev/reference/build_tutorials.md)

- [`build_news()`](https://pkgdown.r-lib.org/dev/reference/build_news.md)

- [`build_redirects()`](https://pkgdown.r-lib.org/dev/reference/build_redirects.md)

- [`build_llm_docs()`](https://pkgdown.r-lib.org/dev/reference/build_llm_docs.md)

See the documentation for the each function to learn how to control that
aspect of the site. This page documents options that affect the whole
site.

## Usage

``` r
build_site(
  pkg = ".",
  examples = TRUE,
  run_dont_run = FALSE,
  seed = 1014L,
  lazy = FALSE,
  override = list(),
  preview = NA,
  devel = FALSE,
  new_process = !devel,
  install = !devel,
  quiet = TRUE
)
```

## Arguments

- pkg:

  Path to package.

- examples:

  Run examples?

- run_dont_run:

  Run examples that are surrounded in \dontrun?

- seed:

  Seed used to initialize random number generation in order to make
  article output reproducible. An integer scalar or `NULL` for no seed.

- lazy:

  If `TRUE`, will only rebuild articles and reference pages if the
  source is newer than the destination.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

- preview:

  If `TRUE`, or `is.na(preview) && interactive()`, will preview freshly
  generated section in browser.

- devel:

  Use development or deployment process?

  If `TRUE`, uses lighter-weight process suitable for rapid iteration;
  it will run examples and vignettes in the current process, and will
  load code with
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html).

  If `FALSE`, will first install the package to a temporary library, and
  will run all examples and vignettes in a new process.

  `build_site()` defaults to `devel = FALSE` so that you get high
  fidelity outputs when you building the complete site;
  [`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md),
  [`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md)
  and friends default to `devel = TRUE` so that you can rapidly iterate
  during development.

- new_process:

  If `TRUE`, will run `build_site()` in a separate process. This
  enhances reproducibility by ensuring nothing that you have loaded in
  the current process affects the build process.

- install:

  If `TRUE`, will install the package in a temporary library so it is
  available for vignettes.

- quiet:

  If `FALSE`, generate build messages for build functions that take
  `quiet` arguments.

## General config

- `destination` controls where the site will be generated, defaulting to
  `docs/`. Paths are relative to the package root.

- `url` is optional, but strongly recommended.

      url: https://pkgdown.r-lib.org

  It specifies where the site will be published and is used to allow
  other pkgdown sites to link to your site when needed
  ([`vignette("linking")`](https://pkgdown.r-lib.org/dev/articles/linking.md)),
  generate a `sitemap.xml`, automatically generate a `CNAME` when
  [deploying to
  github](https://pkgdown.r-lib.org/dev/reference/build_site_github_pages.md),
  generate the metadata needed rich social "media cards"
  ([`vignette("metadata")`](https://pkgdown.r-lib.org/dev/articles/metadata.md)),
  and more.

- `title` overrides the default site title, which is the package name.
  It's used in the page title and default navbar.

## Navbar and footer

The `navbar` and `footer` fields control the appearance of the navbar
footer which appear on every page. Learn more about these fields in
[`vignette("customise")`](https://pkgdown.r-lib.org/dev/articles/customise.md).

## Development mode

The `development` field allows you to generate different sites for the
development and released versions of your package. To use it, you first
need to set the development `mode`:

    development:
      mode: auto

### Setting development mode

The development `mode` of a site controls where the built site is placed
and how it is styled (i.e. the colour of the package version in the
navbar, the version tooltip), and whether or not the site is indexed by
search engines. There are four possible modes:

- **automatic** (`mode: auto`): determines the mode based on the
  version:

  - `0.0.0.9000` (`0.0.0.*`): unreleased.

  - four version components: development.

  - everything else -\> release.

- **release** (`mode: release`), the default. Site is written to `docs/`
  and styled like a released package, even if the content is for an
  unreleased or development version. Version in navbar gets the default
  colouring. Development badges are not shown in the sidebar (see
  [`?build_home`](https://pkgdown.r-lib.org/dev/reference/build_home.md)).

- **development** (`mode: devel`). Site is written to `docs/dev/`. The
  navbar version gets a "danger" class and a tooltip stating these are
  docs for an in-development version of the package. The `noindex` meta
  tag is used to ensure that these packages are not indexed by search
  engines. Development badges are shown in the sidebar (see
  [`?build_home`](https://pkgdown.r-lib.org/dev/reference/build_home.md)).

- **unreleased** (`mode: unreleased`). Site is written to `docs/`.
  Version in navbar gets the "danger" class, and a message indicating
  the package is not yet on CRAN. Development badges are shown in the
  sidebar (see
  [`?build_home`](https://pkgdown.r-lib.org/dev/reference/build_home.md)).

Use `mode: auto` if you want both a released and a dev site, and
`mode: release` if you just want a single site. It is very rare that you
will need either devel or unreleased modes.

You can override the mode specified in the `_pkgdown.yml` by setting by
setting `PKGDOWN_DEV_MODE` to `devel` or `release`.

### Selective HTML

You can selectively show HTML only on the devel or release site by
adding class `pkgdown-devel` or `pkgdown-release`. This is most easily
accessed from `.Rmd` files where you can use pandoc's `<div>` syntax to
control where a block of markdown will display. For example, you can use
the following markdown in your README to only show GitHub install
instructions on the development version of your site:

    ::: {.pkgdown-devel}
    You can install the development version of pkgdown from GitHub with:
    `remotes::install_github("r-lib/pkgdown")`
    :::

You can use a similar technique to control where badges are displayed.
This markdown show the CRAN status badge on the site for the released
package and the GitHub check status for the development package:

    [![CRAN Status](https://www.r-pkg.org/badges/version/pkgdown)]
      (https://cran.r-project.org/package=pkgdown){.pkgdown-release}
    [![R-CMD-check](https://github.com/r-lib/pkgdown/workflows/R-CMD-check/badge.svg)]
      (https://github.com/r-lib/pkgdown/actions){.pkgdown-devel}

### Other options

There are three other options that you can control:

    development:
      destination: dev
      version_label: danger
      version_tooltip: "Custom message here"

`destination` allows you to override the default subdirectory used for
the development site; it defaults to `dev/`. `version_label` allows you
to override the style used for development (and unreleased) versions of
the package. It defaults to "danger", but you can set to "default",
"info", or "warning" instead. (The precise colours are determined by
your bootstrap theme, but become progressively more eye catching as you
go from default to danger). Finally, you can choose to override the
default tooltip with `version_tooltip`.

## Template

The `template` field is mostly used to control the appearance of the
site. See
[`vignette("customise")`](https://pkgdown.r-lib.org/dev/articles/customise.md)
for details. But it's also used to control

### Other aspects

There are a few other `template` fields that control other aspects of
the site:

- `noindex: true` will suppress indexing of your pages by search
  engines:

      template:
        params:
          noindex: true

- `google_site_verification` allows you to verify your site with google:

      template:
        params:
          google_site_verification: _nn6ile-a6x6lctOW

- `trailing_slash_redirect: true` will automatically redirect
  `your-package-url.com` to `your-package-url.com/`, using a JS script
  added to the `<head>` of the home page. This is useful in certain
  redirect scenarios.

      template:
        trailing_slash_redirect: true

### Analytics

To capture usage of your site with a web analytics tool, you can make
use of the `includes` field to add the special HTML they need. This HTML
is typically placed `in_header` (actually in the `<head>`),
`before_body`, or `after_body`. You can learn more about how includes
work in pkgdown at
<https://pkgdown.r-lib.org/articles/customise.html#additional-html-and-files>.

I include a few examples of popular analytics platforms below, but we
recommend getting the HTML directly from the tool:

- [plausible.io](https://plausible.io):

      template:
        includes:
          in_header: |
            <script defer data-domain="{YOUR DOMAIN}" src="https://plausible.io/js/plausible.js"></script>

- [Google analytics](https://analytics.google.com/analytics/web/):

      template:
        includes:
          in_header: |
             <!-- Global site tag (gtag.js) - Google Analytics -->
             <script async src="https://www.googletagmanager.com/gtag/js?id={YOUR MEASUREMENT ID}" ></script>
             <script>
               window.dataLayer = window.dataLayer || [];
               function gtag(){dataLayer.push(arguments);}
               gtag('js', new Date());

               gtag('config', '{YOUR MEASUREMENT ID}');
             </script>
             <!-- Google tag (gtag.js) -->

- [GoatCounter](https://www.goatcounter.com):

      template:
        includes:
          after_body: >
            <script data-goatcounter="https://{YOUR CODE}.goatcounter.com/count" data-goatcounter-settings="{YOUR SETTINGS}" async src="https://gc.zgo.at/count.js"></script>

## Source repository

Use the `repo` field to override pkgdown's automatically discovery of
your source repository. This is used in the navbar, on the homepage, in
articles and reference topics, and in the changelog (to link to issue
numbers and user names). pkgdown can automatically figure out the
necessary URLs if you link to a GitHub, GitLab or Codeberg repo in your
`BugReports` or `URL` field.

Otherwise, you can supply your own in the `repo` field:

    repo:
      url:
        home: https://github.com/r-lib/pkgdown/
        source: https://github.com/r-lib/pkgdown/blob/HEAD/
        issue: https://github.com/r-lib/pkgdown/issues/
        user: https://github.com/

- `home`: path to package home on source code repository.

- `source`: path to source of individual file in default branch (more on
  that below).

- `issue`: path to individual issue.

- `user`: path to user.

The varying components (e.g. path, issue number, user name) are pasted
on the end of these URLs so they should have trailing `/`s.

When creating the link to a package source, we have to link to a
specific branch. The default behaviour is to use current branch when in
GitHub actions and `HEAD` otherwise. You can overide this default with
`repo.branch`:

    repo:
      branch: devel

pkgdown can automatically link to Jira issues as well if specify both a
custom `issue` URL as well Jira project names to auto-link in
`jira_projects`. You can specify as many projects as you would like:

    repo:
      jira_projects: [this_project, another_project]
      url:
        issue: https://jira.organisation.com/jira/browse/

## Deployment (`deploy`)

There is a single `deploy` field

- `install_metadata` allows you to install package index metadata into
  the package itself. Normally this metadata is made available on the
  published site; installing it into your package means that it's
  available for autolinking even if your website is not reachable at
  build time (e.g. because behind a firewall or requires auth).

      deploy:
        install_metadata: true

## Examples

``` r
if (FALSE) { # \dontrun{
build_site()

build_site(override = list(destination = tempdir()))
} # }
```
