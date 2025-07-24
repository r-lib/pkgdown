skip_if_no_pandoc <- function(version = "1.12.3") {
  skip_if_not(rmarkdown::pandoc_available(version), "pandoc not available")
}
skip_if_no_quarto <- function() {
  skip_on_os("windows") # quarto set up currently broken?
  skip_if(is.null(quarto::quarto_path()), "quarto not available")
  skip_if_not(quarto::quarto_version() >= "1.5", "quarto 1.5 not available")
}

# Simulate a package --------------------------------------------------------

local_pkgdown_site <- function(
  path = NULL,
  meta = list(),
  desc = list(),
  env = caller_env()
) {
  check_string(path, allow_null = TRUE)

  dst_path <- path_real(
    withr::local_tempdir(.local_envir = env, pattern = "pkgdown-dst")
  )
  # Simulate init_site() so we only have to run it if we care about <head>
  file_create(path(dst_path, "pkgdown.yml"))
  dir_create(path(dst_path, "deps"))
  file_create(path(dst_path, "deps", "data-deps.txt"))

  meta <- modify_list(meta, list(destination = dst_path))

  if (is.null(path)) {
    path <- path_real(
      withr::local_tempdir(.local_envir = env, pattern = "pkgdown-src")
    )

    description <- desc::desc("!new")
    description$set("Package", "testpackage")
    description$set("Title", "A test package")
    if (length(desc) > 0) {
      inject(description$set(!!!desc))
    }
    description$write(file = path(path, "DESCRIPTION"))

    # Default to BS5 only if template not specified
    meta$template <- meta$template %||% list(bootstrap = 5)

    # Record meta in case we re-run as_pkgdown()
    yaml::write_yaml(meta, path(path, "_pkgdown.yml"))

    # Make it a bit easier to create other files
    dir_create(path(path, "R"))
    dir_create(path(path, "vignettes"))
  }

  as_pkgdown(path, meta)
}

pkg_add_file <- function(pkg, path, lines = NULL) {
  full_path <- path(pkg$src_path, path)
  dir_create(path_dir(full_path))

  if (is.null(lines)) {
    file_create(full_path)
  } else {
    write_lines(lines, full_path)
  }

  if (path_has_parent(path, "vignettes")) {
    pkg <- as_pkgdown(pkg$src_path)
  }
  pkg
}

pkg_add_kitten <- function(pkg, path) {
  full_path <- path(pkg$src_path, path)
  dir_create(full_path)

  file_copy(test_path("assets/kitten.jpg"), full_path)
  pkg
}

pkg_vignette <- function(..., title = "title") {
  dots <- list2(title = title, ...)
  meta <- dots[have_name(dots)]
  contents <- unlist(dots[!have_name(dots)])

  meta$vignette <- paste0("\n", "  %\\VignetteIndexEntry{", title, "}")
  yaml <- yaml::as.yaml(
    meta,
    handlers = list(logical = yaml::verbatim_logical)
  )

  c("---", yaml, "---", contents)
}

r_code_block <- function(...) c("```{r}", ..., "```")

# Simulate a template package ------------------------------------------------

local_pkgdown_template_pkg <- function(
  path = NULL,
  meta = NULL,
  env = parent.frame()
) {
  if (is.null(path)) {
    path <- withr::local_tempdir(.local_envir = env)
    desc <- desc::desc("!new")
    desc$set("Package", "templatepackage")
    desc$set("Title", "A test template package")
    desc$write(file = path(path, "DESCRIPTION"))
  }

  if (!is.null(meta)) {
    path_pkgdown_yml <- path(path, "inst", "pkgdown", "_pkgdown.yml")
    dir_create(path_dir(path_pkgdown_yml))
    yaml::write_yaml(meta, path_pkgdown_yml)
  }

  pkgload::load_all(path, quiet = TRUE)
  withr::defer(pkgload::unload("templatepackage"), envir = env)

  path
}

in_rcmd_check <- function() {
  !is.na(Sys.getenv("_R_CHECK_PACKAGE_NAME_", NA)) ||
    tolower(Sys.getenv("_R_CHECK_LICENSE_")) == "true"
}
