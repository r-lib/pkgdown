config_pluck <- function(pkg, path, default = NULL) {
  check_string(path, allow_empty = FALSE, .internal = TRUE)

  where <- strsplit(path, ".", fixed = TRUE)[[1]]
  purrr::pluck(pkg$meta, !!!where, .default = default)
}

config_pluck_character <- function(pkg,
                                   path,
                                   default = character(),
                                   call = caller_env()) {
  x <- config_pluck(pkg, path, default)
  config_check_character(
    x,
    error_path = path,
    error_pkg = pkg,
    error_call = call
  )
}

# checks ---------------------------------------------------------------------

config_check_character <- function(x,
                                   error_pkg,
                                   error_path,
                                   error_call = caller_env()) {
  if (is.character(x)) {
    x
  } else if (identical(x, list())) {
    character()
  } else {
    not <- obj_type_friendly(x)
    config_abort(
      error_pkg,
      "{.field {error_path}} must be a character vector, not {not}.",
      call = error_call
    )
  }
}

config_check_string <- function(x,
                                error_pkg,
                                error_path,
                                error_call = caller_env()) {
  if (is_string(x)) {
    x
  } else {
    not <- obj_type_friendly(x)
    config_abort(
      error_pkg,
      "{.field {error_path}} must be a string, not {not}.",
      call = error_call
    )
  }
}

config_check_list <- function(x,
                              names = NULL,
                              error_pkg,
                              error_path,
                              error_call = caller_env()) {
  if (is_list(x)) {
    if (!is.null(names) && !all(has_name(x, names))) {
      missing <- setdiff(names, names(x))
      config_abort(
        error_pkg,
        c(
          "{.field {error_path}} must have components {.str {names}}.",
          "{length(missing)} missing component{?s}: {.str {missing}}."
        ),
        call = error_call
      )
    } else {
      x
    }
  } else {
    not <- obj_type_friendly(x)
    config_abort(
      error_pkg,
      "{.field {error_path}} must be a list, not {not}.",
      call = error_call
    )
  }
}

# generic error ---------------------------------------------------------------

config_abort <- function(pkg,
                         message,
                         ...,
                         call = caller_env(),
                         .envir = caller_env()) {

  edit <- cli::format_inline("Edit {config_path(pkg)} to fix the problem.")

  cli::cli_abort(
    c(message, i = edit),
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
