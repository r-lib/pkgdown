# pkgdown_field(s) produces useful description

    Code
      pkgdown_field(pkg, c("a", "b"))
    Output
      [1] "a.b in '_pkgdown.yml'"
    Code
      pkgdown_fields(pkg, list(c("a", "b"), "c"))
    Output
      [1] "a.b, c in '_pkgdown.yml'"

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
      ! Can't find components a.x, a.y in '_pkgdown.yml'.

