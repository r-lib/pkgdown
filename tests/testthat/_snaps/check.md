# fails if reference index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_pkgdown()`:
      ! 1 topic missing from index: "?".
      i Either use `@keywords internal` to drop from index, or
      i Edit _pkgdown.yml to fix the problem.

# fails if article index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_pkgdown()`:
      ! 2 vignettes missing from index: "articles/nested" and "width".
      i Edit _pkgdown.yml to fix the problem.

# informs if everything is ok

    Code
      check_pkgdown(pkg)
    Message
      v No problems found.

# warn about missing images in readme

    Code
      check_built_site(pkg)
    Message
      -- Checking for problems -------------------------------------------------------
      x Missing images in 'README.md': 'articles/kitten.jpg'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

