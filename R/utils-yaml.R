check_yaml_has <- function(missing, where, pkg) {
  if (length(missing) == 0) {
    return()
  }

  missing_components <- lapply(missing, function(x) c(where, x))
  missing_fields <- purrr::map_chr(missing_components, pkgdown_field)

  cli::cli_abort(
    "Can't find {cli::qty(missing_fields)} component{?s} {.field {missing_fields}} in {.file {pkgdown_config_relpath(pkg)}}."
  )
}

yaml_character <- function(pkg, where) {
  x <- purrr::pluck(pkg$meta, !!!where)

  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    fld <- pkgdown_field(where)
    cli::cli_abort("{fld} must be a character vector")
  }
}

pkgdown_field <- function(fields) {
  purrr::map_chr(list(fields), ~ paste0(.x, collapse = "."))
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
