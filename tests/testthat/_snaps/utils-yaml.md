# check_yaml_has produces informative errors

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find component a.x.
      i Edit _pkgdown.yml to fix the problem.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error:
      ! Can't find components a.x and a.y.
      i Edit _pkgdown.yml to fix the problem.

