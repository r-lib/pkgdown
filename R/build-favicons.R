copy_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  favicons <- path(pkg$src_path, "pkgdown", "favicon")
  if (!dir_exists(favicons))
    return()

  dir_copy_to(pkg, favicons, pkg$dst_path)
}

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
#' @inheritParams as_pkgdown
#' @export
build_favicon <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path)) {
    stop("Can't find package logo.", call. = FALSE)
  }

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

  resp <- httr::POST(
    "https://realfavicongenerator.net/api/favicon",
    body = json_request, encode = "json",
  )
  if (httr::http_error(resp)) {
    stop("API request failed.", call. = FALSE)
  }

  content <- httr::content(resp)
  result <- content$favicon_generation_result

  if (!identical(result$result$status, "success")) {
    stop(
      "API request failed. ", "
      Please submit bug report to <http://github.com/r-lib/pkgdown/issues>",
      call. = FALSE
    )
  }

  tmp <- tempfile()
  on.exit(unlink(tmp))
  result <- httr::GET(result$favicon$package_url, httr::write_disk(tmp))
  utils::unzip(tmp, exdir = path(pkg$src_path, "pkgdown", "favicon"))

  invisible()
}

has_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  file.exists(path(pkg$src_path, "pkgdown", "favicon"))
}

find_logo <- function(path) {

  logo_path <- path(path, "logo.svg")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.svg")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  NULL
}
