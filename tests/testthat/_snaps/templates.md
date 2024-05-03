# Invalid bootstrap version spec in template package

    Code
      local_pkgdown_site(meta = list(template = list(package = "templatepackage")))
    Condition
      Error in `as_pkgdown()`:
      ! Must set one only of template.bootstrap and template.bslib.version.
      i Update the pkgdown config in templatepackage, or set a Bootstrap version in your '_pkgdown.yml'.

# Invalid bootstrap version spec in _pkgdown.yml

    Code
      local_pkgdown_site(meta = list(template = list(bootstrap = 4, bslib = list(
        version = 5))))
    Condition
      Error in `as_pkgdown()`:
      ! Must set one only of template.bootstrap and template.bslib.version.
      i Remove one of them from '_pkgdown.yml '

# Warns when Bootstrap theme is specified in multiple locations

    Multiple Bootstrap preset themes were set. Using "flatly" from template.bslib.preset.
    x Found template.bslib.preset, template.bslib.bootswatch, template.bootswatch, and template.params.bootswatch.
    i Remove extraneous theme declarations to avoid this warning.

