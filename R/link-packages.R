packages_in_text <- function(text) {
  tryCatch({
    expr <- parse(text = text)
    packages <- purrr::map(expr, packages_in_expr)
    purrr::flatten_chr(packages)
  }, error = function(e) character())
}

packages_in_expr <- function(expr) {
  if (is_lang(expr)) {
    if (is_lang(expr, c("library", "require"))) {
      as.character(expr[[2]])
    } else {
      purrr::flatten_chr(purrr::map(as.list(expr[-1]), packages_in_expr))
    }
  } else {
    character()
  }
}

