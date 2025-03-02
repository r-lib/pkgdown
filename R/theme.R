build_bslib <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)
  bs_theme <- bs_theme(pkg, call = call)

  cur_deps <- find_deps(pkg)
  cur_digest <- purrr::map_chr(cur_deps, file_digest)

  deps <- c(bslib::bs_theme_dependencies(bs_theme), external_dependencies(pkg))
  deps <- lapply(
    deps,
    htmltools::copyDependencyToDir,
    path(pkg$dst_path, "deps")
  )
  deps <- lapply(deps, htmltools::makeDependencyRelative, pkg$dst_path)

  new_deps <- find_deps(pkg)
  new_digest <- purrr::map_chr(cur_deps, file_digest)

  all_deps <- union(new_deps, cur_deps)
  diff <- (cur_digest[all_deps] == new_digest[all_deps])
  changed <- all_deps[!diff | is.na(diff)]

  if (length(changed) > 0) {
    withr::local_locale(LC_COLLATE = "C")
    purrr::walk(sort(changed), function(dst) {
      cli::cli_inform("Updating {dst_path(path_rel(dst, pkg$dst_path))}")
    })
  }

  head <- htmltools::renderDependencies(deps, srcType = "file")
  write_lines(head, data_deps_path(pkg))
}

data_deps <- function(pkg, depth) {
  if (!file_exists(data_deps_path(pkg))) {
    # this is unlikely to occur after #2439 and #2571
    cli::cli_abort(
      "Run {.fn pkgdown::init_site} first.",
      .internal = TRUE,
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
  path(pkg$dst_path, "deps", "data-deps.txt")
}

find_deps <- function(pkg) {
  deps_path <- path(pkg$dst_path, "deps")
  if (!dir_exists(deps_path)) {
    character()
  } else {
    dir_ls(deps_path, type = "file", recurse = TRUE)
  }
}

bs_theme <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  bs_theme_args <- pkg$meta$template$bslib %||% list()
  bs_theme_args[["version"]] <- pkg$bs_version
  # In bslib >= 0.5.1, bs_theme() takes bootstrap preset theme via `preset`
  bs_theme_args[["preset"]] <- get_bslib_theme(pkg)
  bs_theme_args[["bootswatch"]] <- NULL

  bs_theme <- exec(bslib::bs_theme, !!!bs_theme_args)

  # Drop bs3 compat files added for shiny/RMarkdown
  bs_theme <- bslib::bs_remove(bs_theme, "bs3compat")

  # Add additional pkgdown rules
  rules <- bs_theme_rules(pkg, call = call)
  files <- lapply(rules, sass::sass_file)
  bs_theme <- bslib::bs_add_rules(bs_theme, files)

  # Add dark theme if needed
  if (uses_lightswitch(pkg)) {
    dark_theme <- config_pluck_string(
      pkg,
      "template.theme-dark",
      default = "arrow-dark"
    )
    check_theme(
      dark_theme,
      error_pkg = pkg,
      error_path = "template.theme-dark",
      error_call = call
    )
    path <- highlight_path(dark_theme)
    css <- c('[data-bs-theme="dark"] {', read_lines(path), '}')
    bs_theme <- bslib::bs_add_rules(bs_theme, css)
  }

  bs_theme
}

bs_theme_rules <- function(pkg, call = caller_env()) {
  paths <- path_pkgdown("BS5", "assets", "pkgdown.scss")

  theme <- config_pluck_string(pkg, "template.theme", default = "arrow-light")
  check_theme(
    theme,
    error_pkg = pkg,
    error_path = "template.theme",
    error_call = call
  )
  paths <- c(paths, highlight_path(theme))

  package <- config_pluck_string(pkg, "template.package")
  if (!is.null(package)) {
    package_extra <- path_package_pkgdown("extra.scss", package, pkg$bs_version)
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

check_theme <- function(
  theme,
  error_pkg,
  error_path,
  error_call = caller_env()
) {
  if (theme %in% highlight_styles()) {
    return()
  }
  config_abort(
    error_pkg,
    "{.field {error_path}} uses theme {.val {theme}}",
    call = error_call
  )
}

highlight_path <- function(theme) {
  path_pkgdown("highlight-styles", paste0(theme, ".scss"))
}

highlight_styles <- function() {
  paths <- dir_ls(path_pkgdown("highlight-styles"), glob = "*.scss")
  path_ext_remove(path_file(paths))
}

get_bslib_theme <- function(pkg) {
  themes <- list(
    "template.bslib.preset" = pkg$meta[["template"]]$bslib$preset,
    "template.bslib.bootswatch" = pkg$meta[["template"]]$bslib$bootswatch,
    "template.bootswatch" = pkg$meta[["template"]]$bootswatch,
    # Historically (< 0.2.0), bootswatch wasn't a top-level template field
    "template.params.bootswatch" = pkg$meta[["template"]]$params$bootswatch
  )

  is_present <- !purrr::map_lgl(themes, is.null)
  n_present <- sum(is_present)
  n_unique <- length(unique(themes[is_present]))

  if (n_present == 0) {
    return("default")
  }

  if (n_present > 1 && n_unique > 1) {
    cli::cli_warn(c(
      "Multiple Bootstrap preset themes were set. Using {.val {themes[is_present][[1]]}} from {.field {names(themes)[is_present][1]}}.",
      x = "Found {.and {.field {names(themes)[is_present]}}}.",
      i = "Remove extraneous theme declarations to avoid this warning."
    ))
  }

  field <- names(themes)[which(is_present)[1]]
  check_bslib_theme(themes[[field]], pkg, field)
}

check_bslib_theme <- function(
  theme,
  pkg,
  field = "template.bootswatch",
  bs_version = pkg$bs_version
) {
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

  config_abort(
    pkg,
    c(
      x = "{.field {field}} contains unknown Bootswatch/bslib theme {.val {theme}}.",
      i = "Using Bootstrap version {.val {bs_version}} ({.field template.bootstrap})."
    ),
    call = caller_env()
  )
}

bs_theme_deps_suppress <- function(deps = list()) {
  # jquery and bootstrap are provided by bslib
  # headr-attrs is included for pandoc 2.7.3 - 2.9.2.1 to improve accessibility
  # but includes javascript that breaks our HTML anchor system
  bs_dep_names <- c("jquery", "bootstrap", "header-attrs")
  bs_deps <- purrr::map(bs_dep_names, function(name) {
    # minimal version of htmltools::htmlDependency() (see suppressDependencies())
    structure(
      list(
        name = name,
        version = "9999",
        src = list(href = ""),
        all_files = TRUE
      ),
      class = "html_dependency"
    )
  })

  c(deps, bs_deps)
}
