# pkgdown_field produces useful description

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find component a.x.
      i Edit _pkgdown.yml to define it.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find components a.x and a.y.
      i Edit _pkgdown.yml to define them.

