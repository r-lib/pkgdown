check_yaml_has <- function(missing, where, pkg) {
  if (length(missing) == 0) {
    return()
  }

  missing_components <- lapply(missing, function(x) c(where, x))
  msg_flds <- pkgdown_field(pkg, missing_components, fmt = TRUE, cfg = TRUE)

  cli::cli_abort(
    paste0("Can't find {cli::qty(missing)} component{?s} ", msg_flds, "."),
    call = caller_env()
  )
}

yaml_character <- function(pkg, where) {
  x <- purrr::pluck(pkg$meta, !!!where)

  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    fld <- pkgdown_field(pkg, where, fmt = TRUE)
    cli::cli_abort(
      paste0(fld, " must be a character vector."),
      call = caller_env()
    )
  }
}

pkgdown_field <- function(pkg, fields, cfg = FALSE, fmt = FALSE) {

  if (!is.list(fields)) fields <- list(fields)

  flds <- purrr::map_chr(fields, ~ paste0(.x, collapse = "."))
  if (fmt) {
    flds <- paste0("{.field ", flds, "}")
  }

  if (cfg) {
    config_path <- pkgdown_config_relpath(pkg)
    if (fmt) {
      config_path <- paste0("{.file ", config_path, "}")
    }

    paste0(flds, " in ", config_path)
  } else {

    flds
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
