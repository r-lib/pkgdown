#' Initialise the site
#'
#' This creates the output directory, creates `favicon.ico` from package
#' logo, creates a machine readable description of the site, and sets up
#' assets and extra files.
#'
#' @section Custom CSS/JS:
#' If you want to do minor customisation of your pkgdown site, the easiest
#' way is to add `pkgdown/extra.css` and `pkgdown/extra.js`. These
#' will be automatically copied to `docs/` and inserted into the
#' `<HEAD>` after the default pkgdown CSS and JSS.
#'
#' @section Favicon:
#' If you include you package logo in the standard location of
#' `man/figures/logo.png`, a favicon will be automatically created for
#' you.
#'
#' @inheritParams build_articles
#' @export
init_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  rule("Initialising site")
  dir_create(pkg$dst_path)
  copy_assets(pkg)

  build_site_meta(pkg)
  build_sitemap(pkg)
  build_docsearch_json(pkg)
  build_logo(pkg)

  invisible()
}

copy_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  template <- purrr::pluck(pkg$meta, "template", .default = list())

  # Copy default assets
  if (!identical(template$default_assets, FALSE)) {
    copy_asset_dir(pkg, path_pkgdown("assets"))
  }

  # Copy extras
  copy_asset_dir(pkg, "pkgdown", file_regexp = "^extra")

  # Copy assets from directory
  if (!is.null(template$assets)) {
    copy_asset_dir(pkg, template$assets)
  }

  # Copy assets from package
  if (!is.null(template$package)) {
    copy_asset_dir(pkg, path_package_pkgdown(template$package, "assets"))
  }
}

copy_asset_dir <- function(pkg, from_dir, file_regexp = NULL) {
  from_path <- path_abs(from_dir, pkg$src_path)
  if (!file_exists(from_path)) {
    return(character())
  }

  files <- dir_ls(from_path)
  if (!is.null(file_regexp)) {
    files <- files[grepl(file_regexp, path_file(files))]
  }

  file_copy_to(pkg, files, pkg$dst_path, from_dir = from_path)
}


# Generate site meta data file (available to website viewers)
build_site_meta <- function(pkg = ".") {
  meta <- list(
    pandoc = as.character(rmarkdown::pandoc_version()),
    pkgdown = as.character(utils::packageVersion("pkgdown")),
    pkgdown_sha = utils::packageDescription("pkgdown")$GithubSHA1,
    articles = as.list(pkg$article_index)
  )

  if (!is.null(pkg$meta$url)) {
    meta$urls <- list(
      reference = paste0(pkg$meta$url, "/reference"),
      article = paste0(pkg$meta$url, "/articles")
    )
  }

  path_meta <- path(pkg$dst_path, "pkgdown.yml")
  write_yaml(meta, path_meta)
  invisible()
}
