#' Initialise site infrastructure
#'
#' This creates the output directory (`docs/`), a machine readable description
#' of the site, and copies CSS/JS assets and extra files.
#'
#' @section Build-ignored files:
#' We recommend using [usethis::use_pkgdown()] to build-ignore `docs/` and
#' `_pkgdown.yml`. If use another directory, or create the site manually,
#' you'll need to add them to `.Rbuildignore` yourself. A `NOTE` about
#' an unexpected file during `R CMD CHECK` is an indication you have not
#' correctly ignored these files.
#'
#' @section Custom CSS/JS:
#' If you want to do minor customisation of your pkgdown site, the easiest
#' way is to add `pkgdown/extra.css` and `pkgdown/extra.js`. These
#' will be automatically copied to `docs/` and inserted into the
#' `<HEAD>` after the default pkgdown CSS and JS.
#'
#' @section Favicon:
#' Favicons are built automatically from a logo PNG or SVG by [init_site()] and
#' copied to `pkgdown/favicon`.
#'
#' @section 404:
#' pkgdown creates a default 404 page (`404.html`). You can customize 404
#' page content using `.github/404.md`.
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

  if (has_favicons(pkg)) {
    copy_favicons(pkg)
  } else if (has_logo(pkg)) {
    build_favicons(pkg)
    copy_favicons(pkg)
  }

  build_site_meta(pkg)
  build_sitemap(pkg)
  build_docsearch_json(pkg)
  build_logo(pkg)
  build_404(pkg)

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

  files <- dir_ls(from_path, recurse = TRUE)

  # Remove directories from files
  files <- files[!fs::is_dir(files)]

  if (!is.null(file_regexp)) {
    files <- files[grepl(file_regexp, path_file(files))]
  }

  file_copy_to(pkg, files, pkg$dst_path, from_dir = from_path)
}

timestamp <- function() {
  x <- Sys.time()
  attr(x, "tzone") <- "UTC"
  strftime(x, "%Y-%m-%dT%H:%MZ", tz = "UTC")
}

# Generate site meta data file (available to website viewers)
build_site_meta <- function(pkg = ".") {
  meta <- list(
    pandoc = as.character(rmarkdown::pandoc_version()),
    pkgdown = as.character(utils::packageDescription("pkgdown", fields = "Version")),
    pkgdown_sha = utils::packageDescription("pkgdown")$GithubSHA1,
    articles = as.list(pkg$article_index),
    last_built = timestamp()
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

is_non_pkgdown_site <- function(dst_path) {
  if (!dir_exists(dst_path)) {
    return(FALSE)
  }

  top_level <- dir_ls(dst_path)
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev")]

  length(top_level) >= 1 && !"pkgdown.yml" %in% path_file(top_level)
}
