assemble_ext_assets <- function(pkg) {
  path_assets_yaml <- path_pkgdown(paste0("BS", pkg$bs_version), "assets_external.yaml")
  deps_ext <- yaml::read_yaml(path_assets_yaml)

  purrr::map_chr(deps_ext, ~ {
    # download external resource
    path <- path_deps(pkg, basename(.x$url))
    download.file(.x$url, path, quiet = TRUE, mode = "wb")

    # check file integrity
    sha_size <- as.integer(regmatches(
      .x$integrity,
      regexpr("(?<=^sha)\\d{3}", .x$integrity, perl = TRUE)
    ))
    if (!(sha_size %in% c(256L, 384L, 512L))) {
      cli::cli_abort(paste0(
        "Invalid {.field integrity} value set in {.file ",
        "{path_assets_yaml}}: {.val {(.x$integrity)}} Allowed are only ",
        "SHA-256, SHA-384 and SHA-512."
      ))
    }
    con <- file(path, encoding = "UTF-8")
    hash <- openssl::base64_encode(openssl::sha2(con, sha_size))
    hash_target <- regmatches(
      .x$integrity,
      regexpr("(?<=^sha\\d{3}-).+", .x$integrity, perl = TRUE)
    )

    if (hash != hash_target) {
      cli::cli_abort(paste0(
        "Hash of downloaded {(.x$type)} asset doesn't match {.field ",
        "integrity} value of {.val {(.x$integrity)}}. Asset URL is: {.url ",
        "{(.x$url)}}"
      ))
    }
    .x$url <- fs::path_rel(path, pkg$dst_path)

    # assemble HTML tag
    switch(
      .x$type,
      "stylesheet" = sprintf('<link rel="stylesheet" href="%s" />', .x$url),
      "script" = sprintf('<script src="%s"></script>', .x$url),
      cli::cli_abort("Unknown asset type {.val {.x$type}} defined in {.file path_assets_yaml}.")
    )
  })
}
