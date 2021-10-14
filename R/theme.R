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

  bootswatch_theme <- get_bootswatch_theme(pkg)
  check_bootswatch_theme(bootswatch_theme, pkg$bs_version, pkg)

  bs_theme <- exec(bslib::bs_theme,
    version = pkg$bs_version,
    bootswatch = bootswatch_theme,
    !!!pkg$meta$template$bslib
  )
  bs_theme <- bslib::bs_add_rules(bs_theme,
    list(
      sass::sass_file(path_pkgdown("css/BS4/pkgdown.scss")),
      sass::sass_file(path_pkgdown("css/BS4/syntax-highlighting.scss"))
    )
  )

  bs_theme
}

get_bootswatch_theme <- function(pkg) {
  pkg$meta[["template"]]$bootswatch %||%
    pkg$meta[["template"]]$params$bootswatch %||%
    "_default"
}

check_bootswatch_theme <- function(bootswatch_theme, bs_version, pkg) {
  if (bootswatch_theme == "_default") {
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
