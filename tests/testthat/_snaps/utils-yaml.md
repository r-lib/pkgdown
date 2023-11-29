# pkgdown_field produces useful description

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find component a.x in '_pkgdown.yml'.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find components a.x in '_pkgdown.yml'.
      Can't find components a.y in '_pkgdown.yml'.

