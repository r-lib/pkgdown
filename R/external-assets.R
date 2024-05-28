assemble_ext_assets <- function(pkg) {
  path_assets_yaml <- path_pkgdown(paste0("BS", pkg$bs_version), "assets_external.yaml")
  deps_ext <- yaml::read_yaml(path_assets_yaml)

  purrr::map_chr(deps_ext, ~ {
    path <- path_deps(pkg, basename(.x$url))
    download.file(.x$url, path, quiet = TRUE, mode = "wb")
    check_integrity(path, .x$integrity)

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

check_integrity <- function(path, integrity) {
  parsed <- parse_integrity(integrity)
  if (!parsed$size %in% c(256L, 384L, 512L)) {
    cli::cli_abort(
      "{.field integrity} must use SHA-256, SHA-384, or SHA-512",
      .internal = TRUE
    )
  }

  hash <- compute_hash(path, parsed$size)
  if (hash != parsed$hash) {
    cli::cli_abort(
      "Downloaded asset does not match known integrity",
      .internal = TRUE
    )
  }

  invisible()
}

compute_hash <- function(path, size) {
  con <- file(path, encoding = "UTF-8")
  openssl::base64_encode(openssl::sha2(con, size))
}
 
parse_integrity <- function(x) {
  size <- as.integer(regmatches(x, regexpr("(?<=^sha)\\d{3}", x, perl = TRUE)))
  hash <- regmatches(x, regexpr("(?<=^sha\\d{3}-).+", x, perl = TRUE))

  list(size = size, hash = hash)
}
