#' Initialise site infrastructure
#'
#' @description
#' `init_site()`:
#'
#' * creates the output directory (`docs/`),
#' * generates a machine readable description of the site, used for autolinking,
#' * copies CSS/JS assets and extra files, and
#' * runs `build_favicons()`, if needed.
#'
#' See `vignette("customise")` for the various ways you can customise the
#' display of your site.
#'
#' @section Build-ignored files:
#' We recommend using [usethis::use_pkgdown()] to build-ignore `docs/` and
#' `_pkgdown.yml`. If use another directory, or create the site manually,
#' you'll need to add them to `.Rbuildignore` yourself. A `NOTE` about
#' an unexpected file during `R CMD CHECK` is an indication you have not
#' correctly ignored these files.
#'
#' @inheritParams build_articles
#' @export
init_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  if (is_non_pkgdown_site(pkg$dst_path)) {
    stop(dst_path(pkg$dst_path), " is non-empty and not built by pkgdown", call. = FALSE)
  }

  rule("Initialising site")
  dir_create(pkg$dst_path)

  copy_assets(pkg)
  if (pkg$bs_version > 3) {
    build_bslib(pkg)
  }

  if (has_logo(pkg) && !has_favicons(pkg)) {
    # Building favicons is expensive, so we hopefully only do it once.
    build_favicons(pkg)
  }
  copy_favicons(pkg)
  copy_logo(pkg)

  build_site_meta(pkg)

  invisible()
}

copy_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  template <- purrr::pluck(pkg$meta, "template", .default = list())

  # pkgdown assets
  if (!identical(template$default_assets, FALSE)) {
    copy_asset_dir(pkg, path_pkgdown(paste0("BS", pkg$bs_version), "assets"))
  }

  # manually specified directory: I don't think this is documented
  # and no longer seems important, so I suspect it could be removed
  if (!is.null(template$assets)) {
    copy_asset_dir(pkg, template$assets)
  }

  # package assets
  if (!is.null(template$package)) {
    assets <- path_package_pkgdown(
      "assets",
      package = template$package,
      bs_version = pkg$bs_version
    )
    copy_asset_dir(pkg, assets)
  }

  # extras
  copy_asset_dir(pkg, "pkgdown", file_regexp = "^extra")
  # site assets
  copy_asset_dir(pkg, "pkgdown/assets")

  invisible()
}

copy_asset_dir <- function(pkg, from_dir, file_regexp = NULL) {
  if (length(from_dir) == 0) {
    return(character())
  }
  from_path <- path_abs(from_dir, pkg$src_path)
  if (!file_exists(from_path)) {
    return(character())
  }

  files <- dir_ls(from_path, recurse = TRUE)

  # Remove directories from files
  files <- files[!fs::is_dir(files)]

  if (!is.null(file_regexp)) {
    files <- files[grepl(file_regexp, path_file(files))]
  }
  # Handled in bs_theme()
  files <- files[path_ext(files) != "scss"]

  file_copy_to(pkg, files, pkg$dst_path, from_dir = from_path)
}

timestamp <- function(time = Sys.time()) {
  attr(time, "tzone") <- "UTC"
  strftime(time, "%Y-%m-%dT%H:%MZ", tz = "UTC")
}

# Generate site meta data file (available to website viewers)
build_site_meta <- function(pkg = ".") {
  meta <- site_meta(pkg)

  # Install pkgdown.yml to ./inst if requested,
  install_metadata <- pkg$install_metadata %||% FALSE
  if (install_metadata) {
    path_meta <- path(pkg$src_path, "inst", "pkgdown.yml")

    dir_create(path_dir(path_meta))
    write_yaml(meta, path_meta)
  }

  path_meta <- path(pkg$dst_path, "pkgdown.yml")
  write_yaml(meta, path_meta)
  invisible()
}

site_meta <- function(pkg) {
  article_index <- article_index(pkg)

  meta <- list(
    pandoc = as.character(rmarkdown::pandoc_version()),
    pkgdown = as.character(utils::packageDescription("pkgdown", fields = "Version")),
    pkgdown_sha = utils::packageDescription("pkgdown")$GithubSHA1,
    articles = as.list(article_index),
    last_built = timestamp()
  )

  if (!is.null(pkg$meta$url)) {
    meta$urls <- list(
      reference = paste0(pkg$meta$url, "/reference"),
      article = paste0(pkg$meta$url, "/articles")
    )
  }

  print_yaml(meta)
}

is_non_pkgdown_site <- function(dst_path) {
  if (!dir_exists(dst_path)) {
    return(FALSE)
  }

  top_level <- dir_ls(dst_path)
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev", "deps")]

  length(top_level) >= 1 && !"pkgdown.yml" %in% path_file(top_level)
}
