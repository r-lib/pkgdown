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

  file_copy_to(pkg, data_assets(pkg))
  file_copy_to(pkg, data_extras(pkg))

  build_site_meta(pkg)
  build_logo(pkg)

  invisible()
}

data_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  template <- pkg$meta[["template"]]

  if (!is.null(template$assets)) {
    path <- path_rel(pkg$src_path, template$assets)
    if (!file_exists(path))
      stop("Can not find asset path ", src_path(path), call. = FALSE)

  } else if (!is.null(template$package)) {
    path <- path_package_pkgdown(template$package, "assets")
  } else {
    path <- character()
  }

  if (!identical(template$default_assets, FALSE)) {
    path <- c(path, path_pkgdown("assets"))
  }

  dir(path, full.names = TRUE)
}

data_extras <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  pkgdown <- path(pkg$src_path, "pkgdown")
  if (!dir_exists(pkgdown)) {
    return(character())
  }

  all <- dir_ls(pkgdown)
  extra <- grepl("^extra", path_file(all))
  all[extra]
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
