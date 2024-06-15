# validates yaml

    Code
      data_development_(development = 1)
    Condition
      Error in `as_pkgdown()`:
      ! In _pkgdown.yml, development must be a list, not the number 1.
    Code
      data_development_(development = list(mode = 1))
    Condition
      Error in `as_pkgdown()`:
      ! In _pkgdown.yml, development.mode must be a string, not the number 1.
    Code
      data_development_(development = list(mode = "foo"))
    Condition
      Error in `as_pkgdown()`:
      ! In _pkgdown.yml, development.mode must be one of auto, default, release, devel, or unreleased, not foo.
    Code
      data_development_(development = list(destination = 1))
    Condition
      Error in `as_pkgdown()`:
      ! In _pkgdown.yml, development.destination must be a string, not the number 1.
    Code
      data_development_(development = list(version_label = 1))
    Condition
      Error in `as_pkgdown()`:
      ! In _pkgdown.yml, development.version_label must be a string, not the number 1.

