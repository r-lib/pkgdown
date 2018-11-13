build_logo <- function(pkg = ".") {

  pkg <- as_pkgdown(pkg)

  if (!dir.exists(path(pkg$src_path, "pkgdown", "favicon")) {
    return()
  }

  dir_copy_to(pkg, path(pkg$src_path, "pkgdown", "favicon"), pkg$dst_path)

}

build_favicon <- function(pkg = ".") {

  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)

  if (is.null(logo_path)) {
    stop("Package logo could not be found. Aborting favicon creation.",
         call. = FALSE)
  }

  message("Creating favicon set.")

  logo <- readBin(logo_path, what = "raw", n = fs::file_info(logo_path)$size)

  json_request <- list(
    "favicon_generation" = list(
      "api_key" = "87d5cd739b05c00416c4a19cd14a8bb5632ea563",
      "master_picture" = list(
        "type"= "inline",
        "content"= openssl::base64_encode(logo)
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

  # It may take some time to generate the whole favicon set so we need to set
  # a high timeout value.
  request <- httr::POST("https://realfavicongenerator.net/api/favicon",
                        body = json_request, encode = "json",
                        httr::timeout(10000)
                        )

  if (httr::http_error(request)) {
    stop("The API could not be reached. Please check your internet connection ",
         "or try again later.",
         call. = FALSE
         )
  }

  api_answer <- httr::content(request)

  if (!identical(api_answer$favicon_generation_result$result$status, "success")) {
    stop("API request failed: please check that you are using supported file ",
         "formats",
         call. = FALSE
    )
  }

  tmp <- tempfile()

  result <- httr::GET(api_answer$favicon_generation_result$favicon$package_url,
                      httr::write_disk(tmp)
                      )

  utils::unzip(tmp, exdir = path(pkg$src_path, "pkgdown", "favicon"))

  unlink(tmp)

}


find_logo <- function(path) {
  logo_path <- path(path, "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  NULL
}
