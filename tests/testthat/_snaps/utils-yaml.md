# pkgdown_field produces useful description

    Code
      cli::cli_inform(pkgdown_field(pkg, c("a"), cfg = TRUE, fmt = TRUE))
    Message
      a in _pkgdown.yml

---

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

