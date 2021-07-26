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
  create_bs_assets(pkg)

  if (has_favicons(pkg)) {
    copy_favicons(pkg)
  } else if (has_logo(pkg)) {
    build_favicons(pkg)
    copy_favicons(pkg)
  }

  build_site_meta(pkg)
  build_logo(pkg)
  if (!pkg$development$in_dev) {
    build_404(pkg)
  }

  invisible()
}

copy_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  template <- purrr::pluck(pkg$meta, "template", .default = list())

  # Copy logo
  if (pkg$has_logo) {
    file.copy(
      find_logo(pkg$src_path),
      file.path(pkg$dst_path, "package-logo.png")
    )
  }

  # Copy default assets
  if (!identical(template$default_assets, FALSE)) {
    copy_asset_dir(pkg, path_pkgdown("assets", paste0("BS", pkg$bs_version)))
  }

  # Copy extras
  copy_asset_dir(pkg, "pkgdown", file_regexp = "^extra")

  # Copy assets from directory
  if (!is.null(template$assets)) {
    copy_asset_dir(pkg, template$assets)
  } else {
    # default directory
    copy_asset_dir(pkg, file.path("pkgdown", "assets"))
  }

  # Copy assets from package
  if (!is.null(template$package)) {
    assets <- path_package_pkgdown(
      template$package,
      bs_version = get_bs_version(pkg),
      "assets"
    )

    copy_asset_dir(pkg, assets)
  }
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
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev")]

  length(top_level) >= 1 && !"pkgdown.yml" %in% path_file(top_level)
}

create_bs_assets <- function(pkg) {
  rlang::check_installed("htmltools")

  # theme variables from configuration
  bs_version <- pkg$bs_version
  bootswatch_theme <- pkg$meta[["template"]]$bootswatch %||%
    pkg$meta[["template"]]$params$bootswatch %||%
    NULL

  check_bootswatch_theme(bootswatch_theme, bs_version, pkg)

  # first, defaults from bslib
  bs_theme <- bslib::bs_theme(version = bs_version, bootswatch = bootswatch_theme)
  # then, defaults from pkgdown
  bs_theme <- bslib::bs_add_variables(bs_theme, !!!pkgdown_bslib_defaults())
  # last, user customizations
  if (!is.null(pkg$meta$template$bslib)) {
    bs_theme <- bslib::bs_add_variables(bs_theme, !!!pkg$meta$template$bslib)
  }

  # add rules specific to pkgdown
  pkgdown_sass <- path_pkgdown("css", paste0("BS", bs_version), "pkgdown.scss")
  code_sass <- path_pkgdown("css", paste0("BS", bs_version), "syntax-highlighting.scss")
  pkgdown_css <- sass::sass_partial(
    list(
      sass::sass_file(pkgdown_sass),
      sass::sass_file(code_sass)
    ),
    bs_theme
  )
  bs_theme <- bslib::bs_add_rules(bs_theme, pkgdown_css)

  deps <- bslib::bs_theme_dependencies(bs_theme)
  # Add other dependencies - TODO: more of those?
  # Even font awesome had a too old version in R Markdown (no ORCID)

  # Dependencies files end up at the website root in a deps folder
  deps <- lapply(deps, htmltools::copyDependencyToDir, file.path(pkg$dst_path, "deps"))

  # Function needed for indicating where that deps folder is compared to here
  transform_path <- function(x) {
    # At the time this function is called
    # html::renderDependencies() has already encoded x
    # with the default htmltools::urlEncodePath()
    x <- sub(htmltools::urlEncodePath(pkg$dst_path), "", x)

   sub("/", "", x)

  }

  # Tags ready to be added in heads
  tags <- htmltools::renderDependencies(
    deps,
    srcType = "file",
    hrefFilter = transform_path
  )
  # save tags that will be re-used and tweaked depending on page depth
  write_lines(tags, data_deps_path(pkg))

}


check_bootswatch_theme <- function(bootswatch_theme, bs_version, pkg) {
  if (is.null(bootswatch_theme)) {
    return(invisible())
  }

  if (bootswatch_theme %in% bslib::bootswatch_themes(bs_version)) {
    return(invisible())
  }

  abort(
    sprintf(
      "Can't find Bootswatch theme '%s' (%s) for Bootstrap version '%s' (%s).",
      bootswatch_theme,
      pkgdown_field(pkg = pkg, "template", "bootswatch"),
      bs_version,
      pkgdown_field(pkg = pkg, "template", "bootstrap")
    )
  )
}

data_deps_path <- function(pkg) {
  file.path(pkg$dst_path, "deps", "data-deps.txt")
}

pkgdown_bslib_defaults <- function() {
  list(
    `navbar-nav-link-padding-x` = "1rem !default",
    `primary` = "#0054AD !default",
    `secondary` = "#e9ecef !default",
    `navbar-bg` = "#f8f9fa !default",
    `border-width` = "1px !default",
    `code-bg` = "#f8f8f8 !default",
    `code-color` = "#333 !default",
    `fu-color` = "#4758AB !default",
    `border-radius` = "1rem !default",
    `navbar-light-color` = "rgba(color-contrast($navbar-bg), 0.8) !default",
    `navbar-light-hover-color` = "rgba(color-contrast($navbar-bg), 0.9) !default"
  )
}
