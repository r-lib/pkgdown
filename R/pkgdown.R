#' Determine if code is executed by pkgdown
#'
#' This is occasionally useful when you need different behaviour by
#' pkgdown and regular documentation.
#'
#' @export
#' @examples
#' in_pkgdown()
in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true")
}

local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$lang,
    .local_envir = scope
  )
}

local_pkgdown_site <- function(path = NULL,
                               meta = list(),
                               desc = list(),
                               env = caller_env()) {
  check_string(path, allow_null = TRUE)

  dst_path <- withr::local_tempdir(.local_envir = env)
  meta <- modify_list(meta, list(destination = dst_path))

  if (is.null(path)) {
    path <- withr::local_tempdir(.local_envir = env)
    
    description <- desc::desc("!new")
    description$set("Package", "testpackage")
    description$set("Title", "A test package")
    if (length(desc) > 0)
      inject(description$set(!!!desc))
    description$write(file = path(path, "DESCRIPTION"))

    # Default to BS5 only if template not specified
    meta$template <- meta$template %||% list(bootstrap = 5)

    # Record meta in case we re-run as_pkgdown()
    yaml::write_yaml(meta, path(path, "_pkgdown.yml"))
    
    # Make it a bit easier to create other files
    dir_create(path(path, "R"))
    dir_create(path(path, "vignettes"))

    # Create dummy deps so it's not 100% necessary to run init_site()
    dir_create(path(dst_path, "deps"))
    file_create(path(dst_path, "deps", "data-deps.txt"))
  }

  as_pkgdown(path, meta)
}

local_pkgdown_template_pkg <- function(path = NULL, meta = NULL, env = parent.frame()) {
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
