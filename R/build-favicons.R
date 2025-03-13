#' Initialise favicons from package logo
#'
#' @description
#' This function auto-detects the location of your package logo (with the name
#' `logo.svg` (recommended format) or `logo.png`, created with `usethis::use_logo()`)
#' and runs it through the <https://realfavicongenerator.net> API to build a
#' complete set of favicons with different sizes, as needed for modern web usage.
#'
#' You only need to run the function once. The favicon set will be stored in
#' `pkgdown/favicon` and copied by [init_site()] to the relevant location when
#' the website is rebuilt.
#'
#' Once complete, you should add `pkgdown/` to `.Rbuildignore ` to avoid a NOTE
#' during package checking. (`usethis::use_logo()` does this for you!)
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
    cli::cli_abort(c(
      "Can't find package logo PNG or SVG to build favicons.",
      "i" = "See {.fun usethis::use_logo} for more information."
    ))
  }

  if (has_favicons(pkg) && !overwrite) {
    cli::cli_inform(c(
      "Favicons already exist in {.path pkgdown}",
      "i" = "Set {.code overwrite = TRUE} to re-create."
    ))
    return(invisible())
  }

  cli::cli_inform(c(
    i = "Building favicons with {.url https://realfavicongenerator.net}..."
  ))

  logo <- readBin(logo_path, what = "raw", n = file_info(logo_path)$size)
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
  req <- httr2::request("https://realfavicongenerator.net/api/favicon")
  req <- httr2::req_body_json(req, json_request)

  withCallingHandlers(
    resp <- httr2::req_perform(req),
    error = function(e) {
      cli::cli_abort("API request failed.", parent = e)
    }
  )

  content <- httr2::resp_body_json(resp)
  result <- content$favicon_generation_result

  if (!identical(result$result$status, "success")) {
    cli::cli_abort("API request failed.", .internal = TRUE)
  }

  tmp <- withr::local_tempfile()
  req <- httr2::request(result$favicon$package_url)
  resp <- httr2::req_perform(req, tmp)

  withCallingHandlers(
    paths <- utils::unzip(
      tmp,
      exdir = path(pkg$src_path, "pkgdown", "favicon")
    ),
    warning = function(e) {
      cli::cli_abort(
        "Your logo file couldn't be processed and may be corrupt.",
        parent = e
      )
    },
    error = function(e) {
      cli::cli_abort(
        "Your logo file couldn't be processed and may be corrupt.",
        parent = e
      )
    }
  )
  cli::cli_inform(c("v" = "Added {.path {sort(path_file(paths))}}."))

  invisible()
}

copy_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  dir_copy_to(
    src_dir = path(pkg$src_path, "pkgdown", "favicon"),
    src_root = pkg$src_path,
    dst_dir = pkg$dst_path,
    dst_root = pkg$dst_path
  )
}

has_favicons <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  unname(file_exists(path_favicons(pkg)))
}

path_favicons <- function(pkg) {
  path(pkg$src_path, "pkgdown", "favicon")
}
