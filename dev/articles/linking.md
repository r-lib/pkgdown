# Auto-linking

## Within a package

pkgdown will automatically link to documentation and articles wherever
it’s possible to do unambiguously. This includes:

- Bare function calls, like
  [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md).
- Calls to `?`, like
  [`?build_site`](https://pkgdown.r-lib.org/dev/reference/build_site.md)
  or
  [`package?pkgdown`](https://pkgdown.r-lib.org/dev/reference/pkgdown-package.md).
- Calls to [`help()`](https://rdrr.io/r/utils/help.html), like
  [`help("pkgdown")`](https://pkgdown.r-lib.org/dev/reference/pkgdown-package.md).
- Calls to [`vignette()`](https://rdrr.io/r/utils/vignette.html), like
  [`vignette("pkgdown")`](https://pkgdown.r-lib.org/dev/articles/pkgdown.md).

## Across packages

Linking to documentation in another package is straightforward. Just
adapt the call in the usual way:

- [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html),
  [`MASS::addterm()`](https://rdrr.io/pkg/MASS/man/addterm.html).
- [`?purrr::map`](https://purrr.tidyverse.org/reference/map.html),
  [`?MASS::addterm`](https://rdrr.io/pkg/MASS/man/addterm.html).
- [`vignette("other-langs", package = "purrr")`](https://purrr.tidyverse.org/articles/other-langs.html),
  [`vignette("longintro", package = "rpart")`](https://cran.rstudio.com/web/packages/rpart/vignettes/longintro.pdf)
- [purrr](https://purrr.tidyverse.org/)

If pkgdown can find a pkgdown site for the remote package, it will link
to it; otherwise, it will link to <https://rdrr.io/> for documentation
and CRAN for vignettes. In order for a pkgdown site to be findable, it
needs to be listed in two places:

- In the `URL` field in the `DESCRIPTION`, as in
  [dplyr](https://github.com/tidyverse/dplyr/blob/85faf79c1fd74f4b4f95319e5be6a124a8075502/DESCRIPTION#L15):

      URL: https://dplyr.tidyverse.org, https://github.com/tidyverse/dplyr

- In the `url` field in `_pkgdown.yml`, as in
  [dplyr](https://github.com/tidyverse/dplyr/blob/master/_pkgdown.yml#L1)

  ``` yaml
  url: https://dplyr.tidyverse.org
  ```

  When this field is defined, pkgdown generates a public facing
  [`pkgdown.yml` file](https://dplyr.tidyverse.org/pkgdown.yml) that
  provides metadata about the site:

  ``` yaml
  pandoc: '2.2'
  pkgdown: 1.3.0
  pkgdown_sha: ~
  articles:
    compatibility: compatibility.html
    dplyr: dplyr.html
    dplyr_0.8.0: future/dplyr_0.8.0.html
    dplyr_0.8.0_new_hybrid: future/dplyr_0.8.0_new_hybrid.html
    programming: programming.html
    two-table: two-table.html
    window-functions: window-functions.html
  urls:
    reference: https://dplyr.tidyverse.org/reference
    article: https://dplyr.tidyverse.org/articles
  ```

Now, when you build a pkgdown site for a package that links to the dplyr
documentation (e.g.,
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)),
pkgdown looks first in dplyr’s `DESCRIPTION` to find its website, then
it looks for `pkgdown.yml`, and uses the metadata to generate the
correct links.

To allow your package to be linked by other locally installed packages,
even if your website is not reachable at build time, the following
option needs to be set in `_pkgdown.yml`:

``` yaml
deploy:
  install_metadata: true
```

This allows locally installed packages to access package index metadata
from the locally installed copy, which may be useful if your website
require auth, or you build behind a firewall.
