# config_check_list gives informative errors

    Code
      config_check_list(1, "x", error_path = "path", error_pkg = pkg)
    Condition
      Error:
      ! path must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      config_check_list(list(x = 1, y = 1), c("y", "z"), error_path = "path",
      error_pkg = pkg)
    Condition
      Error:
      ! path must have components "y" and "z".
      1 missing component: "z".
      i Edit _pkgdown.yml to fix the problem.

# config_pluck_yaml generates informative error

    Code
      config_pluck_character(pkg, "x")
    Condition
      Error:
      ! x must be a character vector, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

