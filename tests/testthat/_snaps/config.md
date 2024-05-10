# config_pluck_character generates informative error

    Code
      config_pluck_character(pkg, "x")
    Condition
      Error:
      ! x must be a character vector, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

# config_pluck_string generates informative error

    Code
      config_pluck_string(pkg, "x")
    Condition
      Error:
      ! x must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

# config_check_list gives informative errors

    Code
      config_check_list_(1, has_names = "x")
    Condition
      Error in `config_check_list_()`:
      ! path must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      config_check_list_(list(x = 1, y = 1), has_names = c("y", "z"))
    Condition
      Error in `config_check_list_()`:
      ! path must have components "y" and "z".
      1 missing component: "z".
      i Edit _pkgdown.yml to fix the problem.

