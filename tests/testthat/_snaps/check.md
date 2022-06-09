# fails if reference index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_missing_topics()`:
      ! All topics must be included in reference index
      * Missing topics: ?

# fails if article index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `data_articles_index()`:
      ! Vignettes missing from index: 

# informs if everything is ok

    Code
      check_pkgdown(pkg)
    Message
      No problems found

