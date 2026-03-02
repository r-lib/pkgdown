#' Open site in browser
#'
#' `preview_site()` opens your pkgdown site in your browser, served via a
#' local HTTP server. This enables dynamic features such as search to work
#' correctly in preview.
#'
#' @seealso [stop_preview()] to stop the server.
#' @inheritParams build_article
#' @param path Path relative to destination
#' @export
preview_site <- function(pkg = ".", path = ".", preview = TRUE) {
  pkg <- as_pkgdown(pkg)
  abs_path <- local_path(pkg, path)

  check_bool(preview, allow_na = TRUE)
  if (is.na(preview)) {
    preview <- interactive() && !is_testing()
  }

  if (preview) {
    root <- pkg$dst_path

    if (is.null(the$server) || !identical(the$server_root, root)) {
      the$server <- nanonext::http_server(
        url = "http://127.0.0.1:0",
        handlers = nanonext::handler_directory("/", root)
      )
      the$server$start()
      the$server_root <- root
    }

    cli::cli_inform(c(i = "Previewing site"))
    url <- paste0(the$server$url, "/", if (path != ".") path)
    utils::browseURL(url)
  }

  invisible()
}

#' Stop HTTP preview
#'
#' Stops the HTTP server started by [preview_site()], if active. This can be
#' called manually, but is not strictly necessary as the server is
#' automatically stopped when previewing a new site or ending the R session.
#'
#' @export
#' @keywords internal
stop_preview <- function() {
  if (!is.null(the$server)) {
    the$server$close()
    the$server <- NULL
    the$server_root <- NULL
    cli::cli_inform(c(i = "Stopped preview"))
  }

  invisible()
}

local_path <- function(pkg, path, call = caller_env()) {
  check_string(path, call = call)

  abs_path <- path_abs(path, pkg$dst_path)
  if (!file_exists(abs_path)) {
    cli::cli_abort("Can't find file {.path {path}}.", call = call)
  }

  abs_path
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
