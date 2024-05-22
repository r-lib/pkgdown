# validations yaml specification

    Code
      build_bslib_(template = list(theme = 1, bootstrap = 5))
    Condition
      Error in `bs_theme_rules()`:
      ! template.theme must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      build_bslib_(template = list(theme = "fruit", bootstrap = 5))
    Condition
      Error in `build_bslib_()`:
      ! template.theme uses theme "fruit"
      i Edit _pkgdown.yml to fix the problem.
    Code
      build_bslib_(template = list(`theme-dark` = "fruit", bootstrap = 5))
    Condition
      Error in `build_bslib_()`:
      ! template.theme-dark uses theme "fruit"
      i Edit _pkgdown.yml to fix the problem.

