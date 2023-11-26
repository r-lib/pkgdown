# pkgdown_field(s) produces useful description [plain]

    Code
      pkgdown_field(c("a", "b"))
    Output
      [1] "a.b"

---

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find a.x component in '_pkgdown.yml'.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find a.x and a.y components in '_pkgdown.yml'.

# pkgdown_field(s) produces useful description [ansi]

    Code
      pkgdown_field(c("a", "b"))
    Output
      [1] "a.b"

---

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      [1m[33mError[39m in `check_yaml_has()`:[22m
      [1m[22m[33m![39m Can't find [32ma.x[39m component in [34m_pkgdown.yml[39m.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      [1m[33mError[39m in `check_yaml_has()`:[22m
      [1m[22m[33m![39m Can't find [32ma.x[39m and [32ma.y[39m components in [34m_pkgdown.yml[39m.

# pkgdown_field(s) produces useful description [unicode]

    Code
      pkgdown_field(c("a", "b"))
    Output
      [1] "a.b"

---

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find a.x component in '_pkgdown.yml'.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      Error in `check_yaml_has()`:
      ! Can't find a.x and a.y components in '_pkgdown.yml'.

# pkgdown_field(s) produces useful description [fancy]

    Code
      pkgdown_field(c("a", "b"))
    Output
      [1] "a.b"

---

    Code
      check_yaml_has("x", where = "a", pkg = pkg)
    Condition
      [1m[33mError[39m in `check_yaml_has()`:[22m
      [1m[22m[33m![39m Can't find [32ma.x[39m component in [34m_pkgdown.yml[39m.
    Code
      check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
    Condition
      [1m[33mError[39m in `check_yaml_has()`:[22m
      [1m[22m[33m![39m Can't find [32ma.x[39m and [32ma.y[39m components in [34m_pkgdown.yml[39m.

