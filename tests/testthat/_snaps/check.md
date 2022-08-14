# fails if reference index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_missing_topics()`:
      ! All topics must be included in reference index
      x Missing topics: ?
      i Either add to _pkgdown.yml or use @keywords internal

# fails if article index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `data_articles_index()`:
      ! Vignettes missing from index: articles/nested, width

# informs if everything is ok

    Code
      check_pkgdown(pkg)
    Message
      No problems found

