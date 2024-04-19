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
    cli::cli_abort(
      "Run {.fn pkgdown::init_site} first.",
      call = caller_env()
    )
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

  bs_theme_args <- pkg$meta$template$bslib %||% list()
  bs_theme_args[["version"]] <- pkg$bs_version
  bs_theme_args[["preset"]] <- get_bslib_theme(pkg)

  bs_theme <- exec(bslib::bs_theme, !!!bs_theme_args)

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
    cli::cli_abort(c(
      "Unknown theme: {.val {theme}}",
      i = "Valid themes are: {.val highlight_styles()}"
    ), call = caller_env())
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

get_bslib_theme <- function(pkg) {
  preset <- pkg$meta[["template"]]$bslib$preset

  if (!is.null(preset)) {
    check_bslib_theme(preset, pkg, c("template", "bslib", "preset"))
    return(preset)
  }

  bootswatch <-
    pkg$meta[["template"]]$bootswatch %||%
    # Historically (< 0.2.0), bootswatch wasn't a top-level template field
    pkg$meta[["template"]]$params$bootswatch

  if (!is.null(bootswatch)) {
    check_bslib_theme(bootswatch, pkg, c("template", "bootswatch"))
    return(bootswatch)
  }

  "default"
}

check_bslib_theme <- function(theme, pkg, field = c("template", "bootswatch"), bs_version = pkg$bs_version) {
  if (theme %in% c("_default", "default")) {
    return("default")
  }

  bslib_themes <- c(
    bslib::bootswatch_themes(bs_version),
    bslib::builtin_themes(bs_version),
    # bs_theme() recognizes both below as bare bootstrap
    "default",
    "bootstrap"
  )

  if (theme %in% bslib_themes) {
    return(theme)
  }

  cli::cli_abort(c(
    sprintf(
      "Can't find Bootswatch or bslib theme preset {.val %s} ({.field %s}) for Bootstrap version {.val %s} ({.field %s}).",
      theme,
      pkgdown_field(pkg, field),
      bs_version,
      pkgdown_field(pkg, c("template", "bootstrap"))
    ),
    x = "Edit settings in {pkgdown_config_href({pkg$src_path})}"
  ), call = caller_env())
}

bs_theme_deps_suppress <- function(deps = list()) {
  # jquery and bootstrap are provided by bslib
  # headr-attrs is included for pandoc 2.7.3 - 2.9.2.1 to improve accessibility
  # but includes javascript that breaks our HTML anchor system
  bs_dep_names <- c("jquery", "bootstrap", "header-attrs")
  bs_deps <- purrr::map(bs_dep_names, function(name) {
    # minimal version of htmltools::htmlDependency() (see suppressDependencies())
    structure(list(
      name = name,
      version = "9999",
      src = list(href = ""),
      all_files = TRUE
    ), class = "html_dependency")
  })

  c(deps, bs_deps)
}
