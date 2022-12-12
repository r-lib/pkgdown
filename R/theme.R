build_bslib <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  bs_theme <- bs_theme(pkg)

  deps <- bslib::bs_theme_dependencies(bs_theme)
  deps <- lapply(deps, htmltools::copyDependencyToDir, path_deps(pkg))
  deps <- lapply(deps, htmltools::makeDependencyRelative, pkg$dst_path)

  head <- htmltools::renderDependencies(deps, srcType = "file")

  # include additional external assets
  use_ext <- isTRUE(pkg$meta$template$params$external_assets)
  head <- paste(
    head,
    paste0(assemble_ext_assets(pkg, use_ext), collapse = "\n"),
    sep = "\n"
  )

  write_lines(head, path_data_deps(pkg))
}

assemble_ext_assets <- function(pkg,
                                use_ext = FALSE) {
  path_assets_yaml <- path_pkgdown(paste0("BS", pkg$bs_version), "assets_external.yaml")
  deps_ext <- yaml::read_yaml(path_assets_yaml)

  purrr::map_chr(deps_ext, ~ {
    # download resource if necessary
    if (!use_ext) {
      path <- path_deps(pkg, basename(.x$url))
      download.file(.x$url, path, quiet = TRUE)

      # check file integrity
      file_content <- file(path)
      sha_version <- regmatches(
        .x$integrity,
        regexpr("(?<=^sha)\\d{3}", .x$integrity, perl = TRUE)
      )
      hash_target <- regmatches(
        .x$integrity,
        regexpr("(?<=^sha\\d{3}-).+", .x$integrity, perl = TRUE)
      )
      hash <- openssl::base64_encode(switch(
        sha_version,
        "256" = openssl::sha256(file_content),
        "384" = openssl::sha384(file_content),
        "512" = openssl::sha512(file_content),
        cli::cli_abort(paste0(
          "Invalid {.field integrity} value set in {.file {path_assets_yaml}}: ",
          "{.val {(.x$integrity)}} Allowed are only SHA-256, SHA-384 and SHA-512."
        ))
      ))

      if (hash_target != hash) {
        cli::cli_abort(paste0(
          "Hash of downloaded {(.x$type)} asset doesn't match {.field ",
          "integrity} value of {.val {(.x$integrity)}}. Asset URL is: {.url {(.x$url)}}"
        ))
      }

      # download subressources (webfonts etc.) if necessary
      if (isTRUE(.x$has_subressources)) {
        file_content <- read_file(path)
        pos <- gregexpr("(?<=\\burl\\((?!(data|https?):))[^)?#]*", file_content, perl = TRUE)
        urls <- unique(unlist(regmatches(file_content, pos)))
        subdirs <- unique(fs::path_dir(urls))
        fs::dir_create(
          fs::path_norm(fs::path(path_deps(pkg), subdirs)),
          recurse = TRUE
        )
        url_parsed <- xml2::url_parse(.x$url)
        url_excl_scheme <- fs::path(url_parsed$server, url_parsed$path)
        remote_urls <- paste0(
          url_parsed$scheme, "://",
          fs::path_norm(fs::path(fs::path_dir(url_excl_scheme), urls))
        )
        purrr::walk2(
          remote_urls,
          urls,
          ~ download.file(.x, fs::path_norm(path_deps(pkg, .y)), quiet = TRUE)
        )
      }
      .x$url <- fs::path_rel(path, pkg$dst_path)
    }

    # assemble HTML tag
    switch(
      .x$type,
      "stylesheet" = paste0(
        sprintf('<link rel="stylesheet" href="%s"', .x$url),
        if (use_ext) sprintf(' integrity="%s" crossorigin="anonymous"', .x$integrity),
        ' />'
      ),
      "script" = paste0(
        sprintf('<script src="%s"', .x$url),
        if (use_ext) sprintf(' integrity="%s" crossorigin="anonymous"', .x$integrity),
        '></script>'
      ),
      cli::cli_abort(
        "Unknown asset type {.val {.x$type}} defined in {.file path_assets_yaml}."
      )
    )
  })
}

data_deps <- function(pkg, depth) {
  if (!file.exists(path_data_deps(pkg))) {
    abort("Run pkgdown::init_site() first.")
  }

  deps_path <- paste0(up_path(depth), "deps")

  data_deps <- read_lines(path_data_deps(pkg))
  data_deps <- gsub('src="deps', sprintf('src="%s', deps_path), data_deps)
  data_deps <- gsub('href="deps', sprintf('href="%s', deps_path), data_deps)

  paste0(data_deps, collapse = "")
}

path_deps <- function(pkg, ...) {
  file.path(pkg$dst_path, "deps", ...)
}

path_data_deps <- function(pkg) {
  file.path(path_deps(pkg), "data-deps.txt")
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
        pkgdown_field(pkg, c("template", "bootswatch")),
        bs_version,
        pkgdown_field(pkg, c("template", "bootstrap"))
      )
    )
  }

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
