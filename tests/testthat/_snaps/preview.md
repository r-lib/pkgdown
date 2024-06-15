# checks its inputs

    Code
      preview_site(pkg, path = 1)
    Condition
      Error in `preview_site()`:
      ! `path` must be a single string, not the number 1.
    Code
      preview_site(pkg, path = "foo")
    Condition
      Error in `preview_site()`:
      ! Can't find file 'foo'.
    Code
      preview_site(pkg, preview = 1)
    Condition
      Error in `preview_site()`:
      ! `preview` must be `TRUE`, `FALSE`, or `NA`, not the number 1.

