# is_pkgdown checks its inputs

    Code
      as_pkgdown(1)
    Condition
      Error in `as_pkgdown()`:
      ! `pkg` must be a single string, not the number 1.
    Code
      as_pkgdown(override = 1)
    Condition
      Error in `as_pkgdown()`:
      ! `override` must be a list, not the number 1.

# check_bootstrap_version() gives informative error otherwise

    Code
      check_bootstrap_version(1, pkg)
    Condition
      Error:
      ! In _pkgdown.yml, template.bootstrap must be 3 or 5, not 1.

# read_meta() errors gracefully if _pkgdown.yml failed to parse

    Code
      as_pkgdown(pkg$src_path)
    Condition
      Error in `as_pkgdown()`:
      ! Could not parse config file at '<src>/_pkgdown.yml'.
      Caused by error in `yaml.load()`:
      ! Scanner error: mapping values are not allowed in this context at line 2, column 8

