# fails if reference index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_pkgdown()`:
      ! All topics must be included in reference index
      x Missing topics: ?
      i Either add to _pkgdown.yml or use @keywords internal

# fails if article index incomplete

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_pkgdown()`:
      ! 2 vignettes missing from index in _pkgdown.yml: "articles/nested" and "width".

# informs if everything is ok

    Code
      check_pkgdown(pkg)
    Message
      v No problems found in _pkgdown.yml

# warn about missing images in readme

    Code
      check_built_site(pkg)
    Message
      -- Checking for problems -------------------------------------------------------
    Condition
      Warning:
      Missing images in 'README.md': 'articles/kitten.jpg'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# readme can use images from vignettes

    Code
      check_built_site(pkg)
    Message
      -- Checking for problems -------------------------------------------------------

