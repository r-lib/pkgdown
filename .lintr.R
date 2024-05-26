linters <- list(lintr::undesirable_function_linter(
  fun = c(
    # Base messaging
    "message" = "use cli::cli_inform()",
    "warning" = "use cli::cli_warn()",
    "stop" = "use cli::cli_abort()",
    # rlang messaging
    "inform" = "use cli::cli_inform()",
    "warn" = "use cli::cli_warn()",
    "abort" = "use cli::cli_abort()",
    # older cli
    "cli_alert_danger" = "use cli::cli_inform()",
    "cli_alert_info" = "use cli::cli_inform()",
    "cli_alert_success" = "use cli::cli_inform()",
    "cli_alert_warning" = "use cli::cli_inform()",
    # fs
    "file.path" = "use path()",
    "dir" = "use dir_ls()",
    "dir.create" = "use dir_create()",
    "file.copy" = "use file_copy()",
    "file.create" = "use file_create()",
    "file.exists" = "use file_exists()",
    "file.info" = "use file_info()",
    "normalizePath" = "use path_real()",
    "unlink" = "use file_delete()",
    "basename" = "use path_file()",
    "dirname" = "use path_dir()",
    # i/o
    "readLines" = "use read_lines()",
    "writeLines" = "use write_lines()"
  ),
  symbol_is_undesirable = FALSE
))

exclusions <- list(
  "R/import-standalone-obj-type.R",
  "R/import-standalone-types-check.R",
  "vignettes",
  "tests/testthat/assets"
)