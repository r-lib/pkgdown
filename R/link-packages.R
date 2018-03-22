extract_package_attach <- function(expr) {
  if (is.expression(expr)) {
    packages <- purrr::map(expr, extract_package_attach)
    purrr::flatten_chr(packages)
  } else if (is_lang(expr)) {
    if (is_lang(expr, c("library", "require"))) {
      expr <- rlang::lang_standardise(expr)
      if (!is_true(expr$character.only)) {
        as.character(expr$package)
      } else {
        character()
      }
    } else {
      args <- as.list(expr[-1])
      purrr::flatten_chr(purrr::map(args, extract_package_attach))
    }
  } else {
    character()
  }
}

# Helper for testing
extract_package_attach_ <- function(expr) {
  extract_package_attach(enexpr(expr))
}
