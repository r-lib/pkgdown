config_pluck <- function(pkg, path, default = NULL) {
  check_string(path, allow_empty = FALSE, .internal = TRUE)

  where <- strsplit(path, ".", fixed = TRUE)[[1]]
  purrr::pluck(pkg$meta, !!!where, .default = default)
}

config_pluck_list <- function(pkg,
                              path,
                              has_names = NULL,
                              default = NULL,
                              call = caller_env()) {
  check_string(path, allow_empty = FALSE, .internal = TRUE)

  x <- config_pluck(pkg, path, default)
  config_check_list(
    x,
    has_names = has_names,
    error_path = path,
    error_pkg = pkg,
    error_call = call
  )
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
                                default = NULL,
                                call = caller_env()) {
  x <- config_pluck(pkg, path, default)
  config_check_string(
    x,
    error_path = path,
    error_pkg = pkg,
    error_call = call
  )
}

config_pluck_markdown_inline <- function(pkg,
                                         path,
                                         default = NULL,
                                         call = caller_env()) {
  
  text <- config_pluck_string(pkg, path, default, call = call)
  markdown_text_inline(
    text,
    error_path = path,
    error_pkg = pkg,
    error_call = call
  )
}

config_pluck_markdown_block <- function(pkg,
                                        path,
                                        default = NULL,
                                        call = caller_env()) {
  
  text <- config_pluck_string(pkg, path, default, call = call)
  markdown_text_block(text)
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

config_pluck_number_whole <- function(pkg,
                                      path,
                                      default = NULL,
                                      call = caller_env()) {
  x <- config_pluck(pkg, path, default)
  config_check_number_whole(
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
  if (is.character(x) || is.null(x)) {
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

  if (is_string(x) || is.null(x)) {
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

  if (is_bool(x) || is.null(x)) {
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

config_check_number_whole <- function(x,
                                      error_pkg,
                                      error_path,
                                      error_call = caller_env()) {

  is_whole <- (0 == (exit_code <- .standalone_types_check_dot_call(
    ffi_standalone_check_number_1.0.7,
    x,
    allow_decimal = FALSE,
    min = NULL,
    max = NULL,
    allow_infinite = FALSE,
    allow_na = FALSE,
    allow_null = TRUE
  )))

  if (is_whole) {
    x
  } else {
    config_abort_type(
      must_be = "a whole number",
      not = x,
      error_pkg = error_pkg,
      error_path = error_path,
      error_call = error_call
    )
  }
}

config_check_list <- function(x,
                              has_names = NULL,
                              error_pkg,
                              error_path,
                              error_call = caller_env()) {
  if (is_list(x) || is.null(x)) {
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

config_abort_type <- function(must_be, not, error_pkg, error_path, error_call) {
  not_str <- obj_type_friendly(not)
  config_abort(
    error_pkg,
    "{.field {error_path}} must be {must_be}, not {not_str}.",
    call = error_call
  )
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
