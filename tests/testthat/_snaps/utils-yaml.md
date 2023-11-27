# pkgdown_field(s) produces useful description

    Code
      pkgdown_field(c("a", "b"))
    Output
      [1] "a.b"

---

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find component a.x in '_pkgdown.yml'.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find components a.x and a.y in '_pkgdown.yml'.

