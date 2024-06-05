# A CITATION file anywhere except in `inst/CITATION` is an R CMD check note
local_citation_activate <- function(path, envir = caller_env()) {
  old <- path(path, "inst", "temp-citation")
  new <- path(path, "inst", "CITATION")

  file_move(old, new)
  withr::defer(file_move(new, old), envir = envir)
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
