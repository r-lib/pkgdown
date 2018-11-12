build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path))
    return()

  file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))

  cat_line("Creating ", dst_path("favicon.ico"))

  logo <- readBin(logo_path, what = "raw", n = fs::file_info(logo_path)$size)

  logo_base64 <- openssl::base64_encode(logo)

  json_request <- list(
    "favicon_generation" = list(
      "api_key" = "87d5cd739b05c00416c4a19cd14a8bb5632ea563",
      "master_picture" = list(
        "type"= "inline",
        "content"= logo_base64
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

  request <- httr::POST("https://realfavicongenerator.net/api/favicon",
                        body = json_request, encode = "json")

  api_answer <- httr::content(request)

  if (identical(api_answer$favicon_generation_result$result$status, "success")) {

    result <- httr::GET(api_answer$favicon_generation_result$favicon$package_url,
                        httr::write_disk(path(pkg$dst_path, "favicon_set.zip"), overwrite = TRUE))

    unzip(path(pkg$dst_path, "favicon_set.zip"), exdir = pkg$dst_path)

    unlink(path(pkg$dst_path, "favicon_set.zip"))

  }
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
