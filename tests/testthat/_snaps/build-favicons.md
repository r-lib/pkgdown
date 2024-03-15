# missing logo generates message

    Code
      expect_output(build_favicons(pkg), "Building favicons")
    Condition
      Error in `build_favicons()`:
      ! Can't find package logo PNG or SVG to build favicons.
      i See `usethis::use_logo()` for more information.

# existing logo generates message

    Code
      build_favicons(pkg)
    Message
      Favicons already exist in 'pkgdown'
      i Set `overwrite = TRUE` to re-create.

