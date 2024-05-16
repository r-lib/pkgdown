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

config_pluck_string <- function(pkg,
                                path,
                                default = "",
                                call = caller_env()) {
  x <- config_pluck(pkg, path, default)
  config_check_string(
    x,
    error_path = path,
    error_pkg = pkg,
    error_call = call
  )
}

config_pluck_bool <- function(pkg,
                              path,
                              default = NULL,
                              call = caller_env()) {
  x <- config_pluck(pkg, path, default)
  config_check_bool(
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
    config_abort_type(
      must_be = "a character vector",
      not = x,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
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
    config_abort_type(
      must_be = "a string",
      not = x,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }
}

config_check_bool <- function(x,
                              error_pkg,
                              error_path,
                              error_call = caller_env()) {

  if (is_bool(x)) {
    x
  } else {
    config_abort_type(
      must_be = "true or false",
      not = x,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }
}


config_abort_type <- function(must_be, not, error_pkg, error_path, error_call) {
  not_str <- obj_type_friendly(not)
  config_abort(
    error_pkg,
    "{.field {error_path}} must be {must_be}, not {not_str}.",
    call = error_call
  )

}

config_check_list <- function(x,
                              has_names = NULL,
                              error_pkg,
                              error_path,
                              error_call = caller_env()) {
  if (is.null(x)) {
    return()
  } else if (is_list(x)) {
    if (!is.null(has_names) && !all(has_name(x, has_names))) {
      missing <- setdiff(has_names, names(x))
      config_abort(
        error_pkg,
        c(
          "{.field {error_path}} must have {cli::qty(has_names)} component{?s} {.str {has_names}}.",
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
  # Not all projects necessary have a _pkgdown.yml (#2542)
  config <- pkgdown_config_path(pkg$src_path) %||% "_pkgdown.yml"
  cli::style_hyperlink(path_file(config), paste0("file://", config))  
}
