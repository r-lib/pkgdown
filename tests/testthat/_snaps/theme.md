# check_bslib_theme() works

    Code
      check_bslib_theme("paper", pkg, bs_version = 4)
    Condition
      Error:
      x In _pkgdown.yml, template.bootswatch contains unknown Bootswatch/bslib theme "paper".
      i Using Bootstrap version 4 (template.bootstrap).

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

