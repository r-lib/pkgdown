check_yaml_has <- function(missing, where, pkg, call = caller_env()) {
  if (length(missing) == 0) {
    return()
  }

  missing_components <- lapply(missing, function(x) c(where, x))
  msg_flds <- purrr::map_chr(missing_components, paste, collapse = ".")

  config_abort(
    pkg, 
    "Can't find {cli::qty(missing)} component{?s} {.field {msg_flds}}.",
    call = call
  )
}

config_pluck_character <- function(pkg, path, call = caller_env()) {
  check_string(path, allow_empty = FALSE)

  where <- strsplit(path, ".", fixed = TRUE)[[1]]
  x <- purrr::pluck(pkg$meta, !!!where)

  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    not <- obj_type_friendly(x)
    config_abort(
      pkg,
      "{.field {path}} must be a character vector, {not}.",
      call = call
    )
  }
}

config_abort <- function(pkg,
                         message,
                         ...,
                         call = caller_env(),
                         .envir = caller_env()) {
  cli::cli_abort(
    c(
      message,
      i = "Edit {config_path(pkg)} to fix the problem."
    ),
    ...,
    call = call,
    .envir = .envir
  )
}

config_path <- function(pkg) {
  config <- pkgdown_config_path(pkg$src_path)
  if (is.null(config)) {
    cli::cli_abort("Can't find {.file _pkgdown.yml}.", .internal = TRUE)
  }
  cli::style_hyperlink(fs::path_file(config), paste0("file://", config))
}
