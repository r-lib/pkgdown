# validations yaml specification

    Code
      build_bslib_(theme = 1)
    Condition
      Error in `bs_theme_rules()`:
      ! template.theme must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      build_bslib_(theme = "fruit")
    Condition
      Error in `build_bslib_()`:
      ! template.theme uses theme "fruit"
      i Edit _pkgdown.yml to fix the problem.
    Code
      build_bslib_(`theme-dark` = "fruit")
    Condition
      Error in `build_bslib_()`:
      ! template.theme-dark uses theme "fruit"
      i Edit _pkgdown.yml to fix the problem.

