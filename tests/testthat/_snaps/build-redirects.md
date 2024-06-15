# build_redirect() works

    Code
      build_redirect(c("old.html", "new.html#section"), 1, pkg = pkg)
    Message
      Adding redirect from old.html to new.html#section.

# build_redirect() errors if one entry is not right.

    Code
      data_redirects_(redirects = "old.html")
    Condition
      Error in `data_redirects_()`:
      ! In _pkgdown.yml, redirects must be a list, not the string "old.html".
    Code
      data_redirects_(redirects = list("old.html"))
    Condition
      Error in `data_redirects_()`:
      ! In _pkgdown.yml, redirects[1] must be a character vector of length 2, not the string "old.html".

