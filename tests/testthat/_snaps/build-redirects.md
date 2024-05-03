# build_redirect() errors if one entry is not right.

    Code
      build_redirect(c("old.html"), 5, pkg)
    Condition
      Error:
      ! redirects[[5]] must be a character vector of length 2.
      i Edit _pkgdown.yml to fix the problem.

