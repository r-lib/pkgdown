ext_topics <- function(match_strings) {
  pieces <- strsplit(match_strings, "::", fixed = TRUE)
  pkg <- purrr::map_chr(pieces, 1)
  fun <- sub("\\(\\)$", "", purrr::map_chr(pieces, 2))

  ext_rd <- purrr::map2(pkg, fun, get_rd_from_help)
  ext_title <- purrr::map_chr(ext_rd, extract_title)
  ext_href <- purrr::map2_chr(fun, pkg, downlit::href_topic)
  ext_funs <- purrr::map(ext_rd, topic_funs)

  tibble::tibble(
    name = match_strings,
    file_out = ext_href,
    title = sprintf("%s (from %s)", ext_title, pkg),
    funs = ext_funs,           # used list alternative names
    alias = list(character()), # used to find icons
    internal = FALSE
  )
}

# Adatpted from roxygen2::get_rd_from_help
get_rd_from_help <- function(package, alias) {
  check_installed(package, "as it's used in the reference index.")

  help <- utils::help((alias), (package))
  if (length(help) == 0) {
    abort(sprintf("Could not find documentation for %s::%s", package, alias))
    return()
  }

  out <- get(".getHelpFile", envir = asNamespace("utils"))(help)
  set_classes(out)
}
