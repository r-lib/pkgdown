config_check_list <- function(x, names, error_path, error_pkg, error_call = caller_env()) {
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


config_pluck_character <- function(pkg, path, call = caller_env()) {
  check_string(path, allow_empty = FALSE)

  where <- strsplit(path, ".", fixed = TRUE)[[1]]
  x <- purrr::pluck(pkg$meta, !!!where)
  config_check_character(x, path, pkg, call = call)
}
config_check_character <- function(x, path, pkg, call = caller_env()) {
  if (identical(x, list()) || is.null(x)) {
    character()
  } else if (is.character(x)) {
    x
  } else {
    not <- obj_type_friendly(x)
    config_abort(
      pkg,
      "{.field {path}} must be a character vector, not {not}.",
      call = call
    )
  }
}
config_check_string <- function(x, path, pkg, call = caller_env()) {
  if (is_string(x)) {
    x
  } else {
    not <- obj_type_friendly(x)
    config_abort(pkg, "{.field {path}} must be a string, not {not}.", call = call)
  }
}

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
