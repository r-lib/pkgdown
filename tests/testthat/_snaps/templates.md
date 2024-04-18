# Invalid bootstrap version spec in template package

    Code
      local_pkgdown_site(meta = list(template = list(package = "templatepackage")))
    Condition
      Error in `as_pkgdown()`:
      ! Both template.bootstrap and template.bslib.version are set.
      i Update the pkgdown config in templatepackage, or set a Bootstrap version in your '_pkgdown.yml'.

# Invalid bootstrap version spec in _pkgdown.yml

    Code
      local_pkgdown_site(meta = list(template = list(bootstrap = 4, bslib = list(
        version = 5))))
    Condition
      Error in `as_pkgdown()`:
      ! Both template.bootstrap and template.bslib.version are set.

