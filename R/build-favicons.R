#' Create favicons from package logo
#'
#' This function auto-detects the location of your package logo (with the name
#' `logo.svg` (recommended format) or `logo.png`) and runs it through the
#' <https://realfavicongenerator.net> API to build a complete set of favicons
#' with different sizes, as needed for modern web usage.
#'
#' You only need to run the function once. The favicon set will be stored in
#' `pkgdown/favicon` and copied by [init_site()] to the relevant location when
#' the website is rebuilt.
#'
#' Once complete, you should add `pkgdown/` to `.Rbuildignore ` to avoid a NOTE
#' during package checking.
#'
#' @inheritParams as_pkgdown
#' @param overwrite If `TRUE`, re-create favicons from package logo.
#' @export
build_favicons <- function(pkg = ".", overwrite = FALSE) {
  rlang::check_installed("openssl")
  pkg <- as_pkgdown(pkg)

  cli::cli_rule("Building favicons")

  logo_path <- find_logo(pkg$src_path)

  if (is.null(logo_path)) {
    cli::cli_abort(
      "Can't find package logo PNG or SVG to build favicons."
    )
  }

  if (has_favicons(pkg) && !overwrite) {
    cli::cli_inform(c(
      "Favicons already exist in {.path pkgdown}",
      "i" = "Set {.code overwrite = TRUE} to re-create."
    ))
    return(invisible())
  }

  cli::cli_inform("Building favicons with {.url https://realfavicongenerator.net} ...")

  logo <- readBin(logo_path, what = "raw", n = fs::file_info(logo_path)$size)

  json_request <- list(
    "favicon_generation" = list(
      "api_key" = "87d5cd739b05c00416c4a19cd14a8bb5632ea563",
      "master_picture" = list(
        "type" = "inline",
        "content" = openssl::base64_encode(logo)
      ),
      "favicon_design" = list(
        "desktop_browser" = list(),
        "ios" = list(
          "picture_aspect" = "no_change",
          "assets" = list(
            "ios6_and_prior_icons" = FALSE,
            "ios7_and_later_icons" = TRUE,
            "precomposed_icons" = FALSE,
            "declare_only_default_icon" = TRUE
          )
        )
      )
    )
  )

  resp <- httr::RETRY(
    "POST",
    "https://realfavicongenerator.net/api/favicon",
    body = json_request,
    encode = "json",
    quiet = TRUE
  )
  if (httr::http_error(resp)) {
    cli::cli_abort("API request failed.", call = caller_env())
  }

  content <- httr::content(resp)
  result <- content$favicon_generation_result

  if (!identical(result$result$status, "success")) {
    cli::cli_abort("API request failed.", .internal = TRUE)
  }

  tmp <- tempfile()
  on.exit(unlink(tmp))
  result <- httr::RETRY(
    "GET",
    result$favicon$package_url,
    httr::write_disk(tmp),
    quiet = TRUE
  )

  tryCatch({
    utils::unzip(tmp, exdir = path(pkg$src_path, "pkgdown", "favicon"))
  },
  warning = function(e) {
    cli::cli_abort("Your logo file couldn't be processed and may be corrupt.", parent = e)
  },
  error = function(e) {
    cli::cli_abort("Your logo file couldn't be processed and may be corrupt.", parent = e)
  })

  invisible()
}

copy_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  favicons <- path(pkg$src_path, "pkgdown", "favicon")
  if (!dir_exists(favicons))
    return()

  dir_copy_to(pkg, favicons, pkg$dst_path)
}

has_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  file.exists(path(pkg$src_path, "pkgdown", "favicon"))
}
