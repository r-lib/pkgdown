# fails if reference index incomplete [plain]

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_missing_topics()`:
      ! All topics must be included in reference index
      x Missing topics: ?
      i Either add to _pkgdown.yml or use @keywords internal

# fails if reference index incomplete [ansi]

    Code
      check_pkgdown(pkg)
    Condition
      [1m[33mError[39m in `check_missing_topics()`:[22m
      [33m![39m All topics must be included in reference index
      [31mx[39m Missing topics: ?
      [34mi[39m Either add to _pkgdown.yml or use @keywords internal

# fails if reference index incomplete [unicode]

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_missing_topics()`:
      ! All topics must be included in reference index
      ✖ Missing topics: ?
      ℹ Either add to _pkgdown.yml or use @keywords internal

# fails if reference index incomplete [fancy]

    Code
      check_pkgdown(pkg)
    Condition
      [1m[33mError[39m in `check_missing_topics()`:[22m
      [33m![39m All topics must be included in reference index
      [31m✖[39m Missing topics: ?
      [34mℹ[39m Either add to _pkgdown.yml or use @keywords internal

# fails if article index incomplete [plain]

    Code
      check_pkgdown(pkg)
    Condition
      Error in `data_articles_index()`:
      ! Vignettes missing from index: articles/nested and width

# fails if article index incomplete [ansi]

    Code
      check_pkgdown(pkg)
    Condition
      [1m[33mError[39m in `data_articles_index()`:[22m
      [1m[22m[33m![39m Vignettes missing from index: articles/nested and width

# fails if article index incomplete [unicode]

    Code
      check_pkgdown(pkg)
    Condition
      Error in `data_articles_index()`:
      ! Vignettes missing from index: articles/nested and width

# fails if article index incomplete [fancy]

    Code
      check_pkgdown(pkg)
    Condition
      [1m[33mError[39m in `data_articles_index()`:[22m
      [1m[22m[33m![39m Vignettes missing from index: articles/nested and width

# informs if everything is ok [plain]

    Code
      check_pkgdown(pkg)

# informs if everything is ok [ansi]

    Code
      check_pkgdown(pkg)

# informs if everything is ok [unicode]

    Code
      check_pkgdown(pkg)

# informs if everything is ok [fancy]

    Code
      check_pkgdown(pkg)

