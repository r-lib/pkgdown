# missing template package yields custom error

    Code
      path_package_pkgdown("x", "missing", 3)
    Condition
      Error:
      ! Template package "missing" is not installed.
      i Please install before continuing.

# out_of_date works as expected

    Code
      out_of_date("doesntexist", temp1)
    Condition
      Error:
      ! 'doesntexist' does not exist

