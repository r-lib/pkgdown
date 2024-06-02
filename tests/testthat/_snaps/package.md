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

# check_bootstrap_version() allows 3, 4 (with warning), and 5

    Code
      expect_equal(check_bootstrap_version(4, pkg), 5)
    Condition
      Warning:
      In _pkgdown.yml, `template.bootstrap: 4` no longer supported
      i Using `template.bootstrap: 5` instead

# check_bootstrap_version() gives informative error otherwise

    Code
      check_bootstrap_version(1, pkg)
    Condition
      Error in `check_bootstrap_version()`:
      ! In _pkgdown.yml, template.bootstrap must be 3 or 5, not 1.

# read_meta() errors gracefully if _pkgdown.yml failed to parse

    Code
      as_pkgdown(pkg$src_path)
    Condition
      Error in `as_pkgdown()`:
      ! Could not parse config file at '<src>/_pkgdown.yml'.
      Caused by error in `yaml.load()`:
      ! Scanner error: mapping values are not allowed in this context at line 2, column 8

