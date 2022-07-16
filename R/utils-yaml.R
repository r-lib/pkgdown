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

yaml_character <- function(pkg, where) {
  x <- purrr::pluck(pkg$meta, !!!where)

  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    abort(paste0(pkgdown_field(pkg, where), " must be a character vector"))
  }
}

pkgdown_field <- function(pkg, field) {
  pkgdown_fields(pkg, list(field))
}

pkgdown_fields <- function(pkg, fields, join = ", ") {
  fields <- purrr::map_chr(fields, ~ paste0(cli::style_bold(.x), collapse = "."))
  fields_str <- paste0(fields, collapse = join)

  config_path <- pkgdown_config_path(pkg$src_path)

  if (is.null(config_path)) {
    fields_str
  } else {
    config <- src_path(fs::path_rel(config_path, pkg$src_path))
    paste0(fields_str, " in ", config)
  }
}

# print helper ------------------------------------------------------------

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}
#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

# IO ----------------------------------------------------------------------

write_yaml <- function(x, path) {
  write_lines(yaml::as.yaml(x), path = path)
}
