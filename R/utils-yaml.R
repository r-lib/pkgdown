check_yaml_has <- function(missing, where, pkg, call = caller_env()) {
  if (length(missing) == 0) {
    return()
  }

  missing_components <- lapply(missing, function(x) c(where, x))
  msg_flds <- pkgdown_field(missing_components)

  cli::cli_abort(c(
    "Can't find {cli::qty(missing)} component{?s} {.field {msg_flds}}.",
    i = "Edit {config_path(pkg)} to define {cli::qty(missing)} {?it/them}."
    ),
    call = call
  )
}

yaml_character <- function(pkg, where) {
  x <- purrr::pluck(pkg$meta, !!!where)

  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    fld <- pkgdown_field(where, fmt = TRUE)
    cli::cli_abort(
      paste0(fld, " must be a character vector."),
      call = caller_env()
    )
  }
}

pkgdown_field <- function(fields, fmt = FALSE) {
  if (!is.list(fields)) fields <- list(fields)

  flds <- purrr::map_chr(fields, ~ paste0(.x, collapse = "."))
  if (fmt) {
    flds <- paste0("{.field ", flds, "}")
  }
  flds
}

config_path <- function(pkg) {
  config <- pkgdown_config_path(pkg$src_path)
  if (is.null(config)) {
    cli::cli_abort("Can't find {.file _pkgdown.yml}.", .internal = TRUE)
  }
  cli::style_hyperlink(fs::path_file(config), paste0("file://", config))
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
