find_template <- function(type, name, ext = ".html", pkg = ".") {
  pkg <- as_pkgdown(pkg)

  paths <- template_candidates(type = type, name = name, ext = ext, pkg = pkg)

  existing <- paths[file_exists(paths)]

  if (length(existing) == 0) {
    tname <- paste0(type, "-", name)
    cli::cli_abort(
      "Can't find template for {.val {tname}}.",
      call = caller_env()
    )
  }
  existing[[1]]
}

# Used for testing
read_template_html <- function(type, name, pkg = list()) {
  if (is_list(pkg)) {
    # promote to a shell "pkgdown" object so we don't need a complete pkg
    class(pkg) <- "pkgdown"
  }
  path <- find_template(type = type, name = name, pkg = pkg)
  xml2::read_html(path)
}

template_candidates <- function(type, name, ext = ".html", pkg = list()) {
  paths <- c(
    path(pkg$src_path, "pkgdown", "templates"),
    templates_dir(pkg),
    path_pkgdown(paste0("BS", pkg$bs_version), "templates")
  )
  names <- c(paste0(type, "-", name, ext), paste0(type, ext))
  all <- expand.grid(paths, names)

  path(all[[1]], all[[2]])
}

# Find directory where custom templates might live:
# * path supplied in `template.path`
# * package supplied in `template.package`
# * templates in package itself
templates_dir <- function(pkg = list()) {
  template <- pkg$meta$template

  if (!is.null(template$path)) {
    # Directory specified in yaml doesn't exist, so eagerly error
    if (!dir_exists(template$path)) {
      cli::cli_abort(
        "Can't find templates path: {src_path(template$path)}",
        call = caller_env()
      )
    }
    path_abs(template$path, start = pkg$src_path)
  } else if (!is.null(template$package)) {
    path_package_pkgdown("templates", package = template$package, bs_version = pkg$bs_version)
  } else {
    path(pkg$src_path, "pkgdown", "templates")
  }
}
