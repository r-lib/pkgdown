build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path))
    return()

  file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))

  cat_line("Creating ", dst_path("favicon.ico"))

  logo_string <- readBin(logo_path, what = "raw", n = 99999) %>%
    openssl::base64_encode()

  template <- find_template("config", "favicon", ext = ".json")

  data <- list(
    url = pkg$meta$url,
    logo_string = logo_string
  )

  json_favicon <- render_template(template, data)

  request <- httr::POST("https://realfavicongenerator.net/api/favicon",
                        body = json_favicon, encode = "json")

  api_answer <- httr::content(request)

  if (api_answer$favicon_generation_result$result$status == "success") {

    result <- httr::GET(api_answer$favicon_generation_result$favicon$package_url)

    writeBin(httr::content(result), path(pkg$dst_path, "favicon_set.zip"))

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
