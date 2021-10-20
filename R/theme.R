build_bslib <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  bs_theme <- bs_theme(pkg)

  deps <- bslib::bs_theme_dependencies(bs_theme)
  deps <- lapply(deps, htmltools::copyDependencyToDir, file.path(pkg$dst_path, "deps"))
  deps <- lapply(deps, htmltools::makeDependencyRelative, pkg$dst_path)

  head <- htmltools::renderDependencies(deps, srcType = "file")
  write_lines(head, data_deps_path(pkg))
}

data_deps <- function(pkg, depth) {
  if (!file.exists(data_deps_path(pkg))) {
    abort("Run pkgdown::init_site() first.")
  }

  deps_path <- paste0(up_path(depth), "deps")

  data_deps <- read_lines(data_deps_path(pkg))
  data_deps <- gsub('src="deps', sprintf('src="%s', deps_path), data_deps)
  data_deps <- gsub('href="deps', sprintf('href="%s', deps_path), data_deps)

  paste0(data_deps, collapse = "")
}

data_deps_path <- function(pkg) {
  file.path(pkg$dst_path, "deps", "data-deps.txt")
}

bs_theme <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  theme <- get_bootswatch_theme(pkg)
  theme <- check_bootswatch_theme(theme, pkg$bs_version, pkg)

  bs_theme <- exec(bslib::bs_theme,
    version = pkg$bs_version,
    bootswatch = theme,
    !!!pkg$meta$template$bslib
  )
  # Drop bs3 compat files added for shiny/RMarkdown
  bs_theme <- bslib::bs_remove(bs_theme, "bs3compat")

  # Add additional pkgdown rules
  rules <- bs_theme_rules(pkg)
  files <- lapply(rules, sass::sass_file)
  bs_theme <- bslib::bs_add_rules(bs_theme, files)

  bs_theme
}

bs_theme_rules <- function(pkg) {
  paths <- path_pkgdown("BS5", "assets", "pkgdown.scss")

  theme <- purrr::pluck(pkg, "meta", "template", "theme", .default = "arrow-light")
  theme_path <- path_pkgdown("highlight-styles", paste0(theme, ".scss"))
  if (!file_exists(theme_path)) {
    abort(c(
      paste0("Unknown theme '", theme, "'"),
      i = paste0("Valid themes are: ", paste0(highlight_styles(), collapse = ", "))
    ))
  }
  paths <- c(paths, theme_path)

  package <- purrr::pluck(pkg, "meta", "template", "package")
  if (!is.null(package)) {
    package_extra <- path_package_pkgdown(
      "extra.scss",
      package = package,
      bs_version = pkg$bs_version
    )
    if (file_exists(package_extra)) {
      paths <- c(paths, package_extra)
    }
  }

  # Also look in site supplied
  site_extra <- path(pkg$src_path, "pkgdown", "extra.scss")
  if (file_exists(site_extra)) {
    paths <- c(paths, site_extra)
  }

  paths
}

highlight_styles <- function() {
  paths <- dir_ls(path_pkgdown("highlight-styles"), glob = "*.scss")
  path_ext_remove(path_file(paths))
}

get_bootswatch_theme <- function(pkg) {
  pkg$meta[["template"]]$bootswatch %||%
    pkg$meta[["template"]]$params$bootswatch %||%
    "_default"
}

check_bootswatch_theme <- function(bootswatch_theme, bs_version, pkg) {
  if (bootswatch_theme == "_default") {
    NULL
  } else if (bootswatch_theme %in% bslib::bootswatch_themes(bs_version)) {
    bootswatch_theme
  } else {
    abort(
      sprintf(
        "Can't find Bootswatch theme '%s' (%s) for Bootstrap version '%s' (%s).",
        bootswatch_theme,
        pkgdown_field(pkg, "template", "bootswatch"),
        bs_version,
        pkgdown_field(pkg, "template", "bootstrap")
      )
    )
  }

}
