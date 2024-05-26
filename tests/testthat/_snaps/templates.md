# Invalid bootstrap version spec in template package

    Code
      local_pkgdown_site(meta = list(template = list(package = "templatepackage")))
    Condition
      Error in `as_pkgdown()`:
      ! Must set one only of template.bootstrap and template.bslib.version.
      i Specified locally and in template package templatepackage.
      i Edit _pkgdown.yml to fix the problem.

# Invalid bootstrap version spec in _pkgdown.yml

    Code
      local_pkgdown_site(meta = list(template = list(bootstrap = 4, bslib = list(
        version = 5))))
    Condition
      Error in `as_pkgdown()`:
      ! Must set one only of template.bootstrap and template.bslib.version.
      i Edit _pkgdown.yml to fix the problem.

# Warns when Bootstrap theme is specified in multiple locations

    Code
      get_bslib_theme(pkg)
    Condition
      Warning:
      Multiple Bootstrap preset themes were set. Using "flatly" from template.bslib.preset.
      x Found template.bslib.preset, template.bslib.bootswatch, template.bootswatch, and template.params.bootswatch.
      i Remove extraneous theme declarations to avoid this warning.
    Output
      [1] "flatly"

