# validations yaml specification

    Code
      build_bslib_(theme = 1)
    Condition
      Error in `bs_theme_rules()`:
      ! In _pkgdown.yml, template.theme must be a string, not the number 1.
    Code
      build_bslib_(theme = "fruit")
    Condition
      Error in `build_bslib_()`:
      ! In _pkgdown.yml, template.theme uses theme "fruit"
    Code
      build_bslib_(`theme-dark` = "fruit")
    Condition
      Error in `build_bslib_()`:
      ! In _pkgdown.yml, template.theme-dark uses theme "fruit"

