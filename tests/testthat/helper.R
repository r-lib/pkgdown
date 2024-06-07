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
