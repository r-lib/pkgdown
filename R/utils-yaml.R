
# YAML --------------------------------------------------------------------

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}

pkgdown_field <- function(pkg, field) {
  pkgdown_fields(pkg, list(field))
}

pkgdown_fields <- function(pkg, fields, join = ", ") {
  fields <- purrr::map_chr(fields, ~ paste0(crayon::bold(.x), collapse = "."))
  fields_str <- paste0(fields, collapse = join)

  config_path <- pkgdown_config_path(pkg$src_path)

  if (is.null(config_path)) {
    fields_str
  } else {
    config <- src_path(fs::path_rel(config_path, pkg$src_path))
    paste0(fields_str, " in ", config)
  }
}

check_yaml_has <- function(missing, where, pkg) {
  if (length(missing) == 0) {
    return()
  }

  missing_components <- lapply(missing, function(x) c(where, x))
  missing_fields <- pkgdown_fields(pkg, missing_components)

  abort(paste0(
    "Can't find component", if (length(missing) > 1) "s", " ",
    missing_fields, "."
  ))
}

#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}
