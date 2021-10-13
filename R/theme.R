build_bslib <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  bs_theme <- bs_theme(pkg)

  deps <- bslib::bs_theme_dependencies(bs_theme)
  deps <- lapply(deps, htmltools::copyDependencyToDir, file.path(pkg$dst_path, "deps"))
  deps <- lapply(deps, htmltools::makeDependencyRelative, pkg$dst_path)

  head <- htmltools::renderDependencies(deps, srcType = "file")
  write_lines(head, data_deps_path(pkg))
}

data_deps_path <- function(pkg) {
  file.path(pkg$dst_path, "deps", "data-deps.txt")
}

bs_theme <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  bootswatch_theme <- get_bootswatch_theme(pkg)
  check_bootswatch_theme(bootswatch_theme, pkg$bs_version, pkg)

  bs_theme <- bslib::bs_theme(pkg$bs_version, bootswatch = bootswatch_theme)
  bs_theme <- bslib::bs_add_variables(bs_theme,
    `border-radius` = "1rem",
    `btn-border-radius` = ".25rem"
  )
  if (is.null(bootswatch_theme)) {
    # Add default colors if no Bootswatch
    bs_theme <- bslib::bs_add_variables(bs_theme,
      primary = "#0054AD",
      bg = "white",
      fg = "black",
      `body-color` = "$black",
      `component-active-bg` = "$secondary",
      `list-group-active-bg` = "$secondary",
      `navbar-light-bg` = "$gray-200",
      `navbar-light-color` = "$gray-800",
      `navbar-light-hover-color` = "$black",
      `navbar-dark-bg` = "$black",
      `navbar-dark-color` = "$gray-100",
      `navbar-dark-hover-color` = "$white",
      .where = "declarations"
    )
  }
  bs_theme <- bslib::bs_add_variables(bs_theme, !!!pkg$meta$template$bslib)

  bs_theme <- bslib::bs_add_rules(bs_theme,
    list(
      sass::sass_file(path_pkgdown("css/BS4/pkgdown-variables.scss")),
      sass::sass_file(path_pkgdown("css/BS4/pkgdown.scss")),
      sass::sass_file(path_pkgdown("css/BS4/syntax-highlighting.scss"))
    )
  )

  bs_theme
}

get_bootswatch_theme <- function(pkg) {
  pkg$meta[["template"]]$bootswatch %||%
    pkg$meta[["template"]]$params$bootswatch %||%
    NULL
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
      pkgdown_field(pkg, "template", "bootswatch"),
      bs_version,
      pkgdown_field(pkg, "template", "bootstrap")
    )
  )
}
